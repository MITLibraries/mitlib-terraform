variable "dns_zone_id_pri" {
  type        = string
  description = "Private DNS Zone for the Route53 Record"
}

variable "dns_zone_id_pub" {
  type        = string
  description = "Public DNS Zone for the Route53 Record"
}

variable "workspace_hostname" {
  type        = string
  description = "The hostname of the SFTP server"
}

variable "enable_expire_objects" {
  description = "Specifies expiration lifecycle rule status."
  type        = string
  default     = "false"
}

variable "expire_in_days" {
  description = "Number of days after which to expunge the objects"
  default     = "30"
}

variable "exlibris_ssh" {
  type        = string
  description = "Public SSH key for the ExLibris SSH user"
}

variable "lifecycle_rule" {
  type        = string
  description = "Enable lifecycle events on this object"
}

variable "mitlib_ssh" {
  type        = string
  description = "Public SSH key for the MIT Libraries SSH user"
}
