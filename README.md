# Evaluation der Leistung von WLAN-Infrastruktur in Unterrichtssituationen

## Inhalt

## Problemstellung
https://ieeexplore.ieee.org/document/7098698

## Anforderung
- Webserver
- Accesspoint ac und ax
- realistische Anzahl an Clients für Hörsaalszenario (ca. 30-60)
- script um traffic zu starten (idealerweise für alle clients)

## Ansatz
Per Ansible sich auf alle Clients schalten und auf diesen ein Playbook abarbeiten, welches den Traffic vom Webserver erzeugt/simuliert.


### Setting up clients:
install Raspian and create ssh folder befor first boot.

WIFI: https://www.raspberrypi.com/documentation/computers/configuration.html

`sudo raspi-config`

### Setting up server side:

`sudo apt install git -y`

`git clone https://github.com/s-kuhn/projektarbeit.git`

`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`

Set IP in:
- docker-compose file service: fileserver
- every playbook
- Hostsfile (Clients)
- Deploy_shh_keys.sh

`cd elk/`

`docker-compose build`

`docker-compose up`


### Command to start

`docker exec -it ansible /bin/bash`

`./deploy_ssh_key.sh raspberry`

`command time ansible-playbook -v Playbooks/case1.yml -i hosts`