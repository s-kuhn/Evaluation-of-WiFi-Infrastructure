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

Setup Fileserver:

install go: https://golang.org/doc/install
build go-simple-upload-server: https://github.com/mayth/go-simple-upload-server
Move file to /usr/local/bin
follow: https://wiki.ubuntuusers.de/Howto/systemd_Service_Unit_Beispiel/
start server with this file with command: `go-simple-upload-server -token 123 -port 8888 -upload_limit 100000000`


### Setting up clients:
install Raspian and create ssh folder befor first boot.

WIFI: https://www.raspberrypi.com/documentation/computers/configuration.html

Change PW: `sudo passwd`

current: `raspberry`

new: `rAspberry!`

Requirements curl: usuly included


### Setting up Server and Ansible Controller

`sudo apt-get update`

`sudo apt-get upgrade -y`

`ssh-keygen`

`ssh-copy-id username@remote_host`

`python3 -V`

`sudo apt install ansible -y`

`sudo apt install git -y`

`git clone https://github.com/s-kuhn/projektarbeit.git`

`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`


### Command to start

`cd projektarbeit/ansible`

`command time ansible-playbook -v ../install_go-server.yml -i inventory -e ansible_python_interpreter=/usr/bin/python3 --ask-become-pass`

`command time ansible-playbook -v ../playbook1.yml -i inventory -e ansible_python_interpreter=/usr/bin/python3`

### TODO

- mehr variation
- pfade verallgemeinern
