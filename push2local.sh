#!/usr/bin/env bash
set -e
IMN=$1
echo "image:$IMN"
if [ "$(echo $IMN|grep -F 192.168.13.73:5000)" ]; then
	docker push $IMN
else
    repo=$(echo $IMN|awk -F ':' '{print $1}')
    tag=$(echo $IMN|awk -F ':' '{print $2}')
	echo "repo: $repo"
	echo "tag: $tag"
	if [ ! "$tag" ]; then
		tag="latest"
	fi
	docker tag $IMN 192.168.13.73:5000/$repo-$(arch):$tag
	docker push 192.168.13.73:5000/$repo-$(arch):$tag
fi
