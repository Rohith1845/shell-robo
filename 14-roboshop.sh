#!/bin/bash

AMI_ID="ami-09c813fb71547fc4f"
SG_ID= "sg-045b3478cf0d8062e"  #Replace with your security group id

for instance in $@
do
    INSTANCE_ID=a$(ws ec2 run-instances --image-id $AMI_ID --instance-type t3.micro --security-group-ids $SG_ID --tag-specifications "ResourceType=instance,xTags=[{Key=Name,Value=$instance}]" --query 'Instances[0].InstancesId' --output text)

    if [ $instance != "frontend" ]; then
        IP=$(aws ec2 describe-instances --instance-ids $INSTANCE_ID --query 'Reservations[0].Instances[0].PrivateIpAddress' --output text)
    else
        IP=$(aws ec2 describe-instances --instance-ids $INSTANCE_ID --query 'Reservations[0].Instances[0].PublicIpAddress' --output text)
    fi
    echo "$instance: $"

done 