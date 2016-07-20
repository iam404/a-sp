FROM node:0.10.46
MAINTAINER Prabuddha Chakraborty <prabuddha.nike13@gmail.com>

RUN (apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y build-essential curl ruby-full git git-core libcurl4-openssl-dev libcurl3-gnutls sudo)

RUN git config --global url."https://".insteadOf git://
RUN npm install -g yo
RUN npm install -g bower grunt-cli
ADD . /src/
EXPOSE 3000
WORKDIR /src
RUN npm install
RUN bower --allow-root install
RUN rm -rf /var/lib/apt/lists/*

CMD [ "node","server/server.js" ]
