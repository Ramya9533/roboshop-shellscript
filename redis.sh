#!/bin/bash


R="\e[31m"
G="\e[32m"
N="\e[0m"
Y="\e[33m"


TIMESTAMP=$(date +%F-%H-%M-%S)

LOGFILE="/tmp/$0-$TIMESTAMP.log"
exec &>$LOGFILE 

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

dnf install https://rpms.remirepo.net/enterprise/remi-release-8.rpm -y &>> $LOGFILE

VALIDATE $? "Installing Remi release"

dnf module enable redis:remi-6.2 -y

VALIDATE $? "enabling redis"

dnf install redis -y &>> $LOGFILE

VALIDATE $? "Installing Redis"

sed -i 's/127.0.0.1/0.0.0.0/g' /etc/redis.conf

VALIDATE $? "allowing remote connections"

systemctl enable redis

VALIDATE $? "Enabled Redis"

systemctl start redis

VALIDATE $? "Started Redis"



