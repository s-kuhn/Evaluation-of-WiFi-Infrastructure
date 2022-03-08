# Performance Evaluation of WIFI-Infrastructure in Classroomsituations

## Table of Contents

1. [Problem](#problem)
2. [Requirements](#requirements)
3. [Approach](#approach)
4. [Installation](#installation)
   - [Setting up clients](#setting-up-clients)
   - [Setting up docker host](#setting-up-docker-host)
   - [Command to start](#command-to-start)
5. [Modifing Playbooks](#modifing-playbooks)
   - [Strategy](#strategy)
   - [Async](#async)
   - [Timeout](#timeout)
   - [Conditions](#conditions)
   - [Loop](#loop)
   - [Using other files](#using-other-files)

## Problem
https://ieeexplore.ieee.org/document/7098698

## Requirements
- Ubuntu
- [Docker](https://docs.docker.com/engine/install/ubuntu/ "Install Docker")
- [Compose](https://docs.docker.com/compose/install/#install-compose-on-linux-systems "Install Docker-Compose")
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

## Installation

### Setting up clients:
Here done with raspberrry pi's. Install a premodified image with hostname, wifi, ssh and timezone already set up:

Connect the pi via ethernet to the management network.


### Setting up docker host:

Docker Engine:
```
sudo apt install git -y
```

```
sudo apt-get update
```

```
sudo apt-get install \
    ca-certificates \
    curl \
    gnupg \
    lsb-release -y
```

```
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
```

```
echo \
"deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
$(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
```

```
sudo apt-get update
```

```
sudo apt-get install docker-ce docker-ce-cli containerd.io -y
```

```
sudo usermod -aG docker $USER
```
restart vm or
```
sudo service docker restart
```

Docker Compose:
```
sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
```

```
sudo chmod +x /usr/local/bin/docker-compose
```

Clone Repo:
```
git clone https://github.com/s-kuhn/projektarbeit.git
```

Replace IP-adresses in following files (xxx.xxx.xxx.xxx for management-subnet, xxx.xxx.yyy.xxx for test-subnet):
- [docker-compose.yml](./elk/docker-compose.yml) line 59, 95 and 96
- [config.yml](./Playbooks/config.yml)
- [hosts](./hosts)
- [deploy_shh_keys.sh](./deploy_ssh_key.sh) in array and line 34

Change into compose directory:
```
cd projektarbeit/elk/
```

Build compose:
```
docker-compose build
```

Start containers first time:
```
docker-compose up
```

Restart containers:
```
docker-compose stop
```
or ctrl + c

```
docker-compose up
```

Wait for ca. 10 min
http://localhost:5601

Reset passwords with (optional):
```
docker-compose exec elasticsearch bin/elasticsearch-reset-password --batch --user elastic
```
Insert into [.env](./elk/.env) line 10

```
docker-compose exec elasticsearch bin/elasticsearch-reset-password --batch --user kibana_system
```
Insert into [.env](./elk/.env) line 22

```
docker-compose up -d logstash kibana
```

Load sample data (i.e. Sample web logs).

Import Dashboard from `elk/kibana`:

https://support.logz.io/hc/en-us/articles/210207225-How-can-I-export-import-Dashboards-Searches-and-Visualizations-from-my-own-Kibana-

Click on Dashboard and choose 1.

Download big files:

- https://drive.google.com/file/d/1At2KMUSX5Cu0cCx32GeFOiiiqeXKtxPp/view?usp=sharing
- https://drive.google.com/file/d/1LZGUo8R7O6uCAEFLdsMVamIbwQEImjhf/view?usp=sharing

### Command to start

```
docker exec -it ansible /bin/bash
```

```
./deploy_ssh_key.sh raspberry
```

```
command time ansible-playbook Playbooks/case1.yml -i hosts
```
```
command time ansible-playbook Playbooks/case2.yml -i hosts
```
```
command time ansible-playbook Playbooks/case3.yml -i hosts
```

Depending on how many Clients you have you need to adjust the graphs:
- Change into edit mode
- Click on the gear button and choose edit lens
- Click into the data by what the lens is broke down and adjust the number of values to the number of clients

![image](https://user-images.githubusercontent.com/62448107/157236256-c349eb2c-54fe-4280-a743-dbf365fa4c6b.png)
![image](https://user-images.githubusercontent.com/62448107/157236099-3e843b96-861e-433f-b8c6-16a6a2d7dfd2.png)

## Modifing Playbooks

The actual traffic generating happens in the last task of each playbook. The get-random.yml makes the clients wait for a random time of seconds between 5 and 10 befor starting the actual tasks. This is done so the clients have a more realistic behavior an can easily be adjustied in the file.

### Strategy
All playbooks run in free strategy that means that if a client has finished a task befor another clients he doesn't has to wait for all to finish but continues with the next task.

### Async
Some task have a attribut `async` an `poll`:
> If you want to run multiple tasks in a playbook concurrently, use async with poll set to 0. When you set poll: 0, Ansible starts the task and immediately moves on to the next task without waiting for a result. Each async task runs until it either completes, fails or times out (runs longer than its async value). The playbook run ends without checking back on async tasks.

### Timeout
Others may have a attribut `wait_for` with `timeout`. the number afert timeout ist the amout of seconds the task waits befor continuing with the next.

### Conditions
In case2 I use the contition `when` and ask if a client is in a specific inventory group. If that contiotion is true the task will run else it is skippped. The groups are initialiced in the `hosts` file in the "[]" brackets.

### Loop
Some tasks are run multiple time. That is done with the attribut `with_sequence`. The variable `count` contains the amount of times the rask is run.

### Using other files
Last thing you may like to adjust is the files to generate the network traffic. For that you need to change the url in the corresponding task.
