#!/usr/bin/env bash
set -e

# The implementation to sync (e.g., "ruby", "mruby"). Defaults to "ruby".
# This is passed as the first argument to this script.
IMPLEMENTATION=${1:-ruby}
# The GitHub repository to check for releases.
# This is hardcoded for now, as different implementations have different release pages.
GITHUB_REPO="ruby/ruby"

echo "Syncing implementation: $IMPLEMENTATION"
echo "Fetching from GitHub repo: $GITHUB_REPO"

# Abort if the required versions file doesn't exist.
if [ ! -f "$IMPLEMENTATION/versions.txt" ]; then
    echo "Error: $IMPLEMENTATION/versions.txt not found. Aborting."
    exit 1
fi

echo "Fetching latest stable releases from $GITHUB_REPO..."
all_stable_tags=$(curl -sL "https://api.github.com/repos/$GITHUB_REPO/releases?per_page=100" | jq -r '.[] | select(.prerelease | not) | .tag_name')

formatted_versions=$(echo "$all_stable_tags" | sed 's/^v//;s/_/./g')

echo "Checking for missing versions and processing immediately..."
versions_added=""

while IFS= read -r version; do
    clean_version=$(echo "$version" | sed 's/\\n//g' | tr -d '\n\r' | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')

    if [ -z "$clean_version" ]; then
        continue
    fi

    if ! grep -Fxq "$clean_version" "$IMPLEMENTATION/versions.txt"; then
        echo "--------------------------------------------------"
        echo "Processing new version for '$IMPLEMENTATION': '$clean_version'"
        echo "--------------------------------------------------"
        
        ./update.sh "$IMPLEMENTATION" "$clean_version"

        if [ -z "$versions_added" ]; then
            versions_added="$clean_version"
        else
            versions_added="$versions_added, $clean_version"
        fi
    fi
done <<< "$formatted_versions"

if [ -n "$GITHUB_OUTPUT" ]; then
    echo "added_versions=${versions_added}" >> $GITHUB_OUTPUT
fi

if [ -z "$versions_added" ]; then
    echo "All stable $IMPLEMENTATION releases are already up-to-date."
else
    echo "Sync complete. Added versions for $IMPLEMENTATION: $versions_added"
fi