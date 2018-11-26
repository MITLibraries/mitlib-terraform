variable "name" {
  description = "Name to be used on all the resources as identifier"
  default     = ""
}

variable "cidr" {
  description = "The CIDR block for the VPC which will be created if `vpc_id` is not specified"
  default     = ""
}

variable "azs" {
  description = "A list of availability zones in the region"
  type        = "list"
  default     = []
}

variable "public_subnets" {
  description = "A list of public subnets inside the VPC"
  type        = "list"
  default     = []
}

variable "private_subnets" {
  description = "A list of private subnets inside the VPC"
  type        = "list"
  default     = []
}