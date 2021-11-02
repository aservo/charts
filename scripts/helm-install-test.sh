#!/usr/bin/env bash

# as long as the issue with the non-terminating chart-testing tool is not fixed,
# this script can take over the most basic functionality.
# see https://github.com/helm/chart-testing/issues/332

# exit from bash script on error
set -e

# show executed commands
set -x

charts_dir="charts/"
kubernetes_version=${KUBERNETES_VERSION:-default}
release_suffix="${GITHUB_SHA:-default}"
timeout=600s

chart_dirs=$1
if [[ -z $chart_dirs ]]; then
    chart_dirs=$(find $charts_dir -maxdepth 1 -type d ! -path $charts_dir -print0 | tr \\0 ',')
    chart_dirs=${chart_dirs%?} # remove last comma
fi

# configure the necessary repositories
helm repo add atlassian-data-center https://atlassian.github.io/data-center-helm-charts --force-update
helm repo add bitnami https://charts.bitnami.com/bitnami --force-update

for chart_dir in $(echo $chart_dirs | sed "s/,/ /g")
do
    chart=${chart_dir#"$charts_dir"}
    release=$(echo "$chart-$kubernetes_version-$release_suffix" | tr . - | cut -c -40)
    echo "Installing and testing chart $chart in directory $chart_dir as release $release"

    # assuming we have only umbrella charts (yet)
    product=${chart%-umbrella}

    values=()
    values+=("$product.serverId=AB0C-1D2E-FGHI-JKL3")

    if [ "$kubernetes_version" != "default" ]; then
        values+=("$product.nodeSelector.kubernetes_version=$kubernetes_version")
        values+=("postgresql.nodeSelector.kubernetes_version=$kubernetes_version")
    fi

    printf -v set "%s," "${values[@]}"
    set=${set%?} # remove last comma

    helm dependency up $chart_dir
    helm dependency build $chart_dir
    helm template $release $chart_dir --namespace $release --create-namespace --set $set
    helm install $release $chart_dir --namespace $release --create-namespace --set $set --wait --timeout $timeout
    helm test $release --namespace $release --timeout $timeout
    kubectl delete namespace $release
done
