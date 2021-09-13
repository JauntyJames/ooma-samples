

variable "osaka_name" {
  default = "ap-osaka-1"
}

variable "osaka_cidr" {
  default = "10.1.0.0/16"
}

provider "oci" {
  alias            = "osaka"
  region           = var.osaka_name
  tenancy_ocid     = var.tenancy_ocid
  user_ocid        = var.user_ocid
  fingerprint      = var.fingerprint
  private_key_path = var.private_key_path
}

resource "oci_core_vcn" "osaka_vcn" {
  provider       = oci.osaka
  display_name   = "osaka_vcn"
  dns_label      = "osakavcn"
  cidr_block     = var.osaka_cidr
  compartment_id = var.compartment_ocid
}

resource "oci_core_drg" "osaka_drg" {
  provider       = oci.osaka
  compartment_id = var.compartment_ocid
}

resource "oci_core_drg_attachment" "osaka_drg_attachment" {
  provider = oci.osaka
  drg_id   = oci_core_drg.osaka_drg.id
  vcn_id   = oci_core_vcn.osaka_vcn.id
}

resource "oci_core_remote_peering_connection" "osaka" {
  provider       = oci.osaka
  compartment_id = var.compartment_ocid
  drg_id         = oci_core_drg.osaka_drg.id
  display_name   = "remotePeeringConnectionOsaka"
}

resource "oci_core_internet_gateway" "osaka_internet_gateway" {
  provider       = oci.osaka
  compartment_id = var.compartment_ocid
  display_name   = "osaka_internet_gateway"
  vcn_id         = oci_core_vcn.osaka_vcn.id
}

resource "oci_core_route_table" "osaka_route_table" {
  provider       = oci.osaka
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.osaka_vcn.id
  display_name   = "osakaRouteTable"

  route_rules {
    destination       = var.seoul_cidr
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_drg.osaka_drg.id
  }

  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_internet_gateway.osaka_internet_gateway.id
  }
}

resource "oci_core_security_list" "osaka_security_list" {
  provider       = oci.osaka
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.osaka_vcn.id
  display_name   = "osakaSecurityList"

  egress_security_rules {
    destination = var.seoul_cidr
    protocol    = "all"
  }

  ingress_security_rules {
    protocol = "all"
    source   = var.seoul_cidr
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

data "oci_identity_availability_domain" "osaka_ad" {
  provider       = oci.osaka
  compartment_id = var.tenancy_ocid
  ad_number      = 1
}

resource "oci_core_subnet" "osaka_subnet" {
  provider            = oci.osaka
  availability_domain = data.oci_identity_availability_domain.osaka_ad.name
  cidr_block          = cidrsubnet(var.osaka_cidr, 4, 0)
  display_name        = "osakaSubnet"
  dns_label           = "osakasubnet"
  compartment_id      = var.compartment_ocid
  vcn_id              = oci_core_vcn.osaka_vcn.id
  security_list_ids   = [oci_core_security_list.osaka_security_list.id]
  route_table_id      = oci_core_route_table.osaka_route_table.id
  dhcp_options_id     = oci_core_vcn.osaka_vcn.default_dhcp_options_id
}

resource "oci_core_instance" "osaka_instance" {
  provider            = oci.osaka
  availability_domain = data.oci_identity_availability_domain.osaka_ad.name
  compartment_id      = var.compartment_ocid
  display_name        = "osakaInstance"
  shape               = "VM.Standard2.1"

  create_vnic_details {
    subnet_id        = oci_core_subnet.osaka_subnet.id
    display_name     = "primaryvnic"
    assign_public_ip = true
    hostname_label   = "osakainstance"
  }

  source_details {
    source_type = "image"
    source_id   = "ocid1.image.oc1.ap-osaka-1.aaaaaaaapw2rsmoz2xwboou3me2bousxqvfowam7eh4vmmhssfctbtzf5mza"
  }

  metadata = {
    ssh_authorized_keys = file(var.ssh_public_key)
  }
}
