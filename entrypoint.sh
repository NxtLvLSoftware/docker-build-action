#!/bin/sh

set -e

if [ -z "${INPUT_REGISTRY_USERNAME}" ]; then
  echo "Username is empty. Please set the username input to login to the docker registry."
fi

if [ -z "${INPUT_REGISTRY_PASSWORD}" ]; then
  echo "Password is empty. Please set the password input to login to the docker registry."
fi

echo "${INPUT_REGISTRY_PASSWORD}" | docker login ${INPUT_REGISTRY_URI} -u ${INPUT_REGISTRY_USERNAME} --password-stdin

export DOCKER_BUILDKIT=1

EXTRA_ARGS="${INPUT_EXTRA_ARGS}"

# check if we should pull existing images to help speed up the build
if [ "${INPUT_PULL}" == "true" ]; then
	sh -c "docker pull ${INPUT_NAME}:'$INPUT_TAG'"
	EXTRA_ARGS="${EXTRA_ARGS} --cache-from ${INPUT_NAME}:'$INPUT_TAG' --build-arg BUILDKIT_INLINE_CACHE=1 "
fi

# build the base pmmp duels image
sh -c "docker build $EXTRA_ARGS -t ${INPUT_NAME}:'$INPUT_TAG' ${INPUT_PATH}"

# publish the builds to github packages docker register
sh -c "docker push ${INPUT_NAME}:'$INPUT_TAG'"
