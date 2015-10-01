#!/bin/bash

bold=$(tput bold)
normal=$(tput sgr0)

tag="${bold}[master-hduser]${normal} "

echo "${tag}Generating SSH key pair.."

ssh-keygen -q -t rsa -P ""
cp /home/hadoopuser/.ssh/{id_rsa.pub,authorized_keys}
chmod 600 /home/hadoopuser/.ssh/authorized_keys

echo "${tag}Installing Hadoop.."

cd ~/
rm -rf hadoop*
wget http://apache.stu.edu.tw/hadoop/core/hadoop-2.7.1/hadoop-2.7.1.tar.gz -O hadoop.tar.gz
tar xf hadoop.tar.gz
mv hadoop-2.7.1 hadoop
mkdir -pv ~/hadoop/data/hdfs/{namenode,datanode}

echo "${tag}Copying configuration files.."

cd ~/files/
cat bashrc >> ~/.bashrc
cp hadoop-env.sh ~/hadoop/etc/hadoop/
cp *.xml ~/hadoop/etc/hadoop/
echo $(hostname) > ~/hadoop/etc/hadoop/slaves

source bashrc

echo "${tag}Formatting HDFS.."

hdfs namenode -format