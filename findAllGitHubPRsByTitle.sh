# Input mapping
GH_ORG=$1
PR_TITLE=$2

# Validations
#GITHUB_TOKEN
if [ -z "$GITHUB_TOKEN" ]; then
  echo "Your GITHUB_TOKEN variable appears blank, make sure to export it into this terminal, like this"
  echo "export GITHUB_TOKEN=ghp_xxxxx"
  exit 1
fi
# Org
if [ -z "$GH_ORG" ]; then
  echo "Your GH_ORG variable appears blank, make sure to call this script with the org as your first argument, like this:"
  echo "./findAllPrsWithName YourOrgNameHere \"PR name goes here\""
  exit 1
fi
# PR Title
if [ -z "$PR_TITLE" ]; then
  echo "Your PR_TITLE variable appears blank, make sure to call this script with the repo title as your second argument, like this:"
  echo "./findAllPrsWithName YourOrgNameHere \"PR title goes here\""
  exit 1
fi

# Warn about receiving too many vars
if [ ! -z "$3" ]; then
  echo "Receiving too many arguments, you might need to quote your PR title, like this:"
  echo "./findAllPrsWithName YourOrgNameHere \"PR title goes here\""
  exit 1
fi

# GH CLI Installed
if [ $(gh --help | wc -l) -le 3 ]; then
  echo "It doesn't look like you have the GitHub CLI installed, install it here: https://cli.github.com/"
  exit 1
fi

# State search params
echo "#######"
echo "# Searching org $GH_ORG for PRs with title \"$PR_TITLE\""
echo "# If any are found, their URLs will be printed below"
echo "# These URLs can be used to interact with them, e.g.:"
echo "# (example) gh pr close https://github.com/YourOrgName/RepoName/pull/1234"
echo "#######"

# Grab all repos
org_repos=$(gh repo list $GH_ORG -L 1000 | cut -d "/" -f 2 | cut -f 1)

while IFS= read -r GH_REPO; do
    unset GITHUB_URL
    GITHUB_URL=$(curl -s \
      -H "Accept: application/vnd.github+json" \
      -H "Authorization: Bearer $GITHUB_TOKEN" \
      https://api.github.com/repos/$GH_ORG/$GH_REPO/pulls 2>&1 | jq -r ".[] | select (.title==\"$PR_TITLE\")| .html_url")
    if [ $(echo $GITHUB_URL | awk 'NF' | wc -l) -gt 0 ]; then
      echo $GITHUB_URL
    fi
done <<< "$org_repos"