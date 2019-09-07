# Workshop07 : Docker

## Instructions
* Install Docker [following the procedure for your machine](https://grafana.com/dashboards/1860)
* At the end, you can add the Nomad orchestrator [following this tutorial](https://github.com/jdxlabs/hello-nomad)
* You have cheatsheets available for [Docker](https://jdxlabs.com/notes/docker) and for [Nomad](https://jdxlabs.com/notes/nomad)

## Commands
```
cd ./Workshop07-Docker

# to build the docker image
docker build -t hello-docker -f node-app/Dockerfile node-app/.

# to run your container locally
docker run -d -p 8080:8080 --name hello-docker hello-docker

# to see informations about the container
docker ps -a
docker stats

# to have a shell access for your container
docker exec -it hello-docker sh

# to stop the container and remove the image
docker stop -t0 hello-docker
docker rm hello-docker
```
