.DEFAULT_GOAL := build

REGION ?= "eu-west-2"

schedule-ec2-instance-to-stop:
	@bin/deploy.sh -r $(REGION) -t schedule-ec2-instance-to-stop -s schedule-stop-tag-based-ec2

iam-user-and-their-s3-bucket:
	@bin/deploy.sh -r $(REGION) -t iam-user-and-their-s3-bucket -s my-cf-templates