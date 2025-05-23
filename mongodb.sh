#!/bin/bash

USER_ID=$(id -u)
LOG_PATH="var/log/shell-roboshop-log"
SCRIPT_NAME=$(echo $0 | cut -d "." -f1)
LOG_FILE="$LOG_PATH/$SCRIPT_NAME.log"
mkdir -p $LOG_FOLDER
echo "THE EXECUTION START TIME:$(date)" | tee -a $LOG_FILE

if [ $USER_ID -ne 0 ]
then 
    echo "login to root user and try again" | tee -a $LOG_FILE
    exit 1
else
    echo "you are a root user" | tee -a $LOG_FILE

VALIDATE(){
    if [ $1 -eq 0 ]
    then    
        echo "the $2 is SUCCCES..." | tee -a $LOG_FILE
    else
        echo "the $2 is FAILED....." | tee -a $LOG_FILE
}

cp mongodb.repo /etc/yum.repos.d/mongo.repo &>>$LOG_FILE
VALIDATE $? "MONGO REPO COPYING" 

dnf install mongodb-org -y &>>$LOG_FILE
VALIDATE $? "INSTALLING MONGO SERVER" 

systemctl enable mongod &>>$LOG_FILE
systemctl start mongod &>>$LOG_FILE
VALIDATE $? "ENABLING ANS STARTING SERVER" 

sed -i 's/127.0.0.1/0.0.0.0/g' /etc/mongod.conf  &>>$LOG_FILE  #s-substitue, g-globally
VALIDATE $? "EDITING FILE" 

systemctl restart mongod &>>$LOG_FILE
VALIDATE $? "RESTARTING MONGO" 
