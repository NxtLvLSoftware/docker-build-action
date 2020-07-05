# docker-build-action
The source for the docker-build github action.

## About
This repository contains the source code for the docker-build action that allows you to easily build & tag a docker image
using the actions pipeline.

## Usage

### Action Inputs
| Input             | Description                                                             |
| ----------------- | ----------------------------------------------------------------------- |
| path              | The path to the Dockerfile to build.                                    |
| name              | The docker image name.                                                  |
| tag               | The docker image tag name.                                              |
| extra_args        | Extra arguments to pass to the docker build command.                    |
| registry_username | The docker registry username for the account to publish the image from. |
| registry_password | The docker registry password for the account to publish the image from. |
| registry_uri      | The docker registry uri for the account to publish the image from.      |
| pull              | Should we pull existing images before the build to speed up the build?  |


### Workflow Examples
This example builds & publishes an image from the Dockerfile in the root of a repo and publishes it to GitHub packages.

```yaml
name: ci

on:
  release:
    types: [published]

jobs:
  sync-downstream:

    runs-on: ubuntu-latest

    name: Build & publish image

    steps:
      - uses: actions/checkout@v2
        with:
          fetch-depth: 0
      - uses: nxtlvlsoftware/docker-build@1.0.0
        with:
          name: docker.pkg.github.com/nxtlvlsoftware/repo/image-name
          tag: ${{ github.event.release.tag_name }}
          registery_username: ${{ secrets.DOCKER_USERNAME }}
          registery_password: ${{ secrets.DOCKER_PASSWORD }}
          registery_uri: ${{ secrets.DOCKER_REGISTRY }}
```
