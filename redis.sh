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

#sed editor- permanent change(-i) ane execute(e) 127.0.0.1 to 0.0.0.0 and execute protected-mode 
#cahnges(c) to procted mode no copying the filr into /etc/redi/redis.conf 
sed -i -e 's/127.0.0.1/0.0.0.0/g' -e '/protected-mode/ c protected-mode no' /etc/redis/redis.conf
VALIDATE $? "CHANGING THE CONFIGURATION FILE"

END_DATE=$(date +%s)
TIME=$(($END_DATE - $START_TIME))
echo "$TIME"