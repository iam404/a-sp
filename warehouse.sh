#!/bin/bash
echo $(tput setaf 4)"Starting Deployment of warehouse on Docker container"$(tput sgr0)
echo $(tput setaf 4)"Logs are dumped on /var/log/deploy.log"$(tput sgr0)


touch /var/log/deploy.log
readonly ee_linux_distro=$(lsb_release -i | awk '{print $3}')

function install_docker()
{

dpkg --get-selections | grep -v deinstall | grep docker-engine

if [[ $? -ne 0 ]]; then

	if [ "$ee_linux_distro" == "Ubuntu" ]; then
		echo $(tput setaf 4)"Adding docker repository"$(tput sgr0)
		sudo apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D &>> /var/log/deploy.log
		echo deb https://apt.dockerproject.org/repo ubuntu-trusty main >> /etc/apt/sources.list.d/docker.list
		echo $(tput setaf 4)"Please wait while ..Updating apt-cache"$(tput sgr0)
		sudo apt-get update &>> /var/log/deploy.log
		echo $(tput setaf 4)"Please wait while Installing Docker dependencies"$(tput sgr0)
		sudo apt-get install -y apt-transport-https ca-certificates &>> /var/log/deploy.log
		echo $(tput setaf 4)"Please wait while Installing docker engine"$(tput sgr0)
		sudo apt-get install -y docker-engine &>> /var/log/deploy.log
		echo $(tput setaf 4)"Restarting Docker services"$(tput sgr0)
		sudo service docker restart &>> /dev/null
	else
 		echo "Sorry Docker installation not supported by this script. Please install Docker manually. Refer. https://docs.docker.com/engine/installation/linux/ubuntulinux/ "
		exit 100
	fi

fi
}


install_docker

if [ -d /tmp/warehouse ]
then
	rm -rf /tmp/warehouse
fi
echo $(tput setaf 4)"Clonning warehouse source code"$(tput sgr0)
cd /tmp; git clone https://github.com/ShoppinPal/warehouse.git warehouse  &>> /var/log/deploy.log

cd /tmp/warehouse

wget -c https://raw.githubusercontent.com/iam404/a-sp/master/Dockerfile &>> /var/log/deploy.log
wget -c https://raw.githubusercontent.com/iam404/a-sp/master/run.sh &>> /var/log/deploy.log

echo $(tput setaf 4)"Please wait while docker image is building. It may take few minute to complete."$(tput sgr0)
sudo docker build -t warehouse/docker . &>> /var/log/deploy.log || echo "Image building failed. Check log /var/log/deploy.log "

echo $(tput setaf 4)"Creating Docker Container from build"$(tput sgr0)
CID=$(sudo docker run -d --name warehouse warehouse/docker)
sleep 5
CIP=$(sudo docker inspect --format '{{ .NetworkSettings.IPAddress }}' $CID )

echo $(tput setaf 4)"Application deployed."$(tput sgr0)
echo $(tput setaf 4)"Check on your browser http://$CIP:3000"$(tput sgr0)
