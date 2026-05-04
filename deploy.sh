#!/bin/bash

# Set the names of your branches
pages_branch="gh-pages"
master_branch="master"

# Check if git is installed
if ! command -v git &> /dev/null; then
  echo "Error: Git is not installed. Please install Git before proceeding."
  exit 1
fi

# Check if the master branch exists. If not, create it.
if ! git branch -l | grep -q "$master_branch"; then
  echo "Creating master branch..."
  git checkout -b $master_branch
  git push -u origin $master_branch
  echo "Successfully created master branch."
else
  echo "Master branch already exists. Proceeding..."
fi

# Check if the gh-pages branch exists. If not, create it.
if ! git branch -l | grep -q "$pages_branch"; then
  echo "Creating gh-pages branch..."
  git checkout --orphan $pages_branch
  git rm -rf .
  git commit -m "Initial commit for gh-pages"
  git push --set-upstream origin $pages_branch
  echo "Successfully created gh-pages branch."
else
  echo "gh-pages branch already exists. Proceeding with deployment..."
fi

# Build your website (replace with your actual build command)
echo "Building website..."
# Add your build command here if needed

# Check for changes in the master branch
git checkout $master_branch
if [[ -n $(git status -s) ]]; then
  # Prompt for a commit message
  read -p "Enter commit message for master branch: " commit_message
  git add .
  git commit -m "$commit_message"
  git push origin $master_branch
  echo "Changes pushed to master branch."
else
  echo "No changes to push to master branch."
fi

# Update gh-pages branch with the latest from master
git checkout $pages_branch
git checkout $master_branch -- .
git add .
git commit -m "Update gh-pages from master"

# Prompt for force push
read -p "Do you want to force push to gh-pages? (y/n): " force_push_answer
if [[ "$force_push_answer" == "y" ]]; then
  echo "Force pushing to gh-pages..."
  git push origin $pages_branch --force
  echo "Force push completed."
else
  echo "Pushing to gh-pages..."
  git push origin $pages_branch
  echo "Push completed."
fi

# Check if the branches are identical
if git diff --quiet $master_branch $pages_branch; then
  echo "The master and gh-pages branches are identical."
else
  echo "The master and gh-pages branches are different."
fi

# Return to master branch
git checkout $master_branch
