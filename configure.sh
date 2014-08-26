#!/bin/bash

# Here, you enter the details you want to edit 
# 
#
# Author: Ronak Kogta
# Created: Aug 26, 2014
#
# 

# The directory at which hadoop will be installed.
export HADOOP_HOME=/opt/hadoop

# The username of the dedicated hadoop-installation user
export HADOOP_USER=hadoop

# If set to 0, then the user login will be disabled. You will be able to connect
# only through ssh (without password), after setting up the ssh-keys 
# appropriately. If set to any other value, then the script will require you
# to type in a password for the new user.
export HADOOP_USER_ENABLE_LOGIN=0

# The group name of the dedicated hadoop-installation user
export HADOOP_GROUP=hadoop

# Directory to be used for the hadoop file system
export HADOOP_HDFS=/app/hadooo/tmp-${HADOOP_USER}

# Name of the hadoop version you are installing (doesn't really matter)
export HADOOP_VERSION_NAME=2.4.1

# The temporary directory used to build hadoop
export HADOOP_TMP=/tmp/hadoop_build_$(date +%Y%m%d%H%M%S)

export JAVA_HOME=usr/lib/jvm/jre-1.7.0


