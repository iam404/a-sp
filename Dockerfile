FROM node:0.10.46
MAINTAINER Prabuddha Chakraborty <prabuddha.nike13@gmail.com>

ENV MONGO_USER=mongodb \
  MONGO_DATA_DIR=/var/lib/mongodb \
  MONGO_LOG_DIR=/var/log/mongodb

RUN (apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y build-essential curl ruby-full git git-core libcurl4-openssl-dev libcurl3-gnutls sudo)
RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv EA312927 \
 && echo "deb http://repo.mongodb.org/apt/debian wheezy/mongodb-org/3.2 main" | sudo tee /etc/apt/sources.list.d/mongodb-org-3.2.list
 \
 && apt-get update \
 && DEBIAN_FRONTEND=noninteractive apt-get install -y mongodb-org mongodb-org-server mongodb-org-shell \
 && sed 's/^bindIp/#bindIp/' -i /etc/mongod.conf 
 
RUN git config --global url."https://".insteadOf git://
RUN npm install -g yo
RUN npm install -g bower grunt-cli
ADD . /src/
EXPOSE 3000 27017
WORKDIR /src
RUN npm install
RUN bower --allow-root install

VOLUME /var/lib/mongodb
RUN chmod +x run.sh
ENTRYPOINT ["./run.sh"]
