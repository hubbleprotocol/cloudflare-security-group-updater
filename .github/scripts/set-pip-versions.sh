#!/usr/bin/env bash

pip_version=$(grep -m 1 'version = ' setup.cfg | tr -d '[:space:]' | cut -d'=' -f2)
build_version="${pip_version}-SNAPSHOT-$(date +%s).${GITHUB_RUN_ID}"

echo "Build version: $build_version"
echo "Release version: $pip_version"

echo "::set-output name=build_version::$build_version"
echo "::set-output name=release_version::$pip_version"
