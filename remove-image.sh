#!/usr/bin/env bash
echo delete $1
echo $1 | while IFS=":" read -r repoName tag
do
        echo repo:      $repoName
        echo tag:       $tag
        digest=$(curl --header "Accept: application/vnd.docker.distribution.manifest.v2+json" -I -X GET 192.168.13.73:5000/v2/$repoName/manifests/$tag|grep Docker-Content-Digest|awk '{ print $2 }')
        echo digest: $digest
        digest=$(echo "$digest"|tr -d '\r')
        echo digest: $digest
        echo
        echo
        curl -I -X DELETE 192.168.13.73:5000/v2/$repoName/manifests/$digest
        echo complete
done