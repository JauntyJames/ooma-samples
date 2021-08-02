# Output the "list" of all availability domains.
output "all-availability-domains-in-your-tenancy" {
  value = data.oci_identity_availability_domains.ads.availability_domains
}

output "name-of-first-availability-domain" {
  value = data.oci_identity_availability_domains.ads.availability_domains[0].name
}

# Outputs for compartment
output "compartment-name" {
  value = oci_identity_compartment.tf-compartment.name
}

output "compartment-OCID" {
  value = oci_identity_compartment.tf-compartment.id
}

# Outputs for compute instance
/*
output "public-ip-for-compute-instance" {
  value = oci_core_instance.ubuntu_instance[0].public_ip
}

output "instance-name" {
  value = oci_core_instance.ubuntu_instance[0].display_name
}

output "instance-OCID" {
  value = oci_core_instance.ubuntu_instance[0].id
}

output "instance-region" {
  value = oci_core_instance.ubuntu_instance[0].region
}

output "instance-shape" {
  value = oci_core_instance.ubuntu_instance[0].shape
}

output "instance-state" {
  value = oci_core_instance.ubuntu_instance[0].state
}

output "instance-OCPUs" {
  value = oci_core_instance.ubuntu_instance[0].shape_config[0].ocpus
}

output "instance-memory-in-GBs" {
  value = oci_core_instance.ubuntu_instance[0].shape_config[0].memory_in_gbs
}

output "time-created" {
  value = oci_core_instance.ubuntu_instance[0].time_created
}
*/
# Outputs for the vcn module

output "vcn_id" {
  description = "OCID of the VCN that is created"
  value       = module.vcn.vcn_id
}
output "id-for-route-table-that-includes-the-internet-gateway" {
  description = "OCID of the internet-route table. This route table has an internet gateway to be used for public subnets"
  value       = module.vcn.ig_route_id
}
output "nat-gateway-id" {
  description = "OCID for NAT gateway"
  value       = module.vcn.nat_gateway_id
}
output "id-for-for-route-table-that-includes-the-nat-gateway" {
  description = "OCID of the nat-route table - This route table has a nat gateway to be used for private subnets. This route table also has a service gateway."
  value       = module.vcn.nat_route_id
}

# Outputs for private security list

output "private-security-list-name" {
  value = oci_core_security_list.private-security-list.display_name
}
output "private-security-list-OCID" {
  value = oci_core_security_list.private-security-list.id
}


# Outputs for public security list

output "public-security-list-name" {
  value = oci_core_security_list.public-security-list.display_name
}
output "public-security-list-OCID" {
  value = oci_core_security_list.public-security-list.id
}


# Outputs for private subnet

output "private-subnet-name" {
  value = oci_core_subnet.vcn-private-subnet.display_name
}
output "private-subnet-OCID" {
  value = oci_core_subnet.vcn-private-subnet.id
}


# Outputs for public subnet

output "public-subnet-name" {
  value = oci_core_subnet.vcn-public-subnet.display_name
}
output "public-subnet-OCID" {
  value = oci_core_subnet.vcn-public-subnet.id
}

#dns_a_record_set#argument-reference
data "dns_a_record_set" "google" {
  host = "google.com"
}

output "google_addrs" {
  value = join(",", data.dns_a_record_set.google.addrs)
}
