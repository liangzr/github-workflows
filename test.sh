ver=$RELEASE_VERSION
check_pkg() {
  curl -sL "http://registry.npmjs.com/@pipcook/$1" | jq -r '.versions."'$2'".version'
}

check_image() {
  curl -sL "https://hub.docker.com/v2/repositories/pipcook/pipcook/tags/$1" | jq -r '.name'
}

if
  [ $(check_pkg pipcook-cli $ver) == $ver ] ||
    [ $(check_pkg daemon $ver) == $ver ] ||
    [ $(check_pkg pipboard $ver) == $ver ]
then
  echo ::set-env name=NPM_PUBLISHED::true
fi

if [ $(check_image $ver) == $ver ]; then
  echo ::set-env name=DOCKER_PUBLISHED::true
fi
