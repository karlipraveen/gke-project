project_id          = "qwiklabs-gcp-04-c385bcd0f66a"
region              = "us-east1"
zone                = "us-east1-d"
instance_type       = "e2-medium"
image               = "projects/ubuntu-os-cloud/global/images/family/ubuntu-2204-lts"
network             = "default"
subnetwork          = "default"
devops_server_secgr = "development-server-firewall"
dev_server_ports = [
  22,
  80,
  8000,
  8080,
  9090,
  8081,
  8082,
  8083,
  8888,
  9411,
  7979,
  3000,
  9091,
  8761
]

devservertag    = "development-server"
ssh_user        = "devops"
public_key_file = "C:/Users/user/.ssh/id_rsa.pub"