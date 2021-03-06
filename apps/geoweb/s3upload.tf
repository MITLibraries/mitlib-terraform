module "geoweb_upload" {
  source             = "github.com/mitlibraries/tf-mod-s3-iam?ref=0.12"
  name               = "geoweb-upload"
  versioning_enabled = "true"
}

module "geoweb_label" {
  source = "github.com/mitlibraries/tf-mod-name?ref=0.12"
  name   = "geoweb-upload"
}

# Create a role with admin access to S3 bucket for managing Geoweb Data Uploads
# Access is maintained via "aws-672626379771-geoweb-upload-stage" and
# "aws-672626379771-geoweb-upload-prod" Moira lists
resource "aws_iam_role" "geoweb_upload" {
  name        = "IdP-${module.geoweb_label.name}"
  description = "Moira list role for users to upload ${module.geoweb_label.name} S3 bucket"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Federated": "${module.shared.mit_saml_arn}"
      },
      "Action": "sts:AssumeRoleWithSAML",
      "Condition": {
        "StringEquals": {
          "SAML:aud": "https://signin.aws.amazon.com/saml"
        }
      }
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "geoweb_upload" {
  role       = aws_iam_role.geoweb_upload.name
  policy_arn = module.geoweb_upload.admin_arn
}

########
## GBL user to download layers.
## This should be removed and replaced by the container's
##   role.
########

resource "aws_iam_user" "gbl_downloader" {
  name = "${module.label.name}-gbl-downloader"
  tags = module.label.tags
}

resource "aws_iam_user_policy_attachment" "gbl_downloader" {
  user       = aws_iam_user.gbl_downloader.name
  policy_arn = module.geoweb_upload.readonly_arn
}

resource "aws_iam_access_key" "gbl_downloader" {
  user = aws_iam_user.gbl_downloader.name
}
