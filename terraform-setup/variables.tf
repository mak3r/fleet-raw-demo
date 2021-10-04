variable "aws_access_key_id" {
  type        = string
  description = "AWS access key used to create infrastructure"
}
variable "aws_secret_access_key" {
  type        = string
  description = "AWS secret key used to create AWS infrastructure"
}
variable "aws_region" {
  type        = string
  description = "AWS region used for all resources"
  default     = "us-east-1"
}
variable "ssh_key_file_name" {
  type        = string
  description = "File path and name of SSH private key used for infrastructure and RKE"
  default     = "~/.ssh/id_rsa"
}
variable "prefix" {
  type        = string
  description = "Prefix added to names of all resources"
  default     = "mak3r"
}

variable "arm_count" {
  type        = number
  description = "Number of arm devices"
  default     = 4
}

variable "amd_count" {
  type        = number
  description = "Number of amd devices. "
  default     = 0
}

variable "gpu_count" {
  type        = number
  description = "Number of amd devices. "
  default     = 0
}

variable "demo_gpu" {
  type        = bool
  description = "true if a GPU resource should get created. Default false"
  default     = false
}