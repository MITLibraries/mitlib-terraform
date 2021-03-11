# Dome Analytics Server

This folder contains the AWS resources needed for an ec2 instance used for
computing analytics on the Dome system. Dome is a DSpace digital repository
instance.

### What's Created
* An EC2 instance
* An EFS instance
* An Elastic IP for the Dome analytics server
* Route53 DNS entries for the Dome analytics server

### Additional Info
* EFS access is restricted based on security group membership

## Input Variables
| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| ec2\_ami | The AMI to use for the EC2 instance | string | n/a | yes |
| ec2\_inst\_type | The instance type for the EC2 instance | string | n/a | yes |
| ec2\_key\_name | SSH key to assign to the EC2 instance | string | n/a | yes |
| ec2\_subnet | Subnet to use for the EC2 instance IP address | string | n/a | yes |
| ec2\_vol\_size | The EC2 volume size to use for the instance | string | n/a | yes |
| ec2\_vol\_type | The EC2 volume type to use for the instance | string | n/a | yes |
| efs\_subnet | The subnet for the EFS mount target | string | n/a | yes |
| efs\_mount | The mount location for the EFS file system | string | n/a | yes |
| r53\_internal\_zone\_id | The ID of the zone in which to create the internal DNS record | string | n/a | yes |
| r53\_external\_zone\_id | The ID of the zone in which to create the external DNS record | string | n/a | yes |
| sec\_ssh\_access\_subnets | Subnets to allow SSH access | string | n/a | yes |

## Outputs
| Name | Description |
|------|-------------|
| ec2_private_address | Private IP of the EC2 instance |
| efs\_mount\_address | EFS mount point DNS address |
| eip\_public\_address | Elastic IP address of the new Dome analytics server |
