#!/usr/bin/env bash

set -e

image_name=$1
version=$2

# latest is not a valid helm version
if [[ $version != "latest" ]]
then
  yq e '.version = "'"${version}"'"' -i Chart.yaml
  yq e '.appVersion = "'"${version}"'"' -i Chart.yaml
fi

# replace image tag for service charts
if ! [[ $(yq e '.service-base-chart.image.tag' values.yaml) =~ (null|false) ]]
then
  yq e '.service-base-chart.image.tag = "'"${version}"'"' -i values.yaml
fi

# replace image tag for cronjob charts
if ! [[ $(yq e '.cronjob-base-chart.image.tag' values.yaml) =~ (null|false) ]]
then
  yq e '.cronjob-base-chart.image.tag = "'"${version}"'"' -i values.yaml
fi

# replace image tag for integration tests chart
if ! [[ $(yq e '.container.image' values.yaml) =~ (null|false) ]]
then
  yq e '.image = "'"${image_name}:${version}"'"' -i values.yaml
fi

# replace image tag for base helm chart
if ! [[ $(yq e '.image.tag' values.yaml) =~ (null|false) ]]
then
  yq e '.image.tag = "'"${version}"'"' -i values.yaml
fi
