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
docker run -dp 8080:80 -v $PWD/out/:/usr/share/nginx/html nginx
docker exec -it a80602fc0291 /bin/bash

### Connecting to wifi
https://www.raspberrypi.com/documentation/computers/configuration.html

### Command to start ssh and further commands
parallel-ssh -h pssh-hosts -P -I < pssh-commands

scp -r pi@192.168.178.22:/tmp/cpunetlog /log

scp -r pi@192.168.178.23:/tmp/cpunetlog /log

scp -r pi@192.168.178.25:/tmp/cpunetlog /log

Content of pssh-command:
curl --trace-ascii dump --trace-time -O 192.168.178.19:8080/test.mp4

7 GB iso

## TODO:
current: raspberry
new: rAspberry!
- SSH Keys für einfacheren login: ssh-copy-id -i $HOME/.ssh/id_rsa.pub pi@ip
- monitoring / ergebnisse aufzeichnen
