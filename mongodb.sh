#!/bin/bash

START_TIME=$(date %s)
USERID=$(id -u)
LOGS_FOLDER="/var/log/shellroboshop-log"
SCRIPT_NAME=$(echo $0 | cut -d "." -f1)
LOG_FILE="$LOGS_FOLDER/$SCRIPT_NAME.log"
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

cp mongodb.repo /etc/yum.repos.d/mongo.repo 
VALIDATE $? "MONGO REPO COPYING" 

dnf install mongodb-org -y &>>$LOG_FILE
VALIDATE $? "INSTALLING MONGO SERVER" 

systemctl enable mongod &>>$LOG_FILE
VALIDATE $? "Enabling MongoDB"

systemctl start mongod &>>$LOG_FILE
VALIDATE $? "ENABLING ANS STARTING SERVER" 

sed -i 's/127.0.0.1/0.0.0.0/g' /etc/mongod.conf   #s-substitue, g-globally
VALIDATE $? "EDITING FILE" 

systemctl restart mongod &>>$LOG_FILE
VALIDATE $? "RESTARTING MONGO" 

