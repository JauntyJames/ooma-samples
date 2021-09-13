
variable "seoul_name" {
  default = "ap-seoul-1"
}

variable "seoul_cidr" {
  default = "10.0.0.0/16"
}

provider "oci" {
  alias            = "seoul"
  region           = var.seoul_name
  tenancy_ocid     = var.tenancy_ocid
  user_ocid        = var.user_ocid
  fingerprint      = var.fingerprint
  private_key_path = var.private_key_path
}

resource "oci_core_vcn" "seoul_vcn" {
  provider       = oci.seoul
  display_name   = "seoul_vcn"
  dns_label      = "seoulvcn"
  cidr_block     = var.seoul_cidr
  compartment_id = var.compartment_ocid
}

resource "oci_core_drg" "seoul_drg" {
  provider       = oci.seoul
  compartment_id = var.compartment_ocid
}

resource "oci_core_drg_attachment" "seoul_drg_attachment" {
  provider = oci.seoul
  drg_id   = oci_core_drg.seoul_drg.id
  vcn_id   = oci_core_vcn.seoul_vcn.id
}

resource "oci_core_remote_peering_connection" "seoul" {
  provider         = oci.seoul
  compartment_id   = var.compartment_ocid
  drg_id           = oci_core_drg.seoul_drg.id
  display_name     = "remotePeeringConnectionSeoul"
  peer_id          = oci_core_remote_peering_connection.osaka.id
  peer_region_name = var.osaka_name
}

resource "oci_core_internet_gateway" "seoul_internet_gateway" {
  provider       = oci.seoul
  compartment_id = var.compartment_ocid
  display_name   = "seoul_internet_gateway"
  vcn_id         = oci_core_vcn.seoul_vcn.id
}

resource "oci_core_route_table" "seoul_route_table" {
  provider       = oci.seoul
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.seoul_vcn.id
  display_name   = "seoulRouteTable"

  route_rules {
    destination       = var.osaka_cidr
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_drg.seoul_drg.id
  }

  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_internet_gateway.seoul_internet_gateway.id
  }
}

resource "oci_core_security_list" "seoul_security_list" {
  provider       = oci.seoul
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.seoul_vcn.id
  display_name   = "seoulSecurityList"

  egress_security_rules {
    destination = var.osaka_cidr
    protocol    = "all"
  }

  ingress_security_rules {
    protocol = "all"
    source   = var.osaka_cidr
  }

  ingress_security_rules {
    protocol = 6
    source   = "0.0.0.0/0"

    tcp_options {
      max = 22
      min = 22
    }
  }
}

data "oci_identity_availability_domain" "seoul_ad" {
  provider       = oci.seoul
  compartment_id = var.tenancy_ocid
  ad_number      = 1
}

resource "oci_core_subnet" "seoul_subnet" {
  provider            = oci.seoul
  availability_domain = data.oci_identity_availability_domain.seoul_ad.name
  cidr_block          = cidrsubnet(var.seoul_cidr, 4, 0)
  display_name        = "seoulSubnet"
  dns_label           = "seoulsubnet"
  compartment_id      = var.compartment_ocid
  vcn_id              = oci_core_vcn.seoul_vcn.id
  security_list_ids   = [oci_core_security_list.seoul_security_list.id]
  route_table_id      = oci_core_route_table.seoul_route_table.id
  dhcp_options_id     = oci_core_vcn.seoul_vcn.default_dhcp_options_id
}

resource "oci_core_instance" "seoul_instance" {
  provider            = oci.seoul
  availability_domain = data.oci_identity_availability_domain.seoul_ad.name
  compartment_id      = var.compartment_ocid
  display_name        = "seoulInstance"

  shape = "VM.Standard2.1"

  create_vnic_details {
    subnet_id        = oci_core_subnet.seoul_subnet.id
    display_name     = "primaryvnic"
    assign_public_ip = true
    hostname_label   = "seoulinstance"
  }

  source_details {
    source_type = "image"
    source_id   = "ocid1.image.oc1.ap-seoul-1.aaaaaaaa4o3toyjhsthdjvrfyjkdtirdmpjmyjrlfar5uxksswtyxc3lpjeq"
  }

  metadata = {
    ssh_authorized_keys = file(var.ssh_public_key)
  }
}
