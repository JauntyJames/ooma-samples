// Copyright (c) 2017, 2021, Oracle and/or its affiliates. All rights reserved.
// Licensed under the Mozilla Public License v2.0
//

resource "oci_core_instance" "ubuntu_instance" {
  count = 1
  # Required
  availability_domain = data.oci_identity_availability_domains.ads.availability_domains[0].name
  compartment_id      = oci_identity_compartment.tf-compartment.id
  shape               = "VM.Standard.E4.Flex"

  shape_config {
    ocpus         = 1
    memory_in_gbs = 4
  }
  source_details {
    source_id   = "ocid1.image.oc1.iad.aaaaaaaafjeywk4pmink5lmvhbfwzshlb4skyh74zd3qbberxex4fdkpg62a"
    source_type = "image"
  }

  # Optional
  display_name = "ubuntu_instance${count.index + 1}"
  create_vnic_details {
    assign_public_ip = false
    subnet_id        = oci_core_subnet.vcn-public-subnet.id
  }
  metadata = {
    ssh_authorized_keys = file("/Users/jphartma/.ssh/id_rsa.pub")
  }
  preserve_boot_volume = false
  # provisioner "file" {
  #   source      = "vnic.sh"
  #   destination = "/tmp/vnic.sh"
  #   connection {
  #     type     = "ssh"
  #     user     = "ubuntu"
  #     host     = oci_core_instance.ubuntu_instance.public_ip
  #     private_key = file("/Users/jphartma/.ssh/id_rsa")
  #   }
  # }

  # provisioner "remote-exec" {
  #   inline = [
  #     "chmod +x /tmp/vnic.sh",
  #     "/tmp/vnic.sh -c",
  #   ]
  # }
}

resource "oci_core_vnic_attachment" "eth1_attachment" {
  instance_id = oci_core_instance.ubuntu_instance[0].id
  display_name = "eth1Attachment"

  create_vnic_details {
    subnet_id = oci_core_subnet.vcn-public-subnet.id
    display_name = "eth1"
    assign_public_ip = false
    skip_source_dest_check = false
    private_ip = "10.0.0.50"
  }
}

data "oci_core_vnic" "eth1" {
  vnic_id = oci_core_vnic_attachment.eth1_attachment.vnic_id
}

data "oci_core_private_ips" "eth1_private_ips" {
  vnic_id = data.oci_core_vnic.eth1.id
}

resource "oci_core_public_ip" "test_public_ip" {
  #Required
  compartment_id = oci_identity_compartment.tf-compartment.id
  lifetime       = "RESERVED"

  #Optional
  private_ip_id = data.oci_core_private_ips.eth1_private_ips.private_ips[0].id
}

data "oci_core_vnic_attachments" "instance_vnics" {
  compartment_id      = oci_identity_compartment.tf-compartment.id
  availability_domain = data.oci_identity_availability_domains.ads.availability_domains[0].name
  instance_id         = oci_core_instance.ubuntu_instance[0].id
}



# resource "oci_core_vnic_attachment" "eth0_attachment" {
#      instance_id = oci_core_instance.ubuntu_instance.id
#      display_name = "eth0Attachment"

#      create_vnic_details {
#         subnet_id       = oci_core_subnet.vcn-private-subnet.id
#         display_name        = "eth0"
#         assign_public_ip    = false
#         skip_source_dest_check  = false
#         private_ip      = "10.0.1.50"
#     }
# }

# data "oci_core_vnic" "eth0" {
#      vnic_id = oci_core_vnic_attachment.eth0_attachment.vnic_id
# }
