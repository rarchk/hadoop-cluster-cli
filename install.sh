#!/bin/bash

# This is an automated script for installing apache hadoop on node
# 
#
# Author: Ronak Kogta
# Created: Aug 26, 2014
#
# 

# The directory at which hadoop will be installed.
# Installation Process Output Log File

LOG_FILE=output-$(date +%Y%m%d-%H%M%S).log

#==================================================================================================
#==================================================================================================
# Do not edit below this line
#==================================================================================================
#==================================================================================================


# Mark current directory
SCRIPT_DIR=$(pwd)

#==================================================================================================
# Checking if this script is executed with root privileges.
if [[ "$(whoami)" != "root" ]]; then
	echo "Error: should be run with root priviledges. Abort."
	exit 2;
fi
#==================================================================================================
# Creating Hadoop-Installation Dedicated user

#------------------------------------------------------------------------------------
# Check if group exists. If not, create it.
if [ -z "$HADOOP_GROUP" ]
then
	echo "Warning: No group not specified."  > /dev/stderr
else
	echo -ne "- Adding new group '${HADOOP_GROUP}'...\t"
	
	# Check if the hadoop-installation-user group exists.
	if [ $(grep -c "^${HADOOP_GROUP}" /etc/group) -eq 0 ]; 
	then
		# If the group does not exist, create it.
		groupadd ${HADOOP_GROUP} > /dev/null 2>&1;
  		if [ $? -eq 0 ]; then echo "OK"; else echo "FAIL"; echo "Abort."; exit 2; fi
  	else
  		echo "OK (Exists)"
  	fi
fi

#-------------------------------------------------------------------------------
# Checking if user already exists. If not, create and add in group.
if [ $(grep -c "^${HADOOP_USER}" /etc/passwd) -gt 0 ];
then
	# If user already exists, use existing user as the dedicated hadoop installation user.
	#deluser ${HADOOP_USER}  > /dev/null 2>&1
	echo "Warning: username for hadoop installation user already exists."
	echo "         Existing user will be used."
else
	# If user does not exist, create a new user to be used as the dedicated hadoop installation user.
	echo -ne "- Adding new user '${HADOOP_USER}'... \t"
	if [ ${HADOOP_USER_ENABLE_LOGIN} -eq 0 ]
	then
		useradd ${HADOOP_USER} --gecos ${HADOOP_USER} --ingroup ${HADOOP_GROUP} --disabled-password > /dev/null 2>&1
		if [ $? -eq 0 ]; then echo "OK"; else echo "FAIL"; echo "Abort1."; exit 2; fi
	else
		useradd ${HADOOP_USER} --gecos ${HADOOP_USER} --ingroup ${HADOOP_GROUP}
		if [ $? -eq 0 ]; then echo "OK"; else echo "FAIL"; echo "Abort2."; exit 2; fi
	fi
	
fi

#-------------------------------------------------------------------------------
# Add hadoop dedicated user to sudoers (no password)

usermod -a -G admin ${HADOOP_USER}
echo -ne "- Adding ${HADOOP_USER} to sudoers (no password)...\t"
if [ $(grep --count -e "^[ ]*${HADOOP_USER} [ ]*ALL=(ALL) [ ]*NOPASSWD:ALL" /etc/sudoers) -gt 0 ]
then
	echo "(Already added)"
else
	echo "${HADOOP_USER} ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers
	if [ $? -eq 0 ]; then echo "OK"; else echo "FAIL"; fi
fi

#==================================================================================================
# Generating SSH key for the dedicated hadoop installation user.

#-------------------------------------------------------------------------------
#  Create an RSA key pair with an empty password. 

echo -ne "- Generating a new public ssh-key for the dedicated user...\t"
if [ ! -e "/home/$HADOOP_USER/.ssh/id_rsa" ]
then
	# Empty password is required so that the key can be unlocked without interaction.
	sudo -u $HADOOP_USER rm -f "/home/$HADOOP_USER/.ssh/id_rsa"
	sudo -u $HADOOP_USER ssh-keygen -q -t rsa -P "" -f "/home/$HADOOP_USER/.ssh/id_rsa"
	if [ $? -ne 0 ]; then echo "FAIL"; else echo "OK"; fi
else
	echo ""
	echo -e "Warning:"
	echo -e "\tFile /home/$HADOOP_USER/.ssh/id_rsa exists."
	echo -e "\tNew key not generated. Using existing key."
	echo -e "\tIf key is not passwordless, execute the following commands:"
	echo "------------------------------------------"
	echo -e "\tsudo -u $HADOOP_USER ssh-keygen -q -t rsa -P \"\" -f \"/home/$HADOOP_USER/.ssh/id_rsa\""
	echo -e "\tsudo -u $HADOOP_USER cat /home/$HADOOP_USER/.ssh/id_rsa.pub >> /home/$HADOOP_USER/.ssh/authorized_keys"
	echo "------------------------------------------"
fi

#-------------------------------------------------------------------------------
# Add the generated key to the authorized keys to enable SSH access 
# to the localhost with this newly created key.
echo -ne "- Adding public key to authorized keys...\t"

if [ -e "/home/$HADOOP_USER/.ssh/authorized_keys" ] && [ $(grep --count -f /home/$HADOOP_USER/.ssh/id_rsa.pub /home/$HADOOP_USER/.ssh/authorized_keys) -gt 0 ]
then
	echo "(Already added.)"
else
	sudo -u $HADOOP_USER cat /home/$HADOOP_USER/.ssh/id_rsa.pub >> /home/$HADOOP_USER/.ssh/authorized_keys
	if [ $? -ne 0 ]; then echo "FAIL"; else echo "OK"; fi
fi
#-------------------------------------------------------------------------------
# Modify the owner of the ssh directory and authorized_keys file
echo -ne "- Modifying ownershipf of '.ssh'...\t"
chown ${HADOOP_USER}:${HADOOP_GROUP} /home/${HADOOP_USER}/.ssh
if [ $? -ne 0 ]; then echo "FAIL"; else echo "OK"; fi

echo -ne "- Modifying ownershipf of '.ssh/authorized_keys'...\t"
chown ${HADOOP_USER}:${HADOOP_GROUP} /home/${HADOOP_USER}/.ssh/authorized_keys
if [ $? -ne 0 ]; then echo "FAIL"; else echo "OK"; fi

#-------------------------------------------------------------------------------
# Attempt to establish an ssh connection to the localhost in order to accept the Authentication key
echo -ne "- Test ssh to localhost...\t"
sudo -u $HADOOP_USER ssh -o StrictHostKeyChecking=no localhost ' ' >> ${SCRIPT_DIR}/${LOG_FILE} 2>&1 # just try to connect. but do nothing
if [ $? -ne 0 ]; then echo "FAIL"; else echo "OK"; fi

