#!/bin/bash

AMI_ID="ami-09c813fb71547fc4f"
SG_ID="sg-028aa04b4b0793ed4"
INSTANCES=("mongodb" "redis" "rabbitmq" "user" "cart" "mysql" "catalogue" "shipping" "frontend")
ZONE_ID="Z06253831Z4BB44Y5XLFS"
DOMAIN_NAME="dpractice.site"

for instances in ${INSTANCES[@]}
do
    INSTANCE_ID=$(aws ec2 run-instances --image-id ami-09c813fb71547fc4f --instance-type t2.micro --security-group-ids ssg-028aa04b4b0793ed4 --tag-specifications "ResourceType=instance,
    Tags=[{Key=Name, Value=$instances}]" --query "Instances[0].InstancesId" --output text)
    if [ $instance != "frontend" ]
    then    
        IP=$(aws ec2 describe-instances --instance-ids $INSTANCE_ID --query "Reservations[0].Instances[0].PrivateIpAddress" --output text)
    else
        IP=$(aws ec2 describe-instances --instance-ids $INSTANCE_ID --query "Reservations[0].Instances[0].PublicIpAddress" --output text)
    fi
    echo "$instance : $IP"
done