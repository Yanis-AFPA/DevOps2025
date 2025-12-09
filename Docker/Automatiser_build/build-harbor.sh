#!/usr/bin/env bash
#
# ci-build-and-push-final.sh
#
# Script CI/CD simplifié pour Harbor :
#  - Détection automatique de l'environnement (prod/dev/other)
#  - Gestion version incrémentale
#  - Tag Docker cohérent, avec option --fix
#  - Build et push Docker
#  - Trivy géré par Harbor (scan après push)
#
set -euo pipefail
IFS=$'\n\t'

# ---------------------------
# Fonctions utilitaires
# ---------------------------
log()   { printf '\e[1;34m[INFO]\e[0m %s\n' "$*"; }
warn()  { printf '\e[1;33m[WARN]\e[0m %s\n' "$*" >&2; }
err()   { printf '\e[1;31m[ERROR]\e[0m %s\n' "$*" >&2; exit 1; }
die()   { err "$*"; }

usage() {
  cat <<EOF
Usage: $0 [options]

Options:
  --fix                    : marque le tag comme 'fix' (suffixe -fix)
  --registry REG           : Harbor registry (ex: harbor.example.com)
  --project PROJ           : Harbor project (ex: myproject)
  --repo REPO              : Repository name (ex: myapp)
  --version-file PATH      : fichier version (default: VERSION)
  --dockerfile PATH        : Dockerfile (default: Dockerfile)
  --no-push                : ne pas push vers Harbor (tests locaux)
  --commit-version         : commit local du bump de version
  -h, --help               : affiche cette aide

EOF
  exit 1
}

# ---------------------------
# Parse args
# ---------------------------
FIX_TAG=false
REGISTRY="${HARBOR_REGISTRY:-}"
PROJECT="${HARBOR_PROJECT:-}"
REPO="${HARBOR_REPO:-}"
VERSION_FILE="VERSION"
DOCKERFILE="Dockerfile"
NO_PUSH=false
COMMIT_VERSION=false

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
    *) die "Option inconnue: $1";;
  esac
done

# ---------------------------
# Pré-requis
# ---------------------------
command -v git >/dev/null 2>&1 || die "git introuvable."
command -v docker >/dev/null 2>&1 || die "docker introuvable."
[[ -f "$DOCKERFILE" ]] || die "Dockerfile introuvable: $DOCKERFILE"

# Si push activé, registry/project/repo requis
if ! $NO_PUSH; then
  : "${REGISTRY:?Registry Harbor requis}"
  : "${PROJECT:?Harbor project requis}"
  : "${REPO:?Harbor repo requis}"
fi

# ---------------------------
# Infos Git
# ---------------------------
git_root=$(git rev-parse --show-toplevel 2>/dev/null || true)
[[ -n "$git_root" ]] || die "Ce script doit être exécuté depuis un dépôt git."
cd "$git_root"

commit_short=$(git rev-parse --short HEAD)
commit_long=$(git rev-parse HEAD)
commit_date=$(git show -s --format=%ci HEAD)
branch_name=$(git rev-parse --abbrev-ref HEAD)

log "Git: branch=$branch_name commit=$commit_short ($commit_long) date='$commit_date'"

# ---------------------------
# Détection environnement prod/dev/other
# ---------------------------
branch_lower=${branch_name,,}  # lowercase
case "$branch_lower" in
    main|master|prod|production|release*)
        ENV_TYPE="prod"
        ;;
    dev|develop|development)
        ENV_TYPE="dev"
        ;;
    *)
        ENV_TYPE="other"
        ;;
esac
log "Environnement détecté: $ENV_TYPE"

# ---------------------------
# Version incrémentale
# ---------------------------
if [[ ! -f "$VERSION_FILE" ]]; then
  log "Fichier version introuvable ($VERSION_FILE). Création initiale 1.0"
  echo "1.0" > "$VERSION_FILE"
fi

current_version=$(<"$VERSION_FILE")
if ! [[ "$current_version" =~ ^[0-9]+(\.[0-9]+)?$ ]]; then
  warn "Version actuelle '$current_version' invalide. Réinitialisation à 1.0"
  current_version="1.0"
fi

next_version=$(awk -v v="$current_version" 'BEGIN{printf("%.1f", v+0.1)}')
echo "$next_version" > "$VERSION_FILE"
log "Version mise à jour: $current_version -> $next_version"

$COMMIT_VERSION && git add "$VERSION_FILE" && git commit -m "Bump version to $next_version [ci-script]" || true

# ---------------------------
# Tags Docker
# ---------------------------
branch_safe=$(echo "$branch_name" | sed 's#[/:]#-#g' | tr '[:upper:]' '[:lower:]')
date_tag=$(date -u +"%Y%m%dT%H%M%SZ")
fix_suffix=""
$FIX_TAG && fix_suffix="-fix"

image_base="${REGISTRY}/${PROJECT}/${REPO}"
tag_body="${ENV_TYPE}${fix_suffix}-v${next_version}-${branch_safe}-${date_tag}-${commit_short}"
full_tag="${image_base}:${tag_body}"
latest_tag="${image_base}:latest"

log "Tags générés: full_tag=$full_tag latest_tag=$latest_tag"

# ---------------------------
# Build Docker
# ---------------------------
log "Construction image Docker..."
docker build -f "$DOCKERFILE" -t "$full_tag" -t "$latest_tag" . || die "Docker build a échoué."
log "Build terminé."

# ---------------------------
# Push vers Harbor
# ---------------------------
if ! $NO_PUSH; then
  log "Push de l'image vers Harbor..."
  docker push "$full_tag" || warn "Push échoué pour $full_tag"
  docker push "$latest_tag" || warn "Push échoué pour $latest_tag"
  log "Push terminé."
else
  warn "Push désactivé (--no-push). Images locales uniquement."
fi

# ---------------------------
# Résumé final
# ---------------------------
cat <<EOF

=== RÉSUMÉ ===
Repository: $git_root
Branch: $branch_name
Commit: $commit_short ($commit_long)
Commit date: $commit_date
Environnement: $ENV_TYPE
Version fichier: $next_version
Image construite: $full_tag
Image latest: $latest_tag
Push: $( $NO_PUSH && echo "NON (no-push)" || echo "OUI -> $REGISTRY/$PROJECT/$REPO" )
Harbor gère automatiquement le scan Trivy après push.

EOF

log "Script terminé."
exit 0
