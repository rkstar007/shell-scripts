#!/bin/bash

## Variable Definition

aws_s3_bucket=$1
swagger_ui_version=$2
region=$3
AWSAccessKeyID=$4
AWSSecretKey=$5
DATE=`date +%Y-%m-%d`
HNAME=`uname -n`
LOGFILE="/var/log/swagger.log"

## FUNCTIONS

CHECK()
{
if [ $? -eq 0 ]; then
        echo "Success"
else
        echo "Swagger UI setup process is failed for ${HNAME} on ${DATE}, so kindly check it manually for solution read last line of log file ${LOGFILE} this step is not exctued on server properly"
	exit 1 
fi

}

Cleanup()
{
if [ ! -e "$LOGFILE" ] ; then
    touch "$LOGFILE"
else 
   echo "File is already exist on server location to cleanup old swagger error logs" 
    sudo rm -rf "$LOGFILE" 	
fi
}

## Calling Cleanup FUNCTIONS 
/bin/echo -e "\e[1;32mCalling cleanup function\e[0m"
Cleanup

### Export Environment Variables ###
export AWS_ACCESS_KEY_ID=${AWSAccessKeyID}
CHECK
export AWS_SECRET_ACCESS_KEY=${AWSSecretKey}
CHECK 	
 
## Swagger-UI Creation Code

sudo yum install curl -y 
CHECK

curl -L https://github.com/swagger-api/swagger-ui/archive/${swagger_ui_version}.tar.gz -o /tmp/swagger-ui.tar.gz | sudo sh
CHECK

mkdir -p /tmp/swagger-ui
CHECK

tar --strip-components 1 -C /tmp/swagger-ui -xf /tmp/swagger-ui.tar.gz 
CHECK

aws s3 sync --region ${region} --acl public-read /tmp/swagger-ui/dist s3://${aws_s3_bucket} --delete 
CHECK

rm -rf  /tmp/swagger-ui
CHECK
