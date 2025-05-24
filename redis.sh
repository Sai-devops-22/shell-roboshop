#!/bin/bash

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

VALIDATE(){
    if [ $1 -eq 0 ]
    then    
        echo "the $2 is SUCCCES..." | tee -a $LOG_FILE
    else
        echo "the $2 is FAILED....." | tee -a $LOG_FILE
    fi
}

dnf module disable redis -y &>> $LOG_FILE
VALIDATE $? "DISABLING EXSISITING REDIS"

dnf module enable redis:7 -y &>> $LOG_FILE
VALIDATE $? "ENABLING REDIS"

dnf install redis -y &>> $LOG_FILE
VALIDATE $? "INSTALLING REDIS"

