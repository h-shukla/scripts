#!/usr/bin/env bash
# Clone all public GitHub repos from a user via SSH
# Usage: ./clone_all_github_repos.sh <github_username>

set -e

USER="$1"

if [ -z "$USER" ]; then
    echo "Usage: $0 <github_username>"
    exit 1
fi

PAGE=1
while true; do
    REPOS=$(curl -s "https://api.github.com/users/$USER/repos?per_page=100&page=$PAGE" \
            | grep -o '"ssh_url": "[^"]*' \
            | cut -d '"' -f4)

    if [ -z "$REPOS" ]; then
        break
    fi

    echo "Cloning page $PAGE of repositories via SSH..."

    for REPO in $REPOS; do
        REPO_DIR=$(basename "$REPO" .git)

        if [ -d "$REPO_DIR" ]; then
            echo "Skipping $REPO_DIR — directory already exists."
            continue
        fi

        echo "Cloning $REPO"
        git clone "$REPO"
    done

    PAGE=$((PAGE + 1))
done

echo "Done."

