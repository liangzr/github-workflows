#!/usr/bin/env bash

docker_path="docker"
org_name="pipcook"
repo_name="pipcook"

fatal() {
  printf "**********\\n"
  printf "Fatal Error: %s\\n" "$@"
  printf "**********\\n"
  exit 1
}

check() {
  if [ $? -ne 0 ]; then
    fatal "Check image failed"
  fi
}

# Get the tag of triggering event
#
# The tag must be in a format like `v1.1.0`, otherwise
# will use `latest` instead
function get_version() {
  local ref_tag
  local version

  ref_tag=$(echo ${GITHUB_REF} | cut -d'/' -f3)

  if [[ ${ref_tag} == v* ]]; then
    version="${ref_tag:1}"
  else
    version="latest"
  fi

  echo "${version}"
}

function build() {
  local version
  local full_tag

  version="$1"
  full_tag=$version

  echo "Building ${version}..."

  if ! docker build -t "${NAME}:${full_tag}" --build-arg "VER=${version}" "${docker_path}"; then
    fatal "Build of ${full_tag} failed!"
  fi

  echo "Build of ${full_tag} succeeded."
}

function test_image() {
  local version
  local full_tag
  local output

  version="$1"
  full_tag="$version"

  echo "Testing ${full_tag}..."
  output=$(docker run --rm ${NAME}:${full_tag} pipcook -v | sed -n "1,1p" | awk '{print $3}' | cut -b 2-)
  [ $status -eq 0 ]
  check
  [[ $output == "$full_tag" ]]
  check

  echo "Testing succeeded."
}

function publish() {
  local full_tag

  full_tag=$1

  if ! docker push -t "${NAME}:${full_tag}" -t "${NAME}:latest"; then
    fatal "Publish of ${full_tag} failed!"
  fi

  echo "Publish of ${full_tag} succeeded."
}

NAME="${org_name}/${repo_name}"

version=$(get_version)

if [[ -s "${docker_path}/Dockerfile" ]]; then
  build "${version}"
  test_image "${version}"
  # publish "${version}"
else
  fatal "Dockerfile not exists."
fi

exit 0
