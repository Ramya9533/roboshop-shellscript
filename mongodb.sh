#!/bin/bash


R="\e[31m"
G="\e[32m"
N="\e[0m"
Y="\e[33m"

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

cp mongo.repo /etc/yum.repos.d/mongo.repo &>>$LOGFILE

VALIDATE $? "Copied MongoDB Repo"

dnf install mongodb-org -y &>> $LOGFILE

VALIDATE $? "Installing MongoDB"

Systemctl enable mongodb &>> $LOGFILE

VALIDATE $? "Enabling MongoDB"

Systemctl start mongodb &>> $LOGFILE

VALIDATE $? "Starting MongoDB"

sed -i 's/127.0.0.1/0.0.0.0/g' /etc/mongod.conf &>> $LOGFILE

VALIDATE $? "Remote access to  MongoDB"


Systemctl restart mongodb &>> $LOGFILE


VALIDATE $? "Restarting MongoDB"

