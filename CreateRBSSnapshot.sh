#!/bin/bash
# Creates snapshot for all volumes tagged by Mehdi. It deletes all previous snapshots and then create a new one. 

ownerId=`aws iam list-roles --query Roles[0].Arn --output text | cut -f5 -d:`
volumes=`/usr/bin/aws ec2 describe-volumes --filters Name=tag-key,Values=CreatedBy Name=tag-value,Values=Mehdi --query Volumes[].VolumeId --output text`

for vol in $volumes
do
	oldSnapshots=`/usr/bin/aws ec2 describe-snapshots --owner-id $ownerId --query Snapshots[].[SnapshotId,VolumeId] \
	             --output text | grep vol-035fbd8434251a0ef |awk '{print $1}'`

	for oldSnapshot in $oldSnapshots
	do
		aws ec2 delete-snapshot --snapshot-id $oldSnapshot
	done 

        snapId=`/usr/bin/aws ec2 create-snapshot --volume-id $vol --region ap-southeast-2 \
               --description 'Please contact Mehdi before deleting me!' | grep "SnapshotId" | cut -f4 -d\"`

	/usr/bin/aws ec2 create-tags --resources $snapId --tags Key=Name,Value="Created by Mehdi" Key=CreatedBy,Value=Mehdi
done

