#!/usr/bin/env bash

org_name="liangzr"
repo_name="test_github_workflow"

info() {
  printf "[Pipcook] %s\\n" "$@"
}

fatal() {
  printf "[Pipcook] Fatal Error: %s\\n" "$@"
  exit 1
}

check() {
  if [ $? -ne 0 ]; then
    fatal "Verification failed."
  fi
}

# Get the tag of triggering event
#
# The tag must be in a format like `v1.1.0`, otherwise
# will use `latest` instead
function get_version() {
  local ref_tag
  local version

  # makes v1.1.0 becomes 1.10
  ref_tag=${GITHUB_REF:10}

  if [[ "${ref_tag}" == v* ]]; then
    version="${ref_tag:1}"
  else
    version="latest"
  fi

  echo "${version}"
}

function build() {
  local tag

  tag="$1"

  info "Building ${tag}..."

  if ! docker build -t "${IMAGE_NAME}:${tag}" --build-arg "VER=${tag}" "docker"; then
    fatal "Build of ${tag} failed!"
  fi

  info "Build of ${tag} succeeded."
}

function test_image() {
  local tag
  local output

  tag="$1"

  info "Testing ${tag}..."
  cli_version=$(docker run --rm ${IMAGE_NAME}:${tag} pipcook -v | sed -n "1,1p" | awk '{print $3}')
  [[ $status -eq 0 ]]
  check
  [[ "${cli_version:1}" == "$tag" ]]
  check

  info "Testing succeeded."
}

IMAGE_NAME="${org_name}/${repo_name}"

version=$(get_version)

if [[ -s "docker/Dockerfile" ]]; then
  build "${version}"
  # test_image "${version}"
else
  fatal "Dockerfile not exists."
fi

exit 0
