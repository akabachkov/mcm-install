#!/bin/sh

export ENTITLED_REGISTRY="cp.icr.io"
export ENTITLED_REGISTRY_USER="cp"
export ENTITLED_REGISTRY_KEY=${ENTITLED_REGISTRY_KEY:-eyJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJJQk0gTWFya2V0cGxhY2UiLCJpYXQiOjE2MDcwODIzMjYsImp0aSI6IjI5OWVkYWQyYTc1NTQyNzU4YzQ0MjY2ZTQxNjhkZDBjIn0.co_dpdChpwX3FKrp7DoPApV_yJSjO7LrnGrI80YRtJA}
export ENTITLED_REGISTRY_SECRET="ibm-management-pull-secret"
export DOCKER_EMAIL="anton.kabachkov@ibm.com"
export CP4MCM_NAMESPACE="cp4mcm"
export CP4MCM_BLOCK_STORAGECLASS="nfs-storage-provisioner"
#export CP4MCM_FILE_STORAGECLASS="ibmc-file-gold"
#export CP4MCM_FILE_GID_STORAGECLASS="ibmc-file-gold-gid"

#Create a Kubernetes Docker-registry secret in your IBM Cloud Pak for Multicloud Management namespace.
oc create secret docker-registry $ENTITLED_REGISTRY_SECRET --docker-username=$ENTITLED_REGISTRY_USER --docker-password=$ENTITLED_REGISTRY_KEY --docker-email=$DOCKER_EMAIL --docker-server=$ENTITLED_REGISTRY -n $CP4MCM_NAMESPACE


oc create -f - <<EOF
apiVersion: operators.coreos.com/v1alpha1
kind: CatalogSource
metadata:
  name: ibm-management-orchestrator
  namespace: openshift-marketplace
spec:
  displayName: IBM Management Orchestrator Catalog
  publisher: IBM
  sourceType: grpc
  image: quay.io/cp4mcm/cp4mcm-orchestrator-catalog:2.2-latest
  updateStrategy:
    registryPoll:
      interval: 45m
EOF


oc create -f - <<EOF
apiVersion: operators.coreos.com/v1alpha1
kind: CatalogSource
metadata:
  name: opencloud-operators
  namespace: openshift-marketplace
spec:
  displayName: IBMCS Operators
  publisher: IBM
  sourceType: grpc
  image: docker.io/ibmcom/ibm-common-service-catalog:3.5.6
  updateStrategy:
    registryPoll:
      interval: 45m
EOF


oc create -f - <<EOF
apiVersion: operators.coreos.com/v1alpha1
kind: Subscription
metadata:
  name: ibm-management-orchestrator
  namespace: openshift-operators
spec:
  channel: 2.2-stable
  name: ibm-management-orchestrator
  source: ibm-management-orchestrator
  sourceNamespace: openshift-marketplace
EOF


