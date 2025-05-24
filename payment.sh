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

VALIDATE(){
    if [ $1 -eq 0 ]
    then    
        echo "the $2 is SUCCCES..." | tee -a $LOG_FILE
    else
        echo "the $2 is FAILED....." | tee -a $LOG_FILE
    fi
}

dnf install python3 gcc python3-devel -y &>>$LOG_FILE
VALIDATE $? "INSTALLING PYTHON"

if [ $? -ne 0 ]
then 
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop
else
    echo "user already created"
fi

mkdir -p /app 

curl -L -o /tmp/payment.zip https://roboshop-artifacts.s3.amazonaws.com/payment-v3.zip &>>$LOG_FILE
VALIDATE $? "DOWNLOADING FILE"

rm -rf /app/* 
cd /app 

unzip /tmp/payment.zip &>>$LOG_FILE
VALIDATE $? "UNZIPPING"

pip3 install -r requirements.txt &>>$LOG_FILE
VALIDATE $? "PYTHON DEPENDENCIES"

cp $SCRIPT_DIRCT/payment.service /etc/systemd/system/payment.service &>>$LOG_FILE
VALIDATE $? "COPYING FILES" 
 
systemctl daemon-reload &>>$LOG_FILE
VALIDATE $? "DAEMON RELOAD"

systemctl enable payment &>>$LOG_FILE
VALIDATE $? "ENABLING PAYMENT"

systemctl start payment &>>$LOG_FILE
VALIDATE $? "STARTING PAYMENT"

END_DATE=$(date +%s)
TIME=$(($END_DATE - $START_TIME))
echo "$TIME"