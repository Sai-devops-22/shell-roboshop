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

dnf module disable nodejs -y &>>$LOG_FILE
VALIDATE $? "DISABLING EXSISTING FILE"

dnf module enable nodejs:20 -y &>>$LOG_FILE
VALIDATE $? "ENABLING NODE JS : 20"

dnf install nodejs -y &>>$LOG_FILE
VALIDATE $? "INSTALLING NODEJS"

id roboshop
if [ $? -ne 0 ]
then
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop
else
    echo "already exist"
fi

mkdir -p /app 
VALIDATE $? "creating directory"

curl -L -o /tmp/user.zip https://roboshop-artifacts.s3.amazonaws.com/user-v3.zip &>>$LOG_FILE
VALIDATE $? "DOWMLODING FILE"

rm -rf /app/*
cd /app 
VALIDATE $? "CHAGING TO APP FOLDER"

unzip /tmp/user.zip &>>$LOG_FILE
VALIDATE $? "UNZIPPING"

npm install &>>$LOG_FILE
VALIDATE $? "INSTALLING DEPENDENCY"

cp $SCRIPT_DIRCT/user.service /etc/systemd/system/user.service &>>$LOG_FILE
VALIDATE $? "COPYING FILE"

systemctl daemon-reload &>>$LOG_FILE
VALIDATE $? "SYSTEM RESTARTING"

systemctl enable user &>>$LOG_FILE
VALIDATE $? "ENABLING USER"

systemctl start user &>>$LOG_FILE
VALIDATE $? "STARTING USER"