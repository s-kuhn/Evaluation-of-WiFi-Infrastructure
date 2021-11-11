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
Per Parallel-SSH sich auf alle Clients schalten und auf diesen ein Script starten welches den Traffic vom Webserver erzeugt/simuliert.
Der Webserver ist aktuell ein nginx Docker Container:

`docker run -dp 8080:80 -v $PWD/out/:/usr/share/nginx/html nginx`

`docker exec -it a80602fc0291 /bin/bash`

### Setting up clients:
install Raspian and create ssh folder befor first boot.

WIFI: https://www.raspberrypi.com/documentation/computers/configuration.html

Change PW: `sudo passwd`

current: `raspberry`

new: `rAspberry!`

Requirements curl:

Requirements cpunetlog:

`sudo apt-get install python3`

`sudo apt-get install python3-psutil`

`sudo apt-get install python3-netifaces`

`sudo pip3 install cpunetlog`

### Command to start ssh and further commands

`parallel-ssh -h pssh-hosts -P -I < pssh-commands`

`cpunetlog -l --nics eth0 -q`

`scp -r /tmp/cpunetlog labrat@192.168.0.184:/home/labrat/Schreibtisch/log/`


Content of pssh-command:

old: 
`curl --trace-ascii dump --trace-time -O 192.168.178.19:8080/test.mp4` 

new (with cpunetlog): 
`cpunetlog -l --nics wlan0 -q &
sleep 10 &&
curl -o file 192.168.178.19:8080/test.mp4 &&
pkill -f cpunetlog`

## TODO:

- SSH Keys für einfacheren login: `ssh-copy-id -i $HOME/.ssh/id_rsa.pub pi@ip`
- monitoring / ergebnisse aufzeichnen -> cpunetlog
