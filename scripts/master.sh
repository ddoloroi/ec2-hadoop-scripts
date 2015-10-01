#!/bin/bash

if [[ $EUID -ne 0 ]]; then
	echo "This script must be run as root" 1>&2
	exit 1
fi

bold=$(tput bold)
normal=$(tput sgr0)

tag="${bold}[master]${normal} "

master=`hostname`

echo "${tag}Please confirm that you are installing Hadoop master on this instance by pressing any key except Ctrl+C. Press Ctrl+C to cancel."

read -n1 -s

echo "${tag}Preprocessing configuration files.."
sed -i "s/MASTER/${master}/g" ../files/core-site.xml
sed -i "s/MASTER/${master}/g" ../files/mapred-site.xml
sed -i "s/MASTER/${master}/g" ../files/yarn-site.xml

echo "${tag}Disabling ipv6.."

cp ../files/10-disable-ipv6.conf /etc/sysctl.d/

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

mkdir -pv /home/hadoopuser/files/
cp master-hadoop.sh /home/hadoopuser/files/
cp ../files/bashrc /home/hadoopuser/files/
cp ../files/hadoop-env.sh /home/hadoopuser/files/
cp ../files/*.xml /home/hadoopuser/files/
chown -R hadoopuser:hadoopgroup /home/hadoopuser/files

echo "${tag}SU to Hadoop user."
su hadoopuser -c 'bash /home/hadoopuser/files/master-hadoop.sh'

echo "${tag}Grabbing Hadoop user's SSH keys."
mkdir -pv ../keys/
cat /home/hadoopuser/.ssh/id_rsa > ../keys/id_rsa
cat /home/hadoopuser/.ssh/authorized_keys > ../keys/authorized_keys

echo "${tag}Master setup completed! Please reboot and run slave setup scripts."