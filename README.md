# Evaluation der Leistung von WLAN-Infrastruktur in Unterrichtssituationen

## Inhalt

## Problemstellung
https://ieeexplore.ieee.org/document/7098698

## Requirements
- Ubuntu
- Docker-compose https://docs.docker.com/engine/install/ubuntu/
- Accesspoint
- Number of Clients for Classroomszenario (ca. 30-60)
- Router with two Subnets (one for management, one for the szenario)

## Approach
Docker Compose is setting up five Containers:
- Fileserver for file to generate traffic
- Ansible controller to manage Clients
- ELK Stack consisting of Elasicsearch, Logstash and Kibana
Via Ansible the Clients are set up to complete different szenarios. There are three playbooks with different network traffic approaches.
The traffic is generated over curl-requests to the fileserver. The playbooks also start a command to monitor the wlan interface of the clients as well as the ethernet interface of the webserver.
The data is directly send to the Logstash via netcat.
The clients need to be connected to the wifi as well as the management network over ethernet
The docker host is also connected with two interfaces to both networks.

![diagramm](https://user-images.githubusercontent.com/62448107/155655469-66d681d3-ef49-4df4-8506-97caf589d30b.jpg)


### Setting up clients:
Here done with raspberrry pi's. Install a premodified image with hostname, wifi, ssh and timezone already set up: 

Connect the pi via ethernet to the management network.

### Setting up docker host:

Docker Engine:
`sudo apt install git -y`

`sudo apt-get update`

`sudo apt-get install \
    ca-certificates \
    curl \
    gnupg \
    lsb-release -y`

`curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg`

`echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null`

`sudo apt-get update`

`sudo apt-get install docker-ce docker-ce-cli containerd.io -y`

`sudo usermod -aG docker $USER`
restart vm or
`sudo service docker restart`

Docker Compose:
`sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose`

`sudo chmod +x /usr/local/bin/docker-compose`

Clone Repo:
`git clone https://github.com/s-kuhn/projektarbeit.git`

`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`

Set ipadresses following files:
- docker-compose file service: fileserver, logstash
- every playbook line 7 and 8
- Hostsfile
- deploy_shh_keys.sh array and line 34

`cd elk/`

`docker-compose build`

`docker-compose up`

Wait for ca 10 min
http://localhost:5601

if kibana not ready:
`docker-compose exec elasticsearch bin/elasticsearch-reset-password --batch --user elastic`
elk/.env line 10

`docker-compose exec elasticsearch bin/elasticsearch-reset-password --batch --user kibana_system`
elk/.env line 22

`docker-compose up -d logstash kibana`

load sample data.

Import Dashboard from elk/kibana:

https://support.logz.io/hc/en-us/articles/210207225-How-can-I-export-import-Dashboards-Searches-and-Visualizations-from-my-own-Kibana-


### Command to start

`docker exec -it ansible /bin/bash`

`./deploy_ssh_key.sh raspberry`

`command time ansible-playbook Playbooks/case1.yml -i hosts`
