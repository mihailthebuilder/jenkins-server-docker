# Jenkins Local Server in Docker

Followed [this guide](https://www.jenkins.io/doc/book/installing/docker/#setup-wizard). This was set up for Windows, but there's a guide for Linux as well.

# Installation

**Open the command prompt.**

Create bridge network in Docker:

```
docker network create jenkins
```

This might've been created already, you can check for it with this command:
```
docker network ls
```

Run the Docker-in-Docker image ([see notes](#about-docker-in-docker-dind) for more):
```
dind.bat
```

Build docker image for Jenkins server from the `Dockerfile`:
```
docker build -t myjenkins-blueocean:2.319.3-1 .
```

Run above image as container:
```
jenkins.bat
```

Now we need to set up an SSH connection from the Jenkins server container to your GitHub account. First we CLI into your container:
```
docker exec -it jenkins-blueocean bash
```

Check if you have an SSH key:
```
ls -al ~/.ssh
```

If you do, skip to adding the key to your GitHub account. If not, generate the key:
```
ssh-keygen -t ed25519 -C "your_email@example.com"
```

Add SSH key to ssh-agent:
```
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_ed25519
```

Add SSH key to GitHub account - here's [the official guide](https://docs.github.com/en/authentication/connecting-to-github-with-ssh/adding-a-new-ssh-key-to-your-github-account)

Test your SSH connection:
```
ssh -T git@github.com
```

You'll probably see a warning; check the SSH key fingerprint matches that of [GitHub's](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/githubs-ssh-key-fingerprints), then enter `yes`. You should now get a successful-authentication message. 

When setting up the pipeline, add the remote repo as a source using the `Git` option without any credentials.

# Starting after installation

After you've installed the server, the next time all you need to do is run these 2 files:
```
dind.bat
jenkins.bat
```

# Notes

## If you lose your admin password

Easiest way is to remove all containers and volumes related to the server and start afresh. In Windows, you can do that from the Docker GUI.

## About Docker-in-Docker (DinD)

This is [a reason](https://itnext.io/docker-in-docker-521958d34efd) given for using DinD, but I don't fully understand it yet:

> In Jenkins, all the commands in the stages of your pipeline are executed on the agent that you specify. This agent can be a Docker container. So, if one of your commands, for example, in the Build stage, is a Docker command (for example, for building an image), then you have the case that you need to run a Docker command within a Docker container.
>
> Furthermore, Jenkins itself can be run as a Docker container. If you use a Docker agent, you would start this Docker container from within the Jenkins Docker container. If you also have Docker commands in your Jenkins pipeline, then you would have three levels of nested “Dockers”.
>
> However, with the above approach, all these Dockers use one and the same Docker daemon, and all the difficulties of multiple daemons (in this case three) on the same system, that would otherwise occur, are bypassed.

Apparently it's [not safe](https://jpetazzo.github.io/2015/09/03/do-not-use-docker-in-docker-for-ci/) and you should use Docker sockets.