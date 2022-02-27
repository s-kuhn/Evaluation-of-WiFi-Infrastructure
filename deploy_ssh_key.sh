#!/bin/bash
# Script to auto.matically add our public key on a list of servers
# to remove the pain from typing each time our password
# when we want to access a server.
 
# [manual] If you want to copy your key to only one server
#   ssh-copy-id -i ~/.ssh/id_rsa.pub SERVER

echo $(ssh-keygen -q -t rsa -N '' -f /root/.ssh/id_rsa <<<y >/dev/null 2>&1) & echo "Key generated"

# Definition of the servers
SERVERS=(
  "192.168.178.31"
  "192.168.178.21"
  "192.168.178.27"
  "192.168.178.24"
  "192.168.178.25"
  "192.168.178.36"
  "192.168.178.38"
  "192.168.178.39"
  "192.168.178.40" #Fileserver
)

# Make sure we have your password
if [ -z "$1" ]; then
  echo "You must supply your password!"
  echo " ./ssh-copy-id-servers.sh 'PASSWORD'"
  exit
fi

# Export the password into an environment variable
export SSHPASS=$1
 
# Iterate over all servers
for SERVER in "${SERVERS[@]}"
do
  if [[ $SERVER == ${SERVERS[-1]} ]]; then
    echo $SERVER

    ssh-keygen -f "/root/.ssh/known_hosts" -R $SERVER

    # Copy our key the first time to allow
    sshpass -e ssh-copy-id -i ~/.ssh/id_rsa.pub -o StrictHostKeyChecking=no root@$SERVER || echo "FAILED"
     
    # Clean the .ssh folder
    ssh root@$SERVER 'rm -rf .ssh'
     
    # Add back our key, as we have remove the former authorized keys, along with the new one!
    sshpass -e ssh-copy-id -i ~/.ssh/id_rsa.pub -o StrictHostKeyChecking=no root@$SERVER || echo "FAILED"
  else
    # Echo the server name
    echo $SERVER

    ssh-keygen -f "/root/.ssh/known_hosts" -R $SERVER
     
    # Copy our key the first time to allow
    sshpass -e ssh-copy-id -i ~/.ssh/id_rsa.pub -o StrictHostKeyChecking=no pi@$SERVER || echo "FAILED"
     
    # Clean the .ssh folder
    ssh pi@$SERVER 'rm -rf .ssh'
     
    # Add back our key, as we have remove the former authorized keys, along with the new one!
    sshpass -e ssh-copy-id -i ~/.ssh/id_rsa.pub -o StrictHostKeyChecking=no pi@$SERVER || echo "FAILED"
  fi
done