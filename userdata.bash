#!/bin/bash
sudo apt-get update -y

sudo apt-get upgrade -y 

sudo apt-get install jenkins

sudo apt install fontconfig openjdk-17-jre -y
java -version

openjdk version "17.0.8" 2023-07-18
OpenJDK Runtime Environment (build 17.0.8+7-Debian-1deb12u1)
OpenJDK 64-Bit Server VM (build 17.0.8+7-Debian-1deb12u1, mixed mode, sharing)

sudo systemctl enable jenkins

sudo systemctl start jenkins

sudo systemctl status jenkins



