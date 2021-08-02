# Source from https://registry.terraform.io/providers/hashicorp/oci/latest/docs/resources/core_dhcp_options

resource "oci_core_dhcp_options" "dhcp-options" {

  # Required
  compartment_id = oci_identity_compartment.tf-compartment.id
  vcn_id         = module.vcn.vcn_id
  #Options for type are either "DomainNameServer" or "SearchDomain"
  options {
    type        = "DomainNameServer"
    server_type = "VcnLocalPlusInternet"
  }

  # Optional
  display_name = "default-dhcp-options"
}
