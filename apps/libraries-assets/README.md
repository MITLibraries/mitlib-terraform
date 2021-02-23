# Libraries Assets website

This folder contains AWS resources needed for the deployment of the [Libraries Assets Website](https://libraries-assets.mit.edu).

### What's created?:
* An S3 bucket for storing static web files
* An AWS Cloudfront CDN for this S3 Bucket
* A Route53 alias
* An index.html file is uploaded to the S3 Bucket and set as the default in the Cloudfront CDN

### Input Variables
| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| certificate_arn | The ARN of the certificate in ACM | string | n/a | yes |
| dns_zone_id_pub | Public DNS Zone for the Route53 Record | string | n/a | yes |
| dns_zone_id_pri | Private DNS Zone for the Route53 Record | string | n/a | yes |

### Additional Info:
* libraries-assets is only deployed to the Terraform `prod` workspace
* The libraries-assets.mit.edu certificate was uploaded manually to ACM
* Files are uploaded to the S3 Bucket manually. There is no automated deployment method to the S3 bucket. (EngX will manually add files to the S3 bucket at this time via the AWS web console using existing credentials. Once they have enough files using this service to warrant, EngX will be responsible for automating deployment and at that time would work with InfraEng to determine if a use case specific access key or role is necessary.)
