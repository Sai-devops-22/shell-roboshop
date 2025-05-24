#!/bin/bash

START_TIME=$(date +%s)
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

echo "SER ROOT PASSWORD"
read -s MYSQL_PASSWORD

VALIDATE(){
    if [ $1 -eq 0 ]
    then    
        echo "the $2 is SUCCCES..." | tee -a $LOG_FILE
    else
        echo "the $2 is FAILED....." | tee -a $LOG_FILE
    fi
}

dnf install mysql-server -y &>>$LOG_FILE
VALIDATE $? "INSTALLING MYSQL"

systemctl enable mysqld &>>$LOG_FILE
VALIDATE $? "ENABLING MYSQL"

systemctl start mysqld &>>$LOG_FILE
VALIDATE $? "STARTING MYSQL"  

mysql_secure_installation --set-root-pass $MYSQL_PASSWORD &>>$LOG_FILE

END_DATE=$(date +%s)
TIME=$(($END_DATE - $START_TIME))
echo "$TIME"