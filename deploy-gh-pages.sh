#!/bin/bash
# ==================================================
# deploy-gh-pages-v2.sh
# --------------------------------------------------
# Purpose:
# - Deploy a static HTML/CSS/JS website to gh-pages
# - Ensure gh-pages always mirrors master
# - Show colored output and live URL
# - Auto-update footer year via date.js
# --------------------------------------------------

# -----------------------------
# Color definitions
# -----------------------------
GREEN="\033[0;32m"
RED="\033[0;31m"
YELLOW="\033[1;33m"
BLUE="\033[0;34m"
NC="\033[0m"

# -----------------------------
# Helper functions
# -----------------------------
log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; exit 1; }

# -----------------------------
# Safety checks
# -----------------------------
if ! git rev-parse --is-inside-work-tree > /dev/null 2>&1; then
  log_error "This directory is not a git repository."
fi

MAIN_BRANCH="master"

# Ensure master exists
if ! git show-ref --verify --quiet refs/heads/master; then
  log_error "Master branch not found."
fi

log_info "Using 'master' as source branch."

# Ensure clean working tree
if ! git diff --quiet || ! git diff --cached --quiet; then
  log_warn "Uncommitted changes detected. Commit before deploying."
  exit 1
fi

# Pull latest master
log_info "Pulling latest changes from origin/${MAIN_BRANCH}..."
git pull origin ${MAIN_BRANCH} || log_error "Failed to pull master."

# Check or create gh-pages
if ! git show-ref --verify --quiet refs/heads/gh-pages; then
  log_warn "gh-pages branch not found. Creating..."
  git checkout -b gh-pages || log_error "Failed to create gh-pages branch."
  git push -u origin gh-pages || log_error "Failed to push gh-pages branch."
fi

# Reset gh-pages to match master
log_info "Switching to gh-pages branch..."
git checkout gh-pages || log_error "Failed to switch to gh-pages."
log_info "Resetting gh-pages to match master..."
git reset --hard ${MAIN_BRANCH} || log_error "Failed to reset gh-pages."

# Optional: auto-update footer year in index.html, gallery.html, contact.html
for file in index.html gallery.html contact.html; do
  if [ -f "$file" ]; then
    sed -i "s/© [0-9]\{4\}/© $(date +%Y)/" "$file"
  fi
 done

# Push gh-pages
log_info "Pushing gh-pages to origin..."
git push origin gh-pages --force || log_error "Failed to push gh-pages."

# Return to master
log_info "Returning to master branch..."
git checkout ${MAIN_BRANCH} || log_warn "Could not switch back to master."

# Display live site URL
ORIGIN_URL=$(git config --get remote.origin.url)
GITHUB_USER=$(echo "$ORIGIN_URL" | sed -E 's#(git@github.com:|https://github.com/)([^/]+)/([^/]+)(\.git)?#\2#')
REPO_NAME=$(echo "$ORIGIN_URL" | sed -E 's#(git@github.com:|https://github.com/)([^/]+)/([^/]+)(\.git)?#\3#')

if [ -n "$GITHUB_USER" ] && [ -n "$REPO_NAME" ]; then
  LIVE_URL="https://${GITHUB_USER}.github.io/${REPO_NAME}/"
  log_success "Deployment complete!"
  log_info "Your site is live at:"
  echo -e "${GREEN}${LIVE_URL}${NC}"
else
  log_success "Deployment complete!"
  log_warn "Could not detect live URL. Check GitHub Pages settings."
fi

# -----------------------------
# End of deploy-gh-pages-v2.sh
# -----------------------------