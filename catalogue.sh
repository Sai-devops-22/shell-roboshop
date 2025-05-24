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

dnf module disable nodejs -y &>> $LOG_FILE
VALIDATE $? "DISABLING OLDFILES"

dnf module enable nodejs:20 -y &>> $LOG_FILE
VALIDATE $? "ENABLING NODEJS"

dnf install nodejs -y &>> $LOG_FILE
VALIDATE $? "INSTALLING NODEJS"

id roboshop
if [ $? -ne 0 ]
then
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>> $LOG_FILE
    VALIDATE $? "Creating roboshop system user"
else
    echo -e "System user roboshop already created ...  SKIPPING"
fi

mkdir -p /app 
VALIDATE $? "Creating app directory"

curl -o /tmp/catalogue.zip https://roboshop-artifacts.s3.amazonaws.com/catalogue-v3.zip &>>$LOG_FILE
VALIDATE $? "Downloading Catalogue"

rm -rf /app/*
cd /app 

unzip /tmp/catalogue.zip &>>$LOG_FILE
VALIDATE $? "unzipping catalogue"

npm install &>>$LOG_FILE
VALIDATE $? "Installing Dependencies"

cp $SCRIPT_DIRCT/catalogue.service /etc/systemd/system/catalogue.service
VALIDATE $? "Copying catalogue service"

systemctl daemon-reload &>> $LOG_FILE
VALIDATE $? "DAEMON RELODING"

systemctl enable catalogue &>> $LOG_FILE
systemctl start catalogue &>> $LOG_FILE
VALIDATE $? "ENABILNG AND STARTING CATALOGUE"

dnf install mongodb-mongosh -y &>> $LOG_FILE
VALIDATE $? "INSTALLING"

cp $SCRIPT_DIRCT/mongodb.repo /etc/yum.repos.d/mongo.repo
VALIDATE $? "COPMONGO REPO COPYING"


STATUS=$(mongosh --host mongodb.dpractice.site --eval 'db.getMongo().getDBNames().indexOf("catalogue")')
if [ $STATUS -lt 0 ]
then
    mongosh --host mongodb.dpractice.site </app/db/master-data.js &>>$LOG_FILE
    VALIDATE $? "Loading data into MongoDB"
else
    echo -e "Data is already loaded ... $Y SKIPPING $N"
fi