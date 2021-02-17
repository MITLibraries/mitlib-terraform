variable "certificate_arn" {
  type        = string
  description = "The ARN of the certificate in ACM"
  default     = ""
}

variable "dns_zone_id_pub" {
  type        = string
  description = "Public DNS Zone for the Route53 Record"
}

variable "dns_zone_id_pri" {
  type        = string
  description = "Private DNS Zone for the Route53 Record"
}
