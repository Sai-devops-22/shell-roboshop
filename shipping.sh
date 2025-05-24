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

dnf install maven -y &>>$LOG_FILE
VALIDATE $? "INSTALLING MAVEN"

id roboshop
if [ $? -ne 0 ]
then
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop
else
    echo "already created"
fi

mkdir -p /app &>>$LOG_FILE

curl -L -o /tmp/shipping.zip https://roboshop-artifacts.s3.amazonaws.com/shipping-v3.zip &>>$LOG_FILE
VALIDATE $? "DOWNLOADING FILE"

rm -rf /app/*
cd /app
VALIDATE $? "CREATING APP FOLDER" 

unzip /tmp/shipping.zip &>>$LOG_FILE
VALIDATE $? "UNZIPPING"


mvn clean package &>>$LOG_FILE
VALIDATE $? "CLEANING PACKAGE"

mv target/shipping-1.0.jar shipping.jar  &>>$LOG_FILE
VALIDATE $? "Moving and renaming Jar"
 
cp $SCRIPT_DIRCT/shipping.service /etc/systemd/system/shipping.service &>>$LOG_FILE
VALIDATE $? "COPMONGO REPO COPYING"

systemctl enable shipping &>>$LOG_FILE
VALIDATE $? "ENABLING SHIPPING"

systemctl start shipping &>>$LOG_FILE
VALIDATE $? "STARTING SHIPPING"

dnf install mysql -y &>>$LOG_FILE
VALIDATE $? "INSTALLING MYSQL"

mysql -h mysql.daws84s.site -u root -p$MYSQL_ROOT_PASSWORD -e 'use cities' &>>$LOG_FILE
if [ $? -ne 0 ]
then
    mysql -h mysql.daws84s.site -uroot -p$MYSQL_ROOT_PASSWORD < /app/db/schema.sql &>>$LOG_FILE
    mysql -h mysql.daws84s.site -uroot -p$MYSQL_ROOT_PASSWORD < /app/db/app-user.sql  &>>$LOG_FILE
    mysql -h mysql.daws84s.site -uroot -p$MYSQL_ROOT_PASSWORD < /app/db/master-data.sql &>>$LOG_FILE
    VALIDATE $? "Loading data into MySQL"
else
    echo -e "Data is already loaded into MySQL ...  SKIPPING "
fi

systemctl restart shipping &>>$LOG_FILE
VALIDATE $? "Restart shipping"


END_DATE=$(date +%s)
TIME=$(($END_DATE - $START_TIME))
echo "$TIME"