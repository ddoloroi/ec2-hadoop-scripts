#!/bin/bash

tag="[slave-hduser] "

cd ~/

master=$(cat ./files/master)

echo "${tag}Installing Hadoop.."

chmod 600 ~/.ssh/id_rsa

rm -rf hadoop*
scp -o StrictHostKeyChecking=no $master:/home/hadoopuser/hadoop.tar.gz ./
tar xf hadoop.tar.gz
mv hadoop-2.7.1 hadoop
rm hadoop.tar.gz
mkdir -pv ~/hadoop/data/hdfs/{namenode,datanode}

echo "${tag}Copying configuration files.."

cd ~/files/
cat bashrc >> ~/.bashrc
cd ~/hadoop/etc/hadoop/
scp $master:~/hadoop/etc/hadoop/hadoop-env.sh ./
scp $master:~/hadoop/etc/hadoop/core-site.xml ./
scp $master:~/hadoop/etc/hadoop/hdfs-site.xml ./
scp $master:~/hadoop/etc/hadoop/yarn-site.xml ./