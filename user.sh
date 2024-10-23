#!/bin/bash


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

id roboshop #if roboshop user does not exist, then it is failure


if [ $? -ne 0 ]
then

useradd roboshop

VALIDATE $? "roboshop user creation"

else
   

    echo -e "roboshop user already exist $Y SKIPPING $N"
fi

VALIDATE $? "Creating roboshop user" &>> $LOGFILE

mkdir -p /app

VALIDATE $? "creating app directory" 


curl -o /tmp/user.zip https://roboshop-builds.s3.amazonaws.com/catalogue.zip

VALIDATE $? "Downloading user application" &>> $LOGFILE


cd /app

unzip /tmp/user.zip &>> $LOGFILE

VALIDATE $? "unzipping user"

npm install &>> $LOGFILE

VALIDATE $? "Installing dependencies" 

cp /home/centos/roboshop-shell/user.service /etc/systemd/system/user.service

VALIDATE $? "Copying user service file"


systemctl daemon-reload &>> $LOGFILE

VALIDATE $? "user daemon reload" 

systemctl enable user &>> $LOGFILE

VALIDATE $? "Enable user"

systemctl start user &>> $LOGFILE

VALIDATE $? "Starting user"

cp /home/centos/roboshop-shell/mongo.repo /etc/yum.repos.d/mongo.repo

VALIDATE $? "Copying mongodb repo"

dnf install mongodb-org-shell -y &>> $LOGFILE

VALIDATE $? "Installing MongoDB client"

Mongo --host $MONGODB_HOST </app/schema/user.js &>> $LOGFILE

VALIDATE $? "Loading user data into MongoDB"


