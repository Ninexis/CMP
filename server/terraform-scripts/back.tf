variable "auth_url" {}
variable "ip" {}
variable "user_name" {}
variable "password" {}
variable "tenant_name" {}
variable "domain_name" {}
variable "security_group" {}
variable "flavor" {}

terraform {
required_version = ">= 0.14.0"
  required_providers {
    openstack = {
      source  = "terraform-provider-openstack/openstack"
      version = "~> 1.53.0"
    }
  }
}

provider "openstack" {
  auth_url    = var.auth_url
  user_name   = var.user_name
  password    = var.password
  tenant_name = var.tenant_name # Précise le tenant (projet) si nécessaire
  domain_name = var.domain_name # Assurez-vous que le domaine est correct
  endpoint_overrides = {
    "network"  = "http://${var.ip}:9696/v2.0/"
    "compute"  = "http://${var.ip}:8774/v2.1/"
    "image"    = "http://${var.ip}:9292/v2/"
    "identity" = "http://${var.ip}:5000/v3/"
  }
}

variable "user_data" {
  description = "Script d'initialisation cloud-init"
  type        = string
}

variable "vm_name" {
  description = "Nom de la VM"
}

resource "openstack_compute_instance_v2" "server" {
  name        = var.vm_name
  image_name  = "Ubuntu 22.04 Cloud"
  flavor_id = var.flavor
  key_pair  = "mykey"
  network { name = "my-private-net" }
  security_groups = [var.security_group]

  user_data       = var.user_data
  metadata = {
    auto_start = "true"
  }
} 

# Crée une IP flottante dans le pool "public"
resource "openstack_networking_floatingip_v2" "fip" {
  pool = "external-network"
}

# Associe l'IP flottante à la VM
resource "openstack_compute_floatingip_associate_v2" "fip_association" {
  floating_ip = openstack_networking_floatingip_v2.fip.address
  instance_id = openstack_compute_instance_v2.server.id
  #fixed_ip    = openstack_compute_instance_v2.server.network[0].fixed_ip_v4
}

# Affiche l'IP flottante en sortie
output "floating_ip_address" {
  value = openstack_networking_floatingip_v2.fip.address
  description = "L'adresse IP publique de la machine"
}
