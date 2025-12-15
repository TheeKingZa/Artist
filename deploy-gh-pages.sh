#!/bin/bash
# ==================================================
# deploy-sync-gh-pages.sh
# --------------------------------------------------
# Purpose:
# - Sync master and gh-pages bidirectionally
# - Ensure branches mirror each other
# - Show colored output and live URL
# - Auto-update footer year via date.js
# - Stage changes and ask for commit message
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

MASTER_BRANCH="master"
GH_PAGES_BRANCH="gh-pages"

# Ensure branches exist
for branch in $MASTER_BRANCH $GH_PAGES_BRANCH; do
  if ! git show-ref --verify --quiet refs/heads/$branch; then
    log_warn "$branch branch not found. Creating..."
    git checkout -b $branch || log_error "Failed to create $branch branch."
    git push -u origin $branch || log_error "Failed to push $branch branch."
  fi
done

# Stage all changes
log_info "Staging all changes..."
git add .

# Ask for commit message
read -p "Enter commit message: " COMMIT_MSG
if [ -z "$COMMIT_MSG" ]; then
  COMMIT_MSG="Update site"
fi

# Commit changes
git commit -m "$COMMIT_MSG" || log_info "No changes to commit."

# Pull latest changes
log_info "Pulling latest changes from origin/$MASTER_BRANCH..."
git checkout $MASTER_BRANCH
git pull origin $MASTER_BRANCH || log_error "Failed to pull master."
log_info "Pulling latest changes from origin/$GH_PAGES_BRANCH..."
git checkout $GH_PAGES_BRANCH
git pull origin $GH_PAGES_BRANCH || log_error "Failed to pull gh-pages."

# Compare branches
log_info "Checking if branches are in sync..."
SYNC_STATUS=$(git log --oneline $MASTER_BRANCH..$GH_PAGES_BRANCH)
if [ -z "$SYNC_STATUS" ]; then
  log_success "Branches are already in sync."
else
  log_warn "Branches differ. Syncing gh-pages with master..."
  git checkout $GH_PAGES_BRANCH || log_error "Failed to switch to gh-pages."
  git reset --hard $MASTER_BRANCH || log_error "Failed to reset gh-pages to master."
  git push origin $GH_PAGES_BRANCH --force || log_error "Failed to push gh-pages."
  log_success "gh-pages synced with master."
fi

# Optional: auto-update footer year
for file in index.html gallery.html contact.html; do
  if [ -f "$file" ]; then
    sed -i "s/© [0-9]\{4\}/© $(date +%Y)/" "$file"
  fi
 done

# Return to master
git checkout $MASTER_BRANCH
log_success "Returned to master branch."

# Display live URL
ORIGIN_URL=$(git config --get remote.origin.url)
CLEAN_URL=$(echo "$ORIGIN_URL" | sed -E 's#(https://|git@)##; s#.*github.com[:/]##; s#\.git$##')
GITHUB_USER=$(echo "$CLEAN_URL" | cut -d'/' -f1)
REPO_NAME=$(echo "$CLEAN_URL" | cut -d'/' -f2)

if [ -n "$GITHUB_USER" ] && [ -n "$REPO_NAME" ]; then
  LIVE_URL="https://${GITHUB_USER}.github.io/${REPO_NAME}/"
  log_success "Deployment complete!"
  log_info "Your site is live at:"
  echo -e "${GREEN}${LIVE_URL}${NC}"
else
  log_warn "Could not detect live URL. Check GitHub Pages settings."
fi

# -----------------------------
# End of deploy-sync-gh-pages.sh
# -----------------------------