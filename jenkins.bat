docker run --name jenkins-blueocean --rm --detach ^
  --network jenkins --env DOCKER_HOST=tcp://docker:2376 ^
  --env DOCKER_CERT_PATH=/certs/client --env DOCKER_TLS_VERIFY=1 ^
  --volume jenkins-data:/var/jenkins_home ^
  --volume jenkins-docker-certs:/certs/client:ro ^
  --volume aws-adfs-cli:/usr/local/bin ^
  --volume aws-adfs-cli-python-installation:/usr/local/lib ^
  --publish 30303:8080 --publish 50000:50000 ^
  myjenkins-blueocean:2.319.3-1