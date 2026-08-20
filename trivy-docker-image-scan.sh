#!/bin/bash
dockerImage=$(awk 'NR=1 {print $2}' Dockerfile)
echo $dockerImage


docker run --rm -v $WORKSPACE:/root/.chache/ aquasec/trivy:0.17.2 -q image --exit-code 0 --severity HIGH --light $dockerImage
docker run --rm -v $WORKSPACE:/root/.chache/ aquasec/trivy:0.17.2 -q image --exit-code 1 --severity CRITICAL --light $dockerImage
exit_code=$?

if [["${exit_code}" == 1 ]];
then
    echo "Image scan failed"
    exit 1
else
    echo "Image scan passed"
fi;
