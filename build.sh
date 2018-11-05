#!/bin/bash


function image_clean {

	docker volume rm $(docker volume ls -qf dangling=true)
	#docker network rm $(docker network ls | grep "bridge" | awk '/ / { print $1 }')
	docker rmi $(docker images --filter "dangling=true" -q --no-trunc)
	docker rmi $(docker images | grep "none" | awk '/ / { print $3 }')
	docker rm $(docker ps -qa --no-trunc --filter "status=exited")
}

docker build --rm -t local/ovs-dashboard ./
image_clean 2> /dev/null
