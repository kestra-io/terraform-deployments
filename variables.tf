variable "aws_region" {
  default = "eu-north-1"
}

variable "s3_bucket" {
  default = "kestra-prod"
}

variable "vpc_cidr_block" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "subnet_count" {
  description = "Number of subnets"
  type        = map(number)
  default = {
    public  = 1,
    private = 2
  }
}

variable "settings" {
  description = "Configuration settings"
  type        = map(any)
  default = {
    "database" = {
      allocated_storage = 10         // storage in gigabytes
      engine            = "postgres" // engine type
      engine_version      = "15.3"      // engine version
      instance_class      = "db.t3.micro" // rds instance type
      db_name             = "kestradb"    // database name
      skip_final_snapshot = true
      storage_type        = "gp2"
    },
    "kestra_app" = {
      count         = 1          // the number of EC2 instances
      instance_type = "t3.medium" // the EC2 instance
      ami           = "ami-0989fb15ce71ba39e"
    }
  }
}

variable "public_subnet_cidr_blocks" {
  description = "Available CIDR blocks for public subnets"
  type        = list(string)
  default = [
    "10.0.1.0/24",
    "10.0.2.0/24",
    "10.0.3.0/24",
    "10.0.4.0/24"
  ]
}

variable "private_subnet_cidr_blocks" {
  description = "Available CIDR blocks for private subnets"
  type        = list(string)
  default = [
    "10.0.101.0/24",
    "10.0.102.0/24",
    "10.0.103.0/24",
    "10.0.104.0/24",
  ]
}

// This variable contains your IP address. This
// is used when setting up the SSH rule on the
// web security group
variable "my_ip" {
  description = "Your IP address"
  type        = string
  sensitive   = true
}

variable "db_username" {
  description = "Database master user"
  type        = string
  sensitive   = true
}

variable "db_password" {
  description = "Database master user password"
  type        = string
  sensitive   = true
}

variable "aws_access_key" {
  description = "AWS Access Key"
  type = string
  sensitive = true
}

variable "aws_secret_key" {
  description = "AWS Secret Key"
  type = string
  sensitive = true
}
