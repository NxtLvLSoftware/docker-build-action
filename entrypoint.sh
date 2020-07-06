#!/bin/sh

set -e

if [ -z "${INPUT_REGISTRY_USERNAME}" ] || [ "${INPUT_REGISTRY_USERNAME}" == "" ]; then
	echo "Username is empty. Please set the username input to login to the docker registry."
fi

if [ -z "${INPUT_REGISTRY_PASSWORD}" ] || [ "${INPUT_REGISTRY_PASSWORD}" == "" ]; then
	echo "Password is empty. Please set the password input to login to the docker registry."
fi

if [ -z "${INPUT_REGISTRY_URI}" ] || [ "${INPUT_REGISTRY_URI}" == "" ]; then
	echo "${INPUT_REGISTRY_PASSWORD}" | docker login -u ${INPUT_REGISTRY_USERNAME} --password-stdin
else
	echo "${INPUT_REGISTRY_PASSWORD}" | docker login ${INPUT_REGISTRY_URI} -u ${INPUT_REGISTRY_USERNAME} --password-stdin
fi

EXTRA_ARGS="${INPUT_EXTRA_ARGS}"

# check if we should pull existing images to help speed up the build
if [ ! -z "${INPUT_PULL}" ] && [ "${INPUT_PULL}" != "false" ] && [ "${INPUT_PULL}" != "" ]; then
	# if we should just pull a previous version as cache
	if [ "${INPUT_PULL}" == "true" ]; then
		INPUT_PULL="${INPUT_NAME}:'$INPUT_TAG'"
	fi

	export DOCKER_BUILDKIT=1
	sh -c "docker pull ${INPUT_PULL}"
	EXTRA_ARGS="${EXTRA_ARGS} --cache-from ${INPUT_PULL} --build-arg BUILDKIT_INLINE_CACHE=1"
fi
echo $EXTRA_ARGS
# build the image
sh -c "docker build -t ${INPUT_NAME}:'$INPUT_TAG' $EXTRA_ARGS -f ${INPUT_FILE} ${INPUT_PATH}"

# check if we should publish the builds to docker registry
if [ "${INPUT_PUSH}" == "true" ]; then
	sh -c "docker push ${INPUT_NAME}:'$INPUT_TAG'"
fi
