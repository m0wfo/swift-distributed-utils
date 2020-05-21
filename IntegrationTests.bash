#!/usr/bin/env bash

NAME=${PWD##*/}
BUILD=$(git rev-parse --short HEAD)

docker build -f Dockerfile.integration -t $NAME-integration:$BUILD .

kind get clusters | grep -q $NAME
if [ $? -eq 0 ]
then
  echo "K8s cluster '$NAME' already created, moving on"
else
  kind create cluster --name $NAME
fi

kind load docker-image $NAME-integration:$BUILD --name $NAME

cat IntegrationTests/cluster.yml | sed "s/TAGNAME/$BUILD/g" | kubectl apply -f -

kubectl rollout status deployment/integration
