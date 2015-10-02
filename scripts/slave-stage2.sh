#!/bin/bash

tag="[slave-stage2] "

cd /home/ubuntu

echo "${tag}Disabling ipv6.."

cp 10-disable-ipv6.conf /etc/sysctl.d/

echo "${tag}Installing Java, confirm if needed. Press any key to continue.."

read -n1 -s

add-apt-repository ppa:webupd8team/java
apt-get update
apt-get install oracle-java7-installer
update-java-alternatives -s java-7-oracle

echo "${tag}Adding Hadoop user and group, please set the password manually."

addgroup hadoopgroup
useradd -m -s /bin/bash -g hadoopgroup hadoopuser
passwd hadoopuser

echo "${tag}Copying files to Hadoop user's home."

mkdir -pv /home/hadoopuser/{.ssh,files}
cp keys/id_rsa /home/hadoopuser/.ssh/
cp keys/authorized_keys /home/hadoopuser/.ssh/
cp slave-hadoop.sh /home/hadoopuser/files/
cp bashrc /home/hadoopuser/files/
cp master /home/hadoopuser/files/
chown -R hadoopuser:hadoopgroup /home/hadoopuser/files
chown -R hadoopuser:hadoopgroup /home/hadoopuser/.ssh

echo "${tag}SU to Hadoop user."
su hadoopuser <<EOSU
bash ~/files/slave-hadoop.sh
EOSU

reboot