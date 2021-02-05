#!/bin/bash
# MIT License
# Luis G. Leon Vega - 2021

# -----------------------------------------------------------------------------
# Get all the variables required
# -----------------------------------------------------------------------------
filename="$INPUT_CHANGELOG_FILENAME"
config_file="$INPUT_CONFIG_FILE"
version_file="$INPUT_VERSION_FILE"
mode_file="$INPUT_MODE_FILE"
base_branch="$INPUT_BASE_BRANCH"

# Commiter details
username="$INPUT_COMMITTER_USERNAME"
email="$INPUT_COMMITTER_EMAIL"

# Accesses
github_token=$GITHUB_TOKEN
head_ref=$GITHUB_HEAD_REF

# Get project information
source_name=$(cat $config_file | grep Source | sed 's/Source:\ //g')
if [ "$?" != "0" ]; then
  echo "Cannot get the source"
  exit -1
fi
version=$(cat $version_file)
if [ "$?" != "0" ]; then
  echo "Cannot get the version"
  exit -1
fi

if [ -f $mode_file ]; then
  mode=$(cat $mode_file)
else
  mode="unstable"
fi

# -----------------------------------------------------------------------------
# Config git
# -----------------------------------------------------------------------------
echo '::group::Checkout git repository'
git fetch --prune --unshallow origin $head_ref
echo '::endgroup::'
echo '::group::Configure git::'
git checkout $head_ref
git config user.name "$username"
git config user.email "$email"
echo '::endgroup::'


# -----------------------------------------------------------------------------
# Create the changelog
# -----------------------------------------------------------------------------
file_entry=()
function create_new_entry() {
  file_entry+=("${source_name} (${version}-1) ${mode}; urgency=medium")
  file_entry+=("")
  for line in "${commit_list[@]}";
  do
    file_entry+=("$line")
  done
  file_entry+=("")
  file_entry+=(" -- ${username} <$email> $(git log --pretty=format:"%aD" -n 1 ${base_branch}..HEAD)")
  file_entry+=("")
}

# Build the commit history as minutes for the changelog
commit_list=()
while read -r commit;
do
  commit_list+=("  * $commit")
done <<< $(git log --pretty=format:"%s" ${base_branch}..HEAD)

# Create a new file
tmp_changelog="${filename}-tmp"
create_new_entry
for line in "${file_entry[@]}";
do
  echo "$line" >> ${tmp_changelog}
done
cat ${tmp_changelog} ${filename} >> ${filename}

# -----------------------------------------------------------------------------
# Commit the changelog
# -----------------------------------------------------------------------------
echo '::group::Commit Changelog::'
git add ${filename}
git commit -m '(Changelog CI) Added Changelog'
git push -u origin $head_ref
echo '::endgroup::'
