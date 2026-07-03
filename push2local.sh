#!/usr/bin/env bash
set -e
IMN=$1
if [ "$(echo $IMN|grep -F 192.168.13.73:5000)" ]; then
	docker push $IMN
else
    repo=$(echo $IMG|awk -F ':' '{print $1}')
    tag=$(echo $IMG|awk -F ':' '{print $2}')
	docker tag $IMN 192.168.13.73:5000/$repo-$(arch):$tag
	docker push 192.168.13.73:5000/$repo-$(arch):$tag
fi
