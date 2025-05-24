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


dnf module list nginx &>>$LOG_FILE
VALIDATE $? "LISTING NGNIX"

dnf module disable nginx -y &>>$LOG_FILE
VALIDATE $? "Disabling Default Nginx"

dnf module enable nginx:1.24 -y &>>$LOG_FILE
VALIDATE $? "ENABLING NGINX"

dnf install nginx -y &>>$LOG_FILE
VALIDATE $? "INSTALLING NGINX"

rm -rf /usr/share/nginx/html/*  &>>$LOG_FILE
VALIDATE $? "REMOVING THE DATA IN HTML FOLDER"

curl -o /tmp/frontend.zip https://roboshop-artifacts.s3.amazonaws.com/frontend-v3.zip
VALIDATE $? "dowmloading the url"

cd /usr/share/nginx/html 
VALIDATE $? "GOING TO HMTL PAGE"

unzip /tmp/frontend.zip &>>$LOG_FILE
VALIDATE $? "UNZIPPING"

cp $SCRIPT_DIRCT/nginx.conf /etc/nginx/nginx.conf
VALIDATE $? "Copying nginx.conf"

systemctl restart nginx &>>$LOG_FILE
VALIDATE $? "RESTARTING NGINX"

