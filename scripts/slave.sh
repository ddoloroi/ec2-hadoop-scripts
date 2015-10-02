#!/bin/bash

bold=$(tput bold)
normal=$(tput sgr0)

tag="${bold}[master]${normal} "

master=`hostname`

slave="$1"

if [ -z "$slave" ]; then
	echo "${tag}Usage: slave.sh <slave internal hostname>"
	exit 1
fi

if [ ! -f ../files/ec2.pem ]; then
	echo "${tag}EC2 private key not found!"
	echo "${tag}It must be installed at ../ec2.pem"
	exit 1
fi

echo "${tag}Hadoop slave is going to be installed on ${slave}. Press any key except Ctrl+C to confirm or press Ctrl+C to cancel."

read -n1 -s

echo "${tag}Pushing files to slave instance.. Please confirm SSH connections."

ssh -i ../files/ec2.pem "ubuntu@${slave}" "echo ${master} > ~/master"
scp -i ../files/ec2.pem slave-stage1.sh "ubuntu@${slave}:~/"
scp -i ../files/ec2.pem slave-stage2.sh "ubuntu@${slave}:~/"
scp -i ../files/ec2.pem slave-hadoop.sh "ubuntu@${slave}:~/"
scp -i ../files/ec2.pem ../files/10-disable-ipv6.conf "ubuntu@${slave}:~/"
scp -i ../files/ec2.pem ../files/bashrc "ubuntu@${slave}:~/"
scp -r -i ../files/ec2.pem ../keys "ubuntu@${slave}:~/"

echo "${tag}Installing Hadoop on slave instance.."

ssh -i ../files/ec2.pem "ubuntu@${slave}" "chmod +x ~/*.sh"
ssh -i ../files/ec2.pem "ubuntu@${slave}" "bash ~/slave-stage1.sh"

echo $slave >> /home/hadoopuser/hadoop/etc/hadoop/slaves

echo "${tag}Installation completed. Please restart DFS and YARN."