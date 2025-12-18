#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

# ----------------------------------------
# Fonctions utilitaires
# ----------------------------------------
log()  { echo -e "[INFO] $*"; }
warn() { echo -e "[WARN] $*" >&2; }
die()  { echo -e "[ERROR] $*" >&2; exit 1; }

usage() {
  cat <<EOF
Usage: $0 [options]

Options:
  --fix                    : ajoute suffixe -fix au tag Docker full
  --registry REG           : Harbor registry IP/hostname:port (default: localhost:80)
  --project PROJ           : nom du projet (default: nom du dossier courant)
  --repo REPO              : nom du repository (default: app)
  --version-file PATH      : fichier version (default: VERSION)
  --dockerfile PATH        : Dockerfile (default: Dockerfile dans le dossier courant)
  --no-push                : build local sans push
  --commit-version         : commit le bump de version
  -h, --help               : affiche cette aide
EOF
  exit 1
}

# ----------------------------------------
# Valeurs par défaut
# ----------------------------------------
PROJECT="${PROJECT:-$(basename "$(pwd)")}"
PROJECT="${PROJECT,,}"  # minuscules
REPO="${REPO:-app}"
REPO="${REPO,,}"        # minuscules
REGISTRY="${REGISTRY:-localhost:80}"
VERSION_FILE="${VERSION_FILE:-VERSION}"
DOCKERFILE="${DOCKERFILE:-Dockerfile}"
FIX_TAG=false
NO_PUSH=false
COMMIT_VERSION=false

# ----------------------------------------
# Parse args
# ----------------------------------------
while [[ $# -gt 0 ]]; do
    case "$1" in
        --fix) FIX_TAG=true; shift ;;
        --registry) REGISTRY="$2"; shift 2 ;;
        --project) PROJECT="$2"; shift 2 ;;
        --repo) REPO="$2"; shift 2 ;;
        --version-file) VERSION_FILE="$2"; shift 2 ;;
        --dockerfile) DOCKERFILE="$2"; shift 2 ;;
        --no-push) NO_PUSH=true; shift ;;
        --commit-version) COMMIT_VERSION=true; shift ;;
        -h|--help) usage ;;
        *) die "Option inconnue : $1";;
    esac
done

# ----------------------------------------
# Pré-requis
# ----------------------------------------
command -v git >/dev/null 2>&1 || die "git introuvable."
command -v docker >/dev/null 2>&1 || die "docker introuvable."
[[ -f "$DOCKERFILE" ]] || die "Dockerfile introuvable : $DOCKERFILE"

# ----------------------------------------
# Infos Git
# ----------------------------------------
GIT_BRANCH=$(git rev-parse --abbrev-ref HEAD)
GIT_COMMIT=$(git rev-parse --short HEAD)
GIT_COMMIT_FULL=$(git rev-parse HEAD)
GIT_DATE=$(git log -1 --format=%cd --date=format:'%Y-%m-%d %H:%M:%S %z')

log "Git: branch=$GIT_BRANCH commit=$GIT_COMMIT ($GIT_COMMIT_FULL) date='$GIT_DATE'"

# ----------------------------------------
# Détection environnement
# ----------------------------------------
branch_lower=${GIT_BRANCH,,}
case "$branch_lower" in
    main|master|prod|production|release*) ENV_TYPE="prod" ;;
    dev|develop|development) ENV_TYPE="dev" ;;
    *) ENV_TYPE="other" ;;
esac
log "Environnement détecté: $ENV_TYPE"

# ----------------------------------------
# Gestion version
# ----------------------------------------
if [[ ! -f "$VERSION_FILE" ]]; then
    echo "1.0" > "$VERSION_FILE"
fi

CURRENT_VERSION=$(<"$VERSION_FILE")
if ! [[ "$CURRENT_VERSION" =~ ^[0-9]+(\.[0-9]+)?$ ]]; then
    warn "Version actuelle '$CURRENT_VERSION' invalide. Réinitialisation à 1.0"
    CURRENT_VERSION="1.0"
fi

NEXT_VERSION=$(awk -v v="$CURRENT_VERSION" 'BEGIN{printf("%.1f", v+0.1)}')
echo "$NEXT_VERSION" > "$VERSION_FILE"
log "Version mise à jour: $CURRENT_VERSION -> $NEXT_VERSION"

$COMMIT_VERSION && git add "$VERSION_FILE" && git commit -m "Bump version to $NEXT_VERSION [ci-script]" || true

# ----------------------------------------
# Tags Docker selon l'environnement
# ----------------------------------------
timestamp=$(date +%Y%m%d%H%M%S)
fix_suffix=""
$FIX_TAG && fix_suffix="-fix"

if [[ "$ENV_TYPE" == "prod" ]]; then
    full_tag="${REPO}-v${NEXT_VERSION}${fix_suffix}-${GIT_COMMIT}-${timestamp}"
    latest_tag="${REPO}:latest"
else
    full_tag="${REPO}-v${NEXT_VERSION}${fix_suffix}-${GIT_COMMIT}-${timestamp}"
    latest_tag="${REPO}:v${NEXT_VERSION}-${GIT_COMMIT}-${timestamp}"
fi

log "Tags générés: full_tag=$full_tag latest_tag=$latest_tag"

# ----------------------------------------
# Build Docker
# ----------------------------------------
log "Construction image Docker..."
docker build -f "$DOCKERFILE" -t "$full_tag" -t "$latest_tag" . || die "Build Docker échoué"
log "Build terminé."

# ----------------------------------------
# Push vers Harbor
# ----------------------------------------
HARBOR_USER='robot$robot'
HARBOR_API_TOKEN="XAfc4wezaACkcdkEnYDE1H74cUOYMhCo"

if ! $NO_PUSH; then
    log "Authentification à Harbor..."
    docker login "$REGISTRY" -u "$HARBOR_USER" -p "$HARBOR_API_TOKEN" >/dev/null 2>&1 || die "Docker login échoué"

    full_tag_registry="${REGISTRY}/${PROJECT}/${full_tag}"
    latest_tag_registry="${REGISTRY}/${PROJECT}/${latest_tag}"

    docker tag "$full_tag" "$full_tag_registry"
    docker tag "$latest_tag" "$latest_tag_registry"

    log "Push de l'image vers Harbor..."
    docker push "$full_tag_registry" || warn "Push échoué pour $full_tag_registry"
    docker push "$latest_tag_registry" || warn "Push échoué pour $latest_tag_registry"

    log "Push terminé."
else
    warn "Push désactivé (--no-push)."
fi

# ----------------------------------------
# Résumé final
# ----------------------------------------
cat <<EOF

=== RÉSUMÉ ===
Projet : $PROJECT
Repository : $REPO
Branch : $GIT_BRANCH
Commit : $GIT_COMMIT ($GIT_COMMIT_FULL)
Commit date : $GIT_DATE
Environnement : $ENV_TYPE
Version fichier : $NEXT_VERSION
Image construite : $full_tag
Image latest : $latest_tag
Push : $( $NO_PUSH && echo "NON (--no-push)" || echo "OUI -> ${REGISTRY}") 

EOF

log "Script terminé."
exit 0
