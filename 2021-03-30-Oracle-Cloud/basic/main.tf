# This is going to be a basic deployment of Oracle cloud
# It should include a simple network with one subnet
# And on that subnet we'll deploy an Ubuntu VM running
# Nginx or Apache. The VM should have a public IP address
# and be accessible on port 80

terraform {
  required_providers {
      oci = {
          source = "hashicorp/oci"
          version = "~>4.0"
      }
  }
}

provider "oci" {}

variable "parent_compartment_id" {
  type = string
}

variable "region" {
  type = string
  default = "us-ashburn-1"
}

resource "oci_identity_compartment" "testing" {
  compartment_id = var.parent_compartment_id
  description = "Testing compartment"
  name = "testing"
  enable_delete = true
}

# Now we'll create the VCN

module "vcn" {
  source  = "oracle-terraform-modules/vcn/oci"
  version = "~>2.0"
  
  compartment_id = oci_identity_compartment.testing.id
  drg_display_name = "testing-drg"
  region = var.region
  vcn_dns_label = "testing"
  vcn_name = "testing"
  internet_gateway_enabled = true
  nat_gateway_enabled = true
  vcn_cidr = "10.1.0.0/16"

}

# In the VCN we'll create a subnet for the VM

resource "oci_core_subnet" "subnet1" {
  cidr_block = "10.1.0.0/24"
  compartment_id = oci_identity_compartment.testing.id
  vcn_id = module.vcn.vcn_id
}



module "compute-instance" {
  source  = "oracle-terraform-modules/compute-instance/oci"
  version = "2.1.0"
  
  
}
