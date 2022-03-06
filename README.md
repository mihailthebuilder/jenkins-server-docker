# Jenkins Local Server in Docker

Followed [this guide](https://www.jenkins.io/doc/book/installing/docker/#setup-wizard)

# Instructions

Create bridge network in Docker:

```
docker network create jenkins
```

This might've been created already, you can check for it with this command:
```
docker network ls
```

Run the Docker-in-Docker (dind) image (see notes for more):
```
./dind_startup.sh
```

Build docker image for Jenkins server from the `Dockerfile`:
```
docker build -t myjenkins-blueocean:2.319.3-1 .
```

Run above image as container:
```
./jenkins_startup.sh
```

Congrats, you have the Jenkins server now started up!

# Notes

This is [a reason](https://itnext.io/docker-in-docker-521958d34efd) given for using dind, but I don't fully understand it yet:

> In Jenkins, all the commands in the stages of your pipeline are executed on the agent that you specify. This agent can be a Docker container. So, if one of your commands, for example, in the Build stage, is a Docker command (for example, for building an image), then you have the case that you need to run a Docker command within a Docker container.
>
> Furthermore, Jenkins itself can be run as a Docker container. If you use a Docker agent, you would start this Docker container from within the Jenkins Docker container. If you also have Docker commands in your Jenkins pipeline, then you would have three levels of nested “Dockers”.
>
> However, with the above approach, all these Dockers use one and the same Docker daemon, and all the difficulties of multiple daemons (in this case three) on the same system, that would otherwise occur, are bypassed.

Apparently it's [not safe](https://jpetazzo.github.io/2015/09/03/do-not-use-docker-in-docker-for-ci/) and you should use Docker sockets.


