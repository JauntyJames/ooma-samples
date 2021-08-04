data "oci_core_vcn_dns_resolver_association" "private_dns_resolver_association" {
  vcn_id = module.vcn.vcn_id
}

data "oci_dns_resolver" "private_dns_resolver" {
  resolver_id = data.oci_core_vcn_dns_resolver_association.private_dns_resolver_association.dns_resolver_id
  scope       = "PRIVATE"
}

resource oci_dns_zone "private_dns" {
    compartment_id = var.compartment_ocid
    name = "private-dns.xyz"
    zone_type = "PRIMARY"
    scope = "PRIVATE"
    view_id = data.oci_dns_resolver.private_dns_resolver.default_view_id
}


output "private_dns_assocation" {
  value = data.oci_core_vcn_dns_resolver_association.private_dns_resolver_association.dns_resolver_id
}

output "private_dns_resolver" {
  value = data.oci_dns_resolver.private_dns_resolver.default_view_id
}

resource "oci_dns_rrset" "test_rrset_private_ptr" {
    domain = oci_dns_zone.private_dns.name
    rtype  = "PTR"
    zone_name_or_id = oci_dns_zone.private_dns.id

    items {
        domain = oci_dns_zone.private_dns.name
        rdata  = "10.0.1.1"
        rtype  = "PTR"
        ttl    = "1800"
    }
    scope = "PRIVATE"
    view_id = data.oci_dns_resolver.private_dns_resolver.default_view_id
}
