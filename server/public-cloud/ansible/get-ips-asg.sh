#!/usr/bin/env bash

ASG_NUMBER="$1"

ASG_NAME="web-asg-${ASG_NUMBER}"

INSTANCE_IDS=$(aws autoscaling describe-auto-scaling-groups \
  --auto-scaling-group-names "$ASG_NAME" \
  --query 'AutoScalingGroups[0].Instances[*].InstanceId' --output text)

PUBLIC_IPS=$(aws ec2 describe-instances \
  --instance-ids $INSTANCE_IDS \
  --query 'Reservations[*].Instances[*].PublicIpAddress' --output text)

FILENAME="ips-${ASG_NAME}.txt"

for ip in $PUBLIC_IPS; do
  echo "$ip" >> $FILENAME
done

cat $FILENAME
