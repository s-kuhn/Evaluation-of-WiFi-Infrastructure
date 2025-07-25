# Performance Evaluation of WiFi-Infrastructure in Classroom-Situations

## Table of Contents

1. [Motivation](#motivation)
2. [Requirements](#requirements)
3. [Approach](#approach)
4. [Installation](#installation)
   - [Setting up clients](#setting-up-clients)
   - [Setting up docker host](#setting-up-docker-host)
   - [Commands to start](#commands-to-start)
5. [Dependency Management](#dependency-management)
6. [Modifying Playbooks](#modifying-playbooks)
   - [Strategy](#strategy)
   - [Async](#async)
   - [Timeout](#timeout)
   - [Conditions](#conditions)
   - [Loop](#loop)
   - [Using other files](#using-other-files)

## Motivation
The main goal of this project was to create a program or package that follows the discription in the following paper:
https://ieeexplore.ieee.org/document/7098698

The implementation should not be a simulation but as realistic as possible to a real classroom situation. The intention was to find weaknesses in WiFi-protocols, so I built something that generates web traffic between a file server and several clients. One problem the paper points out is that small uplink chatter on the channel can cause big distractions on the access point and reduce the performance of large downloads. The writers of the paper performed their tests on WiFi 802.11g which is clearly prone to this problem. In my use cases I tried to recreate similar traffic using the 802.11ac protocol instead. Based on the collected data I concluded that either WiFi-ac does not have the same problem as WiFi-g or that the nubmer of clients in my tests were insufficient.

Either way, my solution has the benefit of being modular and adjustable. With a little knowledge in Logstash one clould replace the current commad for data collection with a better alternative. And thanks to Kibana you can easily adjust the resulting graphs.

## Requirements
- Ubuntu
- [Docker](https://docs.docker.com/engine/install/ubuntu/ "Install Docker")
- [Compose](https://docs.docker.com/compose/install/#install-compose-on-linux-systems "Install Docker-Compose")
- Access Point
- Number of clients for a classroom-scenario
- Router with two subnets (one for management, one for the scenario)

## Approach
Docker-Compose is setting up five containers:
- [File Server for files to generate traffic](https://github.com/mayth/go-simple-upload-server)
- Ansible-controller to manage clients
- [ELK-Stack consisting of Elasicsearch, Logstash and Kibana](https://github.com/deviantony/docker-elk)

Via Ansible the clients are set up to complete different scenarios. There are several example playbooks (scripts) with different network traffic generating approaches.
Network load is generated over curl-requests to the file server. The playbooks also start a command to monitor the WiFi interface of the clients as well as the ethernet interface of the file server.
Those logs are directly sent to the Logstash via netcat.
The clients have to be connected to the WiFi as well as the management network over ethernet. The docker host (can be natvie on the machine a virtual machine) is also connected with two interfaces to both networks.

![diagramm](https://user-images.githubusercontent.com/62448107/158077253-941cf752-3012-4c55-95e6-270cb31a105c.jpg)

## Installation

### Setting up clients:
Done here with raspberry pi's. Install a premodified image with hostname, WiFi, SSH and timezone already set up:

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
If docker is run in a VM, you will have to restart it. If docker runs on the hardware, the following command will be sufficient.
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
git clone https://github.com/s-kuhn/Evaluation-of-WiFi-Infrastructure.git
```

Replace the IP addresses in the following files (xxx.xxx.xxx.xxx for management-subnet, xxx.xxx.yyy.xxx for test-subnet):
- [docker-compose.yml](./elk/docker-compose.yml) line *59*, *95* and *96*
- [config.yml](./Playbooks/config.yml)
- [hosts](./hosts)
- [deploy_shh_keys.sh](./deploy_ssh_key.sh) in array and line *34*

Change into compose directory:
```
cd Evaluation-of-WiFi-Infrastructure/elk/
```

Build the containers with compose (depending on your bandwidth this can take several minutes):
```
docker-compose build
```

Start the containers for the first time (can be started in the background if you pass the argument `-d`):
```
docker-compose up
```
Depending on the power of the hardware you will have to wait for about 5 minutes on the first start for the stack to be started.

Restart containers with `Ctrl + c` or with the following command if run in the background:
```
docker-compose restart
```

Again depending on the power of the hardware you will have to wait for about 5 minutes for the stack to be now fully ready. If started in the foreground the logs will eventually stop to roll in.
![Screenshot 2022-03-13 231323](https://user-images.githubusercontent.com/62448107/158081455-525cfd39-8a63-48ee-b6d9-2113da7d2992.png)

Log in with user `elastic` and the password in `/elk/.env`: http://localhost:5601

(optional) If you want to reset the current passwords please follow deviantony's steps: https://github.com/deviantony/docker-elk#setting-up-user-authentication

After successful login you click on `Explore on my own` and the load sample data (i.e. Sample web logs).
![Screenshot 2022-03-13 231723](https://user-images.githubusercontent.com/62448107/158081569-66465473-1123-4f63-9855-bcfd87245588.png)
![image](https://user-images.githubusercontent.com/62448107/158081579-28022f6d-7f3b-48c6-a5d2-295eadfa7ade.png)

Now import the preconfigured dashboard from `elk/kibana`:

https://support.logz.io/hc/en-us/articles/210207225-How-can-I-export-import-Dashboards-Searches-and-Visualizations-from-my-own-Kibana-

![image](https://user-images.githubusercontent.com/62448107/158081669-f44a3717-7951-4e70-bb3f-292a66c0cdc7.png)

Click on Dashboard and select Evaluation-of-WiFi-Infrastructure.
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

Depending on how many Clients you have, you will need to adjust the graphs:
- Change into edit mode
- Click on the gear button and choose edit lens
- Click into the data by which the lens is broke down and adjust the number of values to the number of clients

![image](https://user-images.githubusercontent.com/62448107/157236256-c349eb2c-54fe-4280-a743-dbf365fa4c6b.png)
![image](https://user-images.githubusercontent.com/62448107/157236099-3e843b96-861e-433f-b8c6-16a6a2d7dfd2.png)

## Dependency Management

This project uses [Dependabot](https://docs.github.com/en/code-security/dependabot) for automated dependency management. The configuration file is located at `.github/dependabot.yml` and monitors the following dependency types:

### Docker Dependencies
- **Location**: `/elk` directory (includes `docker-compose.yml` and all Dockerfiles)
- **Components monitored**: 
  - ELK Stack (Elasticsearch, Logstash, Kibana)
  - Go file server
  - Ansible controller
  - Extension services (APM, Curator, Enterprise Search, Filebeat, etc.)
- **Update schedule**: Weekly on Monday mornings

### Go Modules
- **Location**: `/elk/fileserver` directory
- **Files monitored**: `go.mod` and `go.sum`
- **Components**: Go-based file server dependencies
- **Update schedule**: Weekly on Monday mornings

### GitHub Actions
- **Location**: Repository root (`/`)
- **Purpose**: Future-proofing for any workflow files that may be added
- **Update schedule**: Weekly on Monday mornings

### Configuration Features
- Maximum 5 open pull requests per ecosystem to prevent overwhelming
- Automatic reviewer assignment to the repository owner
- Semantic commit messages with appropriate prefixes (`docker:`, `go:`, `actions:`)
- Scheduled updates to minimize disruption to active development

Dependabot will automatically create pull requests when dependency updates are available. Review and merge these PRs to keep the project secure and up-to-date.

## Modifying Playbooks

To be more realistic some cases use the outsourced playbook `get-random.yml` which makes the clients wait for a random amount of time between 5 and 10 seconds before starting the actual tasks. This is done so the clients have a more realistic behavior and can be adjusted in the file more easily.

### Strategy
All playbooks run in *free* strategy that means that if a client has finished a task befor another clients he doesn't has to wait for all to finish but continues with the next task.

### Async
Some tasks have a attribute `async` an `poll`:
> If you want to run multiple tasks in a playbook concurrently, use *async* with *poll* set to *0*. When you set `poll: 0`, Ansible starts the task and immediately moves on to the next task without waiting for a result. Each async task runs until it either completes, fails or times out (runs longer than its async value). The playbook run ends without checking back on async tasks.

### Timeout
Others may have an attribute `wait_for` with `timeout`. The number after timeout is the amount of seconds a task will wait before continuing with the next one.

### Conditions
In case2 I use the condition `when` and ask if a client is in a specific inventory group. If that condition is true, the task will run otherwise it is skipped. The groups are initialized in the `hosts` file in the "[ ]" brackets.

### Loop
Some tasks are run multiple times. That is done with the attribute `with_sequence`. The variable `count` contains the amount of times the task is run.

### Using other files
The final thing you may like to adjust is with which files the network traffic is generated. For that you need to change the URL in the corresponding task.
