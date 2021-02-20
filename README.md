# Signal Server

This guide is based on Singnal Server v3.21 and only tested on Ubuntu.


## Prerequisites
* In order to generate proper various keys, make sure you have java, openssl, make and bsdmainutils installed.

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
# Signal Android
To compile **Signal Android** should be easy, follow instruction [How-to-build-Signal-from-the-sources](https://github.com/signalapp/Signal-Android/wiki/How-to-build-Signal-from-the-sources) should get you there. If you want to trace connections between App and Server, one possible way is to replace HTTPs with HTTP and use Charles for example to see the traffics.

## Allow HTTP

1. Make a small modification from source. Please reference [replace HTTPs with HTTP](https://github.com/clhjoe/signal-installation/blob/master/use_http_only.patch)
2. Start **Charles**. Since Signal server does not allow HTTP requests, use **map remote** to map HTTP back to HTTPS. This can avoid facing SSL handshaking errors if you enable SSL proxying directly without steps 1. 