module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "MC_VPC"
  cidr = var.ip_blocks.vpc_block

  # subnet info
  azs                     = [var.aws_primary_az]
  public_subnets          = var.ip_blocks.public_subnet_blocks
  map_public_ip_on_launch = true # we will use a elastic IP

  create_igw = true

  igw_tags = merge({
    Name = "MC_CORE_IGW"
  }, local.common_tags)

  tags = merge({
    Name = "MC_CORE_VPC"
  }, local.common_tags)
}


resource "aws_security_group" "sg" {
  name        = "MC_CORE_SG"
  vpc_id      = module.vpc.vpc_id
  description = "Web Traffic"

  ingress {
    description = "Allow SSH [SECURE]"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow MINECRAFT [tcp]"
    from_port   = local.mc_tcp_port
    to_port     = local.mc_tcp_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "Allow MINECRAFT [udp]"
    from_port   = local.mc_udp_port
    to_port     = local.mc_udp_port
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all ip and ports outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_iam_policy" "allow_ec2_ebs_attachment" {
  name        = "MC-Server-EBS-Attachment-Policy"
  description = "Allows an EC2 Instance to attach to EBS Volume with ID=${local.vm_settings.ebs_volume_id}"

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : "ec2:AttachVolume",
        "Resource" : [
          "arn:aws:ec2:*:${data.aws_caller_identity.current.account_id}:instance/*",
          "arn:aws:ec2:us-east-1:${data.aws_caller_identity.current.account_id}:volume/${local.vm_settings.ebs_volume_id}"
        ]
      }
    ]
  })
}

resource "aws_iam_role" "ec2_role" {
  name = "mc_ec2_ebs_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_policy_attachment" "policy_role_attach" {
  name       = "mc_ec2_ebs_role-attachment"
  roles      = [aws_iam_role.ec2_role.name]
  policy_arn = aws_iam_policy.allow_ec2_ebs_attachment.arn
}

resource "aws_iam_instance_profile" "ec2_attach_ebs_profile" {
  name = "mc_ec2_ebs_attachment"
  role = aws_iam_role.ec2_role.name
}

resource "aws_instance" "EC2_server" {
  ami           = local.vm_settings.ami
  instance_type = local.vm_settings.size

  vpc_security_group_ids = [aws_security_group.sg.id]
  subnet_id              = module.vpc.public_subnets[0]

  iam_instance_profile = aws_iam_instance_profile.ec2_attach_ebs_profile.name

  user_data = templatefile("./user_data_script.txt", {
    volume_id = local.vm_settings.ebs_volume_id
  })

  tags = merge({
    Name = "MC_CORE_EC2_server"
  }, local.common_tags)
}

resource "aws_route53_record" "server_record" {
  count   = var.use_domain ? 1 : 0
  zone_id = var.hosted_zone_id
  name    = "mc-server"
  type    = "A"
  ttl     = 300
  records = [aws_instance.EC2_server.public_ip]
}

