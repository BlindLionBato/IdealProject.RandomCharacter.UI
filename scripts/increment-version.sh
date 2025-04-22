#!/bin/bash

# Extract current version from package.json
PACKAGE_VERSION=$(jq -r '.version' package.json)
MAJOR_VERSION=$(echo $PACKAGE_VERSION | cut -d'.' -f 1)
MINOR_VERSION=$(echo $PACKAGE_VERSION | cut -d'.' -f 2)
PATCH_NUM=$(echo $PACKAGE_VERSION | cut -d'.' -f 3)
BUILD_NUM=$(echo $PACKAGE_VERSION | cut -d'.' -f 4)

# Increment or set the build number
if [ -z "${BUILD_NUM}" ]; then
  BUILD_NUM=0
fi
NEW_BUILD=$((BUILD_NUM + 1))
NEW_VERSION="${MAJOR_VERSION}.${MINOR_VERSION}.${PATCH_NUM}.${NEW_BUILD}"

# Update version in package.json and set as environment variable
jq --arg v "$NEW_VERSION" '.version = $v' package.json > package.temp.json && mv package.temp.json package.json
echo "NEW_VERSION=${NEW_VERSION}" >> $GITHUB_ENV