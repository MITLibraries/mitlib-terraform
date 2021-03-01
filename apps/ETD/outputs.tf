output "thesis_submit_s3_bucket" {
  value       = aws_s3_bucket.default.arn
  description = "ARN for Thesis Submit bucket."
}

output "iam_user" {
  description = "Name of the IAM user with access to the Thesis Submit bucket"
  value       = aws_iam_user.default.name
}

output "access_key_id" {
  value       = aws_iam_access_key.default.id
  description = "Access key ID for the Thesis Submit user"
}

output "secret_access_key" {
  value       = aws_iam_access_key.default.secret
  sensitive   = true
  description = "Secret access key for Thesis Submit user"
}

