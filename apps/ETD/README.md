# ETD

## Ingest Bucket

See Jira [ETD-83](https://mitlibraries.atlassian.net/browse/ETD-83?atlOrigin=eyJpIjoiMzU3OWZjYzcxNDdkNDJiMzgxMGM4NTRlYzc1MWIzZGMiLCJwIjoiaiJ9) for details of the original request in the context of the ETD project.

The new thesis ingest process requires an S3 bucket for transient storage of ingested theses and related objects. The following general requirements were stated

* Separate buckets for dev and test
* CORS rules to allow Heroku apps to access bucket for storage
* IAM rules & keys (shared with EngX) to control access to bucket
* backup/DR to recover files unintentionally modified outside of the standard workflow
* expiration/deletion of objects to be handled by ETD workflow

## What's Created

* S3 bucket (NOT using our standard module)
* Versioning rules for protecting objects in bucket
* Storage tiering rules to move older content to less expensive storage tiers
* CORS configured to allow access by Heroku app
* IAM user with keys for programmatic access by Heroku app
* IAM policy that restricts S3 bucket access to Heroku app

## Access Control

Access control policies should be reviewed in the future. Our current practice for S3 buckets is to use IAM policies on the users to be granted access. We might want to revisit S3 bucket policies in the future. For reference, see this AWS blog post: [IAM vs Bucket Policies](https://aws.amazon.com/blogs/security/iam-policies-and-bucket-policies-and-acls-oh-my-controlling-access-to-s3-resources/).

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| bucketname | The name of the thesis submit bucket | `string` | n/a | yes |
| expiration\_days | Number of days after which to expunge the objects | `string` | `"90"` | no |
| expire\_objects\_enabled | Specifies expiration lifecycle rule status. | `string` | `"false"` | no |
| glacier\_transition\_days | Number of days after which to move the data to the glacier storage tier | `string` | `"60"` | no |
| glacier\_transition\_enabled | Specifies Glacier transition lifecycle rule status. | `string` | `"false"` | no |
| mfadelete\_enabled | Flag to enable or disable the MFA\_Delete requirement | `string` | `"false"` | no |
| noncurrent\_rules\_enabled | Specifies noncurrent lifecycle rule status. | `string` | `"false"` | no |
| noncurrent\_version\_expiration\_days | (Optional) Specifies when noncurrent object versions expire. | `string` | `"90"` | no |
| noncurrent\_version\_transition\_days | (Optional) Specifies when noncurrent object versions transitions | `string` | `"30"` | no |
| region | AWS region to be used for resources | `string` | `"us-east-1"` | no |
| s3\_acl | The ACL to apply to the thesis submit bucket | `string` | n/a | yes |
| s3\_cors\_rule | The CORS rule for the bucket to allow cross-origin access | `any` | n/a | yes |
| standard\_transition\_days | Number of days to persist in the standard storage tier before moving to the infrequent access tier | `string` | `"30"` | no |
| standard\_transition\_enabled | Specifies infrequent storage transition lifecycle rule status. | `string` | `"false"` | no |
| versioning\_enabled | (Optional) A state of versioning. Versioning is a means of keeping multiple variants of an object in the same bucket. | `string` | `"false"` | no |

## Outputs

| Name | Description |
|------|-------------|
| access\_key\_id | Access key ID for the Thesis Submit user |
| iam\_user | Name of the IAM user with access to the Thesis Submit bucket |
| secret\_access\_key | Secret access key for Thesis Submit user |
| thesis\_submit\_s3\_bucket | ARN for Thesis Submit bucket. |