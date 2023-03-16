#!/bin/bash

SCRIPT_DIR=$(cd $(dirname "$0"); pwd -P)

source "${SCRIPT_DIR}/helper-functions.sh"

if [[ -z "${NAMESPACE}" ]]; then
  echo "NAMESPACE not set" &>2
  exit 1
fi

if [[ -z "${SECRET_NAME}" ]]; then
  echo "SECRET_NAME not set" &>2
  exit 1
fi

set -ex

CURRENT_NAMESPACE=$(oc project -q)

# wait for secret
check_k8s_resource "${CURRENT_NAMESPACE}" secret "${SECRET_NAME}" || exit 1

# wait for namespace
check_k8s_namespace "${NAMESPACE}" || exit 1

oc get secret "${SECRET_NAME}" -o json | \
  jq --arg NS "${NAMESPACE}" '{"apiVersion":.apiVersion,"type":.type,"kind":.kind,"metadata":{"name":.metadata.name,"namespace":$NS},"data":.data}' | \
  oc apply -f -
