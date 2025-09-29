#!/bin/bash

USER_ID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

LOGS_FOLDER="var/log/shell-roboshop"
SCRIPT_NAME=$( echo $0 | cut -d "." -f1)
SCRIPT_DIR=$PWD
MONGODB=HOST=mongodb.rdaws86s.fun
LOG_FILE=$LOGS_FOLDER/$SCRIPT_NAME.log

mkdir -p $LOGS_FOLDER
echo "script started excuted at: $(date)" | tee -a $LOGS_FILE

if [ $USER_ID -ne 0]; then
    echo "Error:: please run the script with root privelege"
    exit 1
fi

VALIDATE(){ # functions receive inputs through args just like shell script args
    if [ $1 -ne 0 ]; then
        echo -e "$2 ... $R FAILURE $N" | tee -a $LOG_FILE
        exit 1
    else
        echo -e "$2 ... $G SUCCESS $N" | tee -a $LOG_FILE
    fi
}

dnf module disable nodejs -y &>>$LOG_FILE
VALIDATE $? "Disabling NodeJS"

dnf module enable nodejs:20 -y  &>>$LOG_FILE
VALIDATE $? "Enabling NodeJS 20"

dnf install nodejs -y &>>$LOG_FILE
VALIDATE $? "Installing NodeJS"

mkdir -p /app
VALIDATE $? "Creating app directory"

curl -o /tmp/catalogue.zip https://roboshop-artifacts.s3.amazonaws.com/catalogue-v3.zip &>>$LOG_FILE
VALIDATE $? "Downloading catalogue application"

cd /app 
VALIDATE $? "Changing to app directory"

rm -rf /app/*
VALIDATE $? "Removing existing code"

unzip /tmp/catalogue.zip &>>$LOG_FILE
VALIDATE $? "unzip catalogue"

npm install &>>$LOG_FILE
VALIDATE $? "Install dependencies"

cp $SCRIPT_DIR/catalogue.service /etc/systemd/system/catalogue.service
VALIDATE $? "Copy systemctl service"

systemctl daemon-reload
systemctl enable catalogue &>>$LOG_FILE
VALIDATE $? "Enable catalogue"

cp $SCRIPT_DIR/mongo.repo /etc/yum.repos.d/mongo.repo
VALIDATE $? "Copy mongo repo"

dnf install mongodb-mongosh -y &>>$LOG_FILE
VALIDATE $? "Install MongoDB client"

