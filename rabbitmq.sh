#!/bin/bash

START_TIME=$(date +%s)
USERID=$(id -u)
LOGS_FOLDER="/var/log/shellroboshop-log"
SCRIPT_NAME=$(echo $0 | cut -d "." -f1)
LOG_FILE="$LOGS_FOLDER/$SCRIPT_NAME.log"
SCRIPT_DIRCT=$PWD

mkdir -p $LOGS_FOLDER

if [ $USER_ID -ne 0 ]
then 
    echo "login to root user and try again" | tee -a $LOG_FILE
    exit 1
else
    echo "you are a root user" | tee -a $LOG_FILE
fi

echo "Please enter root password to setup"
read -s MYSQL_ROOT_PASSWORD

VALIDATE(){
    if [ $1 -eq 0 ]
    then    
        echo "the $2 is SUCCCES..." | tee -a $LOG_FILE
    else
        echo "the $2 is FAILED....." | tee -a $LOG_FILE
    fi
}

cp $SCRIPT_DIRCT/rabbitmq.repo /etc/yum.repos.d/rabbitmq.repo
VALIDATE $? "COPYING THE FILE"

dnf install rabbitmq-server -y
VALIDATE $? "INSTALLING RABBITMQ"

systemctl enable rabbitmq-server
VALIDATE $? "ENABLING RABBITMQ"

systemctl start rabbitmq-server
VALIDATE $? "STARTING RABBITMQ"




























END_DATE=$(date +%s)
TIME=$(($END_DATE - $START_TIME))
echo "$TIME"