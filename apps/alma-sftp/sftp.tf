module "label" {
  source = "github.com/mitlibraries/tf-mod-name?ref=0.12"
  name   = "alma-sftp"
}

# Create the S3 bucket for the transfer server
module "alma_sftp_s3_bucket" {
  source                 = "github.com/mitlibraries/tf-mod-s3-iam?ref=0.12"
  name                   = "alma-sftp"
  expiration_days        = var.expire_in_days
  expire_objects_enabled = var.enable_expire_objects
  lifecycle_rule_enabled = var.lifecycle_rule
  tags                   = module.label.tags
}

# Create the transfer server with a Public (default) endpoint_type
resource "aws_transfer_server" "alma_sftp" {
  logging_role = aws_iam_role.alma_sftp_role.arn
  tags         = module.label.tags
}

# Create a managed SFTP user for Ex Libris and MIT Libraries
resource "aws_transfer_user" "exlibris" {
  depends_on = [module.alma_sftp_s3_bucket.bucket_id]
  server_id  = aws_transfer_server.alma_sftp.id
  user_name  = "exlibris"
  role       = aws_iam_role.alma_sftp_role.arn
  tags       = module.label.tags
}

resource "aws_transfer_user" "mitlib" {
  depends_on = [module.alma_sftp_s3_bucket.bucket_id]
  server_id  = aws_transfer_server.alma_sftp.id
  user_name  = "mitlib"
  role       = aws_iam_role.alma_sftp_role.arn
  tags       = module.label.tags
}

# Store an externally generated SSH key for the SFTP users

resource "aws_transfer_ssh_key" "exlibris" {
  server_id = aws_transfer_server.alma_sftp.id
  user_name = aws_transfer_user.exlibris.user_name
  body      = var.exlibris_ssh
}

resource "aws_transfer_ssh_key" "mitlib" {
  server_id = aws_transfer_server.alma_sftp.id
  user_name = aws_transfer_user.mitlib.user_name
  body      = var.mitlib_ssh
}

#Create IAM role for the transfer server
resource "aws_iam_role" "alma_sftp_role" {
  name = "alma-sftp-transfer-server-role-${terraform.workspace}"

  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
      {
      "Effect": "Allow",
      "Principal": {
        "Service": "transfer.amazonaws.com"
        },
      "Action": "sts:AssumeRole"  
      }
    ] 
  }
EOF
}

# Set SFTP user permissions
resource "aws_iam_role_policy" "alma_sftp_policy" {
  name = "alma-sftp-transfer-server-iam-policy-${terraform.workspace}"
  role = aws_iam_role.alma_sftp_role.id

  policy = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
        "Sid": "AllowFullAccesstoCloudWatchLogs",
        "Effect": "Allow",
        "Action": [
            "logs:*"
        ],
        "Resource": "*"
        },
        {
			    "Effect": "Allow",
          "Action": [
            "s3:ListBucket",
            "s3:GetBucketLocation"
          ],
         "Resource": [
            "arn:aws:s3:::${module.alma_sftp_s3_bucket.bucket_id}"
          ]
        },
        {
          "Effect": "Allow",
          "Action": [
            "s3:PutObject",
            "s3:GetObject",
            "s3:DeleteObject",
            "s3:DeleteObjectVersion",
            "s3:GetObjectVersion",
            "s3:GetObjectACL",
            "s3:PutObjectACL"
          ],
      "Resource": [
        "arn:aws:s3:::user/${aws_transfer_user.exlibris.user_name}/*",
        "arn:aws:s3:::user/${aws_transfer_user.mitlib.user_name}/*"
        ]
      }     
    ]
  }
  POLICY  
}


# Create the Route53 records for the transfer server
resource "aws_route53_record" "alma_sftp_dns_pri" {
  name    = "${var.workspace_hostname}.mitlib.net"
  zone_id = var.dns_zone_id_pri
  type    = "CNAME"
  ttl     = "300"
  records = ["${aws_transfer_server.alma_sftp.id}.server.transfer.us-east-1.amazonaws.com"]
}

resource "aws_route53_record" "alma_sftp_dns_pub" {
  name    = "${var.workspace_hostname}.mitlib.net"
  zone_id = var.dns_zone_id_pub
  type    = "CNAME"
  ttl     = "300"
  records = ["${aws_transfer_server.alma_sftp.id}.server.transfer.us-east-1.amazonaws.com"]
}
