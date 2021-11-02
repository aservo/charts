#!/bin/env bash

# exit from bash script on error
set -e

# show executed commands
set -x

export HELM_EXPERIMENTAL_OCI=1

if [ $# -ne 3 ]; then
    echo "Must specify 3 parameters"
    exit 1
fi

registry=$1
username=$2
password=$3

charts_dir="charts/"
packages_dir=".cr-release-packages/"
repository=${registry}/helm

if [ -d "$packages_dir" ]; then
    helm registry login ${registry} --username ${username} --password ${password}

    for package_path in ${packages_dir}*.tgz; do
        package=${package_path#"$packages_dir"}
        chart=${package%-*}
        ending=${package#"${chart}-"}
        version=${ending%.tgz}

        helm push ${package_path} oci://${repository}
    done
fi
