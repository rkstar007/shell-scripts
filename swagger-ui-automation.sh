#!/bin/bash

## Exit Script if not arguments is passed 
if [ $# -eq 0 ]; then
    echo "No arguments provided. Please pass the all the arguments required for swagger ui automation"
    echo "example : sh swagger-ui-automation.sh rktest-s3-bucket v3.19.0 us-east-2"
    exit 1
fi

## Variable Definition
DATE=`date +%Y-%m-%d`
HNAME=`uname -n`
LOGFILE="/var/log/swagger.log"

## FUNCTIONS

CHECK()
{
if [ $? -eq 0 ]; then
        echo "Success"
else
        echo "Swagger UI setup process is failed for ${HNAME} on ${DATE}, so kindly check it manually for resolution by reading last line of log file ${LOGFILE}"
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

function usage()
{
echo "Help:-  `basename $0` -h"  
}

function help()
{
echo "Help:-  `basename $0` -h [Help] | -b <bucket_name> | -v <swagger_ui_version> | -r  <region>"  
}

## GetOPs function to passing multiple arguments in shell script.

while getopts ":b:v:r:" opt; do
  case "$opt" in
   b | -bucket) bucket_name=$OPTARG ;;
   v | -version) swagger_ui_version=$OPTARG ;;
   r | -region) region=$OPTARG ;;
   h) help
      exit 0
	  ;;
  \?) echo "Unknown Option:-  " $OPTARG
	  exit 1 
	  ;;
   :) echo "$OPTARG: - requires a value.please see help."
	  exit 1
	  ;;
   *) usage
	  echo "Invalid Argument is passed"
esac
done

shift $(( OPTIND - 1 ))

## Calling Cleanup FUNCTIONS 
/bin/echo -e "\e[1;32mCalling cleanup function\e[0m"
Cleanup

	 
## Swagger-UI Creation Code
sudo yum install curl -y 
CHECK

curl -L https://github.com/swagger-api/swagger-ui/archive/${swagger_ui_version}.tar.gz -o /tmp/swagger-ui.tar.gz | sudo sh
CHECK

mkdir -p /tmp/swagger-ui
CHECK

tar --strip-components 1 -C /tmp/swagger-ui -xf /tmp/swagger-ui.tar.gz 
CHECK

aws s3 sync --region ${region} --acl public-read /tmp/swagger-ui/dist s3://${bucket_name} --delete 
CHECK

rm -rf  /tmp/swagger-ui
CHECK
