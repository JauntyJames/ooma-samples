module "vcn" {
  source  = "oracle-terraform-modules/vcn/oci"
  version = "2.3.0"
  # insert the 7 required variables here

  # Required
  compartment_id = oci_identity_compartment.tf-compartment.id

  region        = "us-ashburn-1"
  vcn_name      = "tf-vcn"
  vcn_dns_label = "tfvcn"

  # Optional
  internet_gateway_enabled = true
  nat_gateway_enabled      = true
  service_gateway_enabled  = true
  vcn_cidr                 = "10.0.0.0/16"
}
