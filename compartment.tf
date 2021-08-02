
resource "oci_identity_compartment" "tf-compartment" {
  # Required
  compartment_id = "ocid1.compartment.oc1..aaaaaaaaimkkwohq4ly6ynh3unja2xbnpj5gmv7mfxe4kvgm72xhgrlyj5ua"
  description    = "Compartment for Terraform resources."
  name           = "tfcompartment"
}
