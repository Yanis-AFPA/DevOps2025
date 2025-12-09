#!/usr/bin/env bash
set -euo pipefail

# ----------------------------------------
# Fonctions utilitaires
# ----------------------------------------
log()  { echo -e "[INFO] $*"; }
warn() { echo -e "[WARN] $*" >&2; }
die()  { echo -e "[ERROR] $*" >&2; exit 1; }

# ----------------------------------------
# Configuration
# ----------------------------------------
PROJECT="automatiser_build"
REGISTRY="localhost:80"

# Robot account Harbor
HARBOR_USER='robot$robot'
HARBOR_API_TOKEN="XAfc4wezaACkcdkEnYDE1H74cUOYMhCo"

# Pas de push si --no-push
NO_PUSH=false
if [[ "${1:-}" == "--no-push" ]]; then NO_PUSH=true; fi

# ----------------------------------------
# Extraction Git
# ----------------------------------------
GIT_BRANCH=$(git rev-parse --abbrev-ref HEAD)
GIT_COMMIT=$(git rev-parse --short HEAD)
GIT_COMMIT_FULL=$(git rev-parse HEAD)
GIT_DATE=$(git log -1 --format=%cd --date=format:'%Y-%m-%d %H:%M:%S %z')

log "Git: branch=$GIT_BRANCH commit=$GIT_COMMIT ($GIT_COMMIT_FULL) date='$GIT_DATE'"

# ----------------------------------------
# Gestion version
# ----------------------------------------
VERSION_FILE="VERSION"

if [[ ! -f "$VERSION_FILE" ]]; then
    echo "1.0" > "$VERSION_FILE"
fi

OLD_VERSION=$(cat "$VERSION_FILE")
NEW_VERSION=$(awk -F. '{printf "%d.%d", $1, $2+1}' VERSION)

echo "$NEW_VERSION" > "$VERSION_FILE"
log "Version mise à jour: $OLD_VERSION -> $NEW_VERSION"

# ----------------------------------------
# Tags Docker
# ----------------------------------------
timestamp=$(date +%Y%m%d%H%M%S)
full_tag="${PROJECT}-v${NEW_VERSION}-${GIT_COMMIT}-${timestamp}"
latest_tag="${PROJECT}-latest"

log "Tags générés: full_tag=$full_tag latest_tag=$latest_tag"

# ----------------------------------------
# Build Docker
# ----------------------------------------
log "Construction image Docker..."
docker build -t "$full_tag" -t "$latest_tag" . || die "Build Docker échoué"
log "Build terminé."

# ----------------------------------------
# Push vers Harbor
# ----------------------------------------
if ! $NO_PUSH; then
    log "Authentification à Harbor..."

    docker login "$REGISTRY" \
        -u "$HARBOR_USER" \
        -p "$HARBOR_API_TOKEN" \
        >/dev/null 2>&1 || die "Docker login échoué"

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
