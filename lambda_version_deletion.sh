#!/bin/bash

## Exit Script if not arguments is passed 
if [ $# -eq 0 ]; then
    echo "No arguments provided. Please pass the aws-region from which to remove the old lambda versions"
    echo "example : sh lambda_version_deletion.sh us-east-2"
    exit 1
fi

## Variable Definition
Region=$1

## Cleanup OLD Data
rm -fv /opt/lambda_functions.txt
rm -fv /opt/lambda_list_versions.txt
rm -fv /opt/lambda_list_versions_latest.txt

## Execution

echo "Creating file /opt/lambda_functions.txt which lists all the lambda functions"
aws lambda list-functions --region ${Region} | grep -i "FunctionName" | awk '{print $NF}' | cut -d'"' -f2 >> /opt/lambda_functions.txt

echo "Creating file /opt/lambda_list_versions.txt which will list all existing version for each lambda"
for i in `cat /opt/lambda_functions.txt` ; do  aws lambda list-versions-by-function --region ${Region} --function-name ${i} | grep -w  "Version" | awk '{print $2}' | cut -d'"' -f2 >> /opt/lambda_list_versions.txt ; done

echo "Creating file /opt/lambda_list_versions_latest.txt which will include a list of all versions for all lambdas excluding the latest (current) version"
cat /opt/lambda_list_versions.txt  | egrep -vw "$LATEST" | sort -rn | head -n1 | uniq -c  | awk '{print $2}' >> /opt/lambda_list_versions_latest.txt

echo "Looping through the list all functions + versions & using AWS CLI to remove the lambdas"
for j in `cat /opt/lambda_functions.txt`
 do
for (( k=1; k<="$(cat /opt/lambda_list_versions_latest.txt)"; k++ ))
 do
    aws lambda delete-function --region ${Region} --function-name ${j} --qualifier ${k}
    echo "...lambda ${j} version ${k} was removed"
 done
done
