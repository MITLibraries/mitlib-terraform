# Alma SFTP Server

This folder contains AWS resources needed for the deployment of the [Alma SFTP server](https://alma-sftp.mitlib.net).
The request for this infrastructure is documented in Jira task [IMP-1714](https://mitlibraries.atlassian.net/browse/IMP-1714)

### What's created?:
* An S3 bucket for storing SFTP files with a 30-day retention policy
* An AWS SFTP transfer server
* A public and private zone Route53 alias
* SFTP users for ExLibris and MIT Libraries
* SSH keys imported for ExLibris and MIT Libraries users

### Input Variables
| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| enable_expire_objects | Specifies expiration lifecycle rule status | string | "false" | no |
| expire_in_days | Number of days after which to expunge the objects | string | "90" | no |
| exlibris_ssh | SSH key for the Ex Libris user | string | n/a | yes |
| lifecycle_rule | Enable lifecycle events on the S3 bucket | string | "false" | no |
| mitlib_ssh | SSH key for the MIT Libraries user | string | n/a | yes |
| workspace_hostname | Hostname for the DNS record for stage or prod | string | n/a | yes |

### Additional Info:
* Manually create the SSH keypairs and store the private keys in the LastPass/Alma folder
* Content could have protected data so a 30-day retention policy will be set
