locals {
  common_tags = {
    minecraft_server = true
  }
  mc_tcp_port = 25565
  mc_udp_port = 19132

  vm_settings = {
    size          = "t2.large"
    ebs_volume_id = var.ebs_volume_id #! Should be replaced 
    ami           = "ami-06ca3ca175f37dd66"
  }
}
