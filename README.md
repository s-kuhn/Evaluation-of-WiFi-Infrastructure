# Performance Evaluation of WIFI-Infrastructure in Classroom-Situations

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
The prior intention to this solution was to create a program or package that does pretty much what is discriped in the folloing paper:
https://ieeexplore.ieee.org/document/7098698

So something that is not a simulation and as realistic as possible to a real classroom situation. The intention is to find weaknesses in WIFI-protocols so I build something that generates web traffic between a fileserver and several clients. One problem the paper points out is that small uplink chatter on the channel can cause big distractions on the accesspoint and reduce the performance of large downloads. The writers of the paper performed their tests on WIFI 802.11g which clearly shows this problem. I tried in my usecases to recreate that traffic but on the 802.11ac protocol. With my collected data I came to the conclution that eighter WIFI-ac does not has the same problem as WIFI-g or that I tested with not enough clients.

Eigher way I hope my solution has the benefit to be modular and adjustable. With little knowledge in Logstash you clould replace the the current commad that collects the data with something else. And thanks to Kibana you can easily adjust the resulting graphs.

## Requirements
- Ubuntu
- [Docker](https://docs.docker.com/engine/install/ubuntu/ "Install Docker")
- [Compose](https://docs.docker.com/compose/install/#install-compose-on-linux-systems "Install Docker-Compose")
- Accesspoint
- Number of clients for a classroom-scenario
- Router with two subnets (one for management, one for the scenario)

## Approach
Docker-Compose is setting up five containers:
- [Fileserver for files to generate traffic](https://github.com/mayth/go-simple-upload-server)
- Ansible-controller to manage clients
- [ELK-Stack consisting of Elasicsearch, Logstash and Kibana](https://github.com/deviantony/docker-elk)

Via Ansible the clients are set up to complete different scenarios. There are several example playbooks (scrips) with different network traffic generating approaches.
Network load is generated over curl-requests to the fileserver. The playbooks also start a command to monitor the wlan interface of the clients as well as the ethernet interface of the webserver.
Those logs are directly send to the Logstash via netcat.
The clients have to be connected to the wifi as well as the management network over ethernet. The docker host (can be navie on the machine a virtual machine) is also connected with two interfaces to both networks.

![diagramm](https://user-images.githubusercontent.com/62448107/158077253-941cf752-3012-4c55-95e6-270cb31a105c.jpg)

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
If docker is run in a VM you have to restart it. If docker runs on the hardware the following command is sufficient.
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

Clone Repository:
```
git clone https://github.com/s-kuhn/Evaluation-of-WIFI-Infrastructure.git
```

Replace IP-adresses in following files (xxx.xxx.xxx.xxx for management-subnet, xxx.xxx.yyy.xxx for test-subnet):
- [docker-compose.yml](./elk/docker-compose.yml) line 59, 95 and 96
- [config.yml](./Playbooks/config.yml)
- [hosts](./hosts)
- [deploy_shh_keys.sh](./deploy_ssh_key.sh) in array and line 34

Change into compose directory:
```
cd Evaluation-of-WIFI-Infrastructure/elk/
```

Build the containers with compose (depending on your bandwidth this can take several minutes):
```
docker-compose build
```

Start the containers for the first time (can be started in the background if you pass the argument `-d`):
```
docker-compose up
```
Depending on the power of the hardware you have to wait for about 5 minutes on the first start for the stack to be started.

Restart containers with `Ctrl + c` or with the following command if run in the background:
```
docker-compose restart
```

Again depending on the power of the hardware you have to wait for about 5 minutes for the stack to be now fully ready. If started in the forground the logs eventually stop to roll in.
![Screenshot 2022-03-13 231323](https://user-images.githubusercontent.com/62448107/158081455-525cfd39-8a63-48ee-b6d9-2113da7d2992.png)

Log in with user `elastic` and the password in `/elk/.env`: http://localhost:5601

(optional) If you want to reset the current passwords please follow deviantony's steps: https://github.com/deviantony/docker-elk#setting-up-user-authentication

After successful login you click on `Explore on my own` and the load sample data (i.e. Sample web logs).
![Screenshot 2022-03-13 231723](https://user-images.githubusercontent.com/62448107/158081569-66465473-1123-4f63-9855-bcfd87245588.png)
![image](https://user-images.githubusercontent.com/62448107/158081579-28022f6d-7f3b-48c6-a5d2-295eadfa7ade.png)

Now import the preconfigured dashboard from `elk/kibana`:

https://support.logz.io/hc/en-us/articles/210207225-How-can-I-export-import-Dashboards-Searches-and-Visualizations-from-my-own-Kibana-

![image](https://user-images.githubusercontent.com/62448107/158081669-f44a3717-7951-4e70-bb3f-292a66c0cdc7.png)

Click on Dashboard and select Evaluation-of-WIFI-Infrastructure.
![image](https://user-images.githubusercontent.com/62448107/158081757-a724481e-80a3-437e-91f4-c128e89ae304.png)

Download these large files for the playbooks to work or repace them with your own (see [Using other files](#using-other-files)):

- https://drive.google.com/file/d/1LZGUo8R7O6uCAEFLdsMVamIbwQEImjhf/view?usp=sharing
- https://drive.google.com/file/d/1At2KMUSX5Cu0cCx32GeFOiiiqeXKtxPp/view?usp=sharing

### Commands to start

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

To be more realistic some cases use the outsourced playbook `get-random.yml` which makes the clients wait for a random time of seconds between 5 and 10 befor starting the actual tasks. This is done so the clients have a more realistic behavior an can easily be adjustied in the file.

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
