#!/bin/bash

if [[ $EUID -ne 0 ]]; then
	echo "This script must be run as root" 1>&2
	exit 1
fi

master=`cat ../files/master`

echo "Disabling ipv6.."

cp ../files/10-disable-ipv6.conf /etc/sysctl.d/

read -p "Installing Java, confirm if needed. Press any key to continue.." -n1 -s

add-apt-repository ppa:webupd8team/java
apt-get update
apt-get install oracle-java7-installer
update-java-alternatives -s java-7-oracle

echo "Adding Hadoop user and group, please set the password and leave others default."

addgroup hadoopgroup
adduser -ingroup hadoopgroup hadoopuser

echo "Copying pre-defined key pair.."

mkdir -pv /home/hadoopuser/.ssh
cp ../keys/id_rsa /home/hadoopuser/.ssh/
cp ../keys/authorized_keys /home/hadoopuser/.ssh/
chown -Rvf hadoopuser:hadoopgroup /home/hadoopuser/.ssh

echo "Installing Hadoop.."

su hadoopuser <<EOSU
cd ~/
rm -rf hadoop*
wget http://apache.stu.edu.tw/hadoop/core/hadoop-2.7.1/hadoop-2.7.1.tar.gz
tar xf hadoop-2.7.1.tar.gz
rm hadoop-2.7.1.tar.gz
mv hadoop{-2.7.1,}
mkdir -pv ~/hadoop/data/hdfs/{namenode,datanode}
EOSU

cat ../files/bashrc >> /home/hadoopuser/.bashrc

echo "Configuring Hadoop, confirm ssh connection if needed."
su hadoopuser <<EOSU
cd ~/hadoop/etc/hadoop/
scp $master:~/hadoop/etc/hadoop/hadoop-env.sh ./
scp $master:~/hadoop/etc/hadoop/core-site.xml ./
scp $master:~/hadoop/etc/hadoop/hdfs-site.xml ./
scp $master:~/hadoop/etc/hadoop/yarn-site.xml ./
EOSU

echo "Installation completed, please reboot the instance, modify slaves on master instance and restart DFS and YARN."
