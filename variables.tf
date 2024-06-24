variable "aws_primary_region" {
  default     = "us-east-1"
  description = "Value of the region for most of the components"
}

variable "aws_primary_az" {
  default     = "us-east-1a"
  description = "Value of the region for most of the components"
}

variable "ebs_attrs" {
  default = {
    "size" = 24
    "type" = "gp3"
  }
}

variable "ip_blocks" {
  default = {
    vpc_block            = "172.31.0.0/16"
    public_subnet_blocks = ["172.31.0.0/24"]
  }
}

variable "ebs_volume_id" {
  description = "ID of the EBS Volume you installed the server on"
}

variable "use_domain" {
  description = "Do you own a domain? Set to true to update Hosted Zone (below) if yes"
  default     = true
}

variable "hosted_zone_id" {
  description = "ID of the Hosted Zone if you own/imported your domain to AWS"
}
