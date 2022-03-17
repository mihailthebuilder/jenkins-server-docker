# Jenkins Local Server in Docker

Followed [this guide](https://www.jenkins.io/doc/book/installing/docker/#setup-wizard). This was set up for Windows, but there's a guide for Linux as well.
# Table of contents
- [Jenkins Local Server in Docker](#jenkins-local-server-in-docker)
- [Table of contents](#table-of-contents)
- [Installation](#installation)
  - [Launch Docker server](#launch-docker-server)
  - [Set up AWS connection](#set-up-aws-connection)
  - [Set up GitHub connection](#set-up-github-connection)
- [Starting after installation](#starting-after-installation)
- [TODO](#todo)
- [Notes](#notes)
  - [If you lose your admin password](#if-you-lose-your-admin-password)
  - [About Docker-in-Docker (DinD)](#about-docker-in-docker-dind)
# Installation

## Launch Docker server

Open the **comand prompt** and create a bridge network in Docker:

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

## Set up AWS connection

Start by copying the `aws-adfs-cli` package from your local folder into the container:
```
docker cp aws-adfs-cli/ jenkins-blueocean:/var/jenkins_home/
```

Then CLI into your container with root access:
```
docker exec -u 0 -it jenkins-blueocean bash
```

`cd` into the directory and get bash to understand the `install.sh` and `aws-adfs` scripts. Then install the AWS utility:
```
cd /var/jenkins_home/aws-adfs-cli
sed -i -e 's/\r$//' install.sh
sed -i -e 's/\r$//' aws-adfs
./install.sh
```

Now you can log into AWS with this command:
```
aws-adfs
```

But the `.aws` credentials folder gets created in the `root` directory, which the Jenkins runner doesn't have access to. So you need to copy the folder to `jenkins_home`:
```
cp -r /root/.aws /var/jenkins_home/
```

## Set up GitHub connection

We want to fetch the repo that's stored remotely on your GitHub account, so we'll need to set up an SSH connection from the Jenkins server to that account. In the container CLI, check if you have an SSH key:
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

After you've installed the server, you'll need to run these 2 files to start the server:
```
dind.bat
jenkins.bat
```

And you'll need to CLI into the Jenkins server container and log into AWS as per the [above instructions](#set-up-aws-connection).

# TODO

Figure out how to automate any of the above setups.
- I tried doing it for the [AWS install](#set-up-aws-connection) step, but I got into an error running `docker exec` command. I gave up because I only need to do it once.

Rename containers to something more easily memorable.

Figure out how to use Docker sockets - [see why](#about-docker-in-docker-dind).

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