# EC2 variables
variable "ec2_ami" {
  description = "The AMI to use for the EC2 instance"
  type        = string
  default     = ""
}

variable "ec2_inst_type" {
  description = "The instance type for the EC2 instance"
  type        = string
  default     = ""
}

variable "ec2_key_name" {
  description = "SSH key to assign to the EC2 instance"
  type        = string
  default     = ""
}

variable "ec2_subnet" {
  description = "Subnet to use for the EC2 instance IP address"
  type        = string
  default     = ""
}

variable "ec2_vol_size" {
  description = "The EC2 volume size to use for the instance"
  type        = string
  default     = ""
}

variable "ec2_vol_type" {
  description = "The EC2 volume type to use for the instance"
  type        = string
  default     = ""
}

# EFS Vars
variable "efs_subnet" {
  description = "The subnet for the EFS mount target"
  type        = string
  default     = ""
}

variable "efs_mount" {
  description = "The EFS mount for the assetstore"
  type        = string
  default     = ""
}

# Route53 variables
variable "r53_internal_zone_id" {
  description = "The ID of the internal zone in which to create the DNS record"
  type        = string
  default     = ""
}

variable "r53_external_zone_id" {
  description = "The ID of the internal zone in which to create the DNS record"
  type        = string
  default     = ""
}

# Security Group variables
variable "sec_ssh_access_subnets" {
  description = "Subnets to allow SSH access"
  type        = list(string)
  default     = []
}

# Special
variable "ssh_key_private" {
  description = "SSH Private Key for remote-exec (ansible)"
  type        = string
  default     = ""
}
