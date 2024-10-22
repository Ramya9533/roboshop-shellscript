#!/bin/bash


R="\e[31m"
G="\e[32m"
N="\e[0m"
Y="\e[33m"
MONGODB_HOST=mongodb.daws76s.online

TIMESTAMP=$(date +%F-%H-%M-%S)

LOGFILE="/tmp/$0-$TIMESTAMP.log"

echo "script started executing at $TIMESTAMP"  &>> $LOGFILE

VALIDATE(){
    IF [ $1 -ne 0 ]
    then
      echo -e $2 ... $R FAILED $N"

    else
      echo -e $2 ... $G SUCCESS $N"

      fi

}

ID=$(id-u)

if [ $ID -ne 0 ]
then
    echo -e "$R ERROR:: Please run this script with root access $N"
    exit 1 # you can give other than 0

else

    echo "You are root user"
fi # fi means reverse of if, indicating condition end

dnf module disable nodejs -y

VALIDATE $? "Disabling current NodeJS" &>> $LOGFILE

dnf module disable nodejs:18 -y

VALIDATE $? "Enabling NodeJS:18" &>> $LOGFILE

dnf install nodejs -y

VALIDATE $? "Installing NodeJS:18" &>> $LOGFILE

id roboshop
if [ $? -ne 0 ]
then

useradd roboshop

VALIDATE $? "roboshop user creation"

else
   

    echo -e "roboshop user already exist $Y SKIPPING $N"
fi

VALIDATE $? "Creating roboshop user" &>> $LOGFILE

mkdir -p /app

VALIDATE $? "creating app directory" &>> $LOGFILE


curl -o /tmp/catalogue.zip https://roboshop-builds.s3.amazonaws.com/catalogue.zip

VALIDATE $? "Downloading catalogue application" &>> $LOGFILE


cd /app

unzip /tmp/catalogue.zip &>> $LOGFILE

VALIDATE $? "unzipping catalogue" &>> $LOGFILE

npm install &>> $LOGFILE

VALIDATE $? "Installing dependencies" &>> $LOGFILE

# use absolute, because catalogue.service exists there

cp /home/centos/roboshop-shell/catalogue.service /etc/systemd/system/catalogue.service &>> $LOGFILE

VALIDATE $? "Copying catalogue service file"

systemctl daemon-reload &>> $LOGFILE

VALIDATE $? "Catalogue daemon reload" &>> $LOGFILE

systemctl enable catalogue &>> $LOGFILE

VALIDATE $? "Enable catalogue"

systemctl start catalogue &>> $LOGFILE

VALIDATE $? "Starting catalogue"

cp /home/centos/roboshop-shell/mongo.repo /etc/yum.repos.d/mongo.repo

VALIDATE $? "Copying mongodb repo"

dnf install mongodb-org-shell -y &>> $LOGFILE

VALIDATE $? "Installing MongoDB client"

Mongo --host $MONGODB_HOST </app/schema/catalogue.js &>> $LOGFILE

VALIDATE $? "Loading catalogue data into MongoDB"
 
 












