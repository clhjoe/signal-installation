# Signal Server

This guide is based on Singnal Server v3.21 and only tested on Ubuntu.


## Prerequisites

* In order to generate proper various keys, you should make sure you have java, openssl, make and bsdmainutils installed.

```
sudo apt-get install -y make bsdmainutils openssl default-jdk
```

* Make sure you have docker installed. [Install Docker Engine on Ubuntu](https://docs.docker.com/engine/install/ubuntu/)
  

## Steps for Compile and Run Signal Server

0. Clone this project to make thing happen

```
git clone https://github.com/clhjoe/signal-installation.git
```

1. Run related services
Signal server relies on AWS SQS, AWS S3, Redis, and Postgresql. Thanks to container and localstack, we can setup on our local site easily.

```
# start redis, postgresql, and Localstack services
make start-env

# create SQS queue and S3 bucket
make init-env
```

2. Download Signal Server project, compile, and generates configs

```
make build
```

3. Start Signal Server

```
make start
```
