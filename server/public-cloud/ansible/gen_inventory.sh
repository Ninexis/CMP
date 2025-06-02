#!/usr/bin/env bash

ASG_NAME="web-asg-1"

INSTANCE_IDS=$(aws autoscaling describe-auto-scaling-groups \
  --auto-scaling-group-names "$ASG_NAME" \
  --query 'AutoScalingGroups[0].Instances[*].InstanceId' --output text)

PUBLIC_IPS=$(aws ec2 describe-instances \
  --instance-ids $INSTANCE_IDS \
  --query 'Reservations[*].Instances[*].PublicIpAddress' --output text)

echo "[web]" > inventory.ini
for ip in $PUBLIC_IPS; do
  echo "$ip ansible_user=ubuntu" >> inventory.ini
done

echo "✅ inventory.ini generated:"
cat inventory.ini
