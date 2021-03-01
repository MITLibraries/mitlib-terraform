# AWS variables
variable "region" {
  description = "AWS region to be used for resources"
  type        = string
  default     = "us-east-1"
}

# S3 variables
variable "bucketname" {
  description = "The name of the thesis submit bucket"
  type        = string
}

variable "s3_acl" {
  description = "The ACL to apply to the thesis submit bucket"
  type        = string
}

variable "s3_cors_rule" {
  description = "The CORS rule for the bucket to allow cross-origin access"
}

variable "mfadelete_enabled" {
  description = "Flag to enable or disable the MFA_Delete requirement"
  type        = string
  default     = "false"
}

variable "versioning_enabled" {
  description = "(Optional) A state of versioning. Versioning is a means of keeping multiple variants of an object in the same bucket."
  type        = string
  default     = "false"
}

variable "noncurrent_rules_enabled" {
  description = "Specifies noncurrent lifecycle rule status."
  type        = string
  default     = "false"
}

variable "noncurrent_version_expiration_days" {
  description = "(Optional) Specifies when noncurrent object versions expire."
  default     = "90"
}

variable "noncurrent_version_transition_days" {
  description = "(Optional) Specifies when noncurrent object versions transitions"
  default     = "30"
}

variable "standard_transition_enabled" {
  description = "Specifies infrequent storage transition lifecycle rule status."
  type        = string
  default     = "false"
}

variable "standard_transition_days" {
  description = "Number of days to persist in the standard storage tier before moving to the infrequent access tier"
  default     = "30"
}

variable "glacier_transition_enabled" {
  description = "Specifies Glacier transition lifecycle rule status."
  type        = string
  default     = "false"
}

variable "glacier_transition_days" {
  description = "Number of days after which to move the data to the glacier storage tier"
  default     = "60"
}

variable "expire_objects_enabled" {
  description = "Specifies expiration lifecycle rule status."
  type        = string
  default     = "false"
}

variable "expiration_days" {
  description = "Number of days after which to expunge the objects"
  default     = "90"
}

