variable "region" {
  type        = string
  description = "AWS region"
  default     = "eu-west-1"
}

variable "bucket" {
  type        = string
  description = "S3 bucket name"
  default     = "kestra-ie"
}
