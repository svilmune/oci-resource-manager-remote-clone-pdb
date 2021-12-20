variable "tenancy_ocid" {}
variable "region" {}

provider "oci" {
  tenancy_ocid = var.tenancy_ocid
  region = var.region
}

########################################
#   Get variables for Source Database
#--------------------------------------#

// Get the compartment for Source Database
data "oci_identity_compartments" "source" {
    compartment_id = var.tenancy_ocid
    compartment_id_in_subtree = true
    filter {
    name   = "name"
    values = [var.compartment_name_source]
    }
}

// Get the DB System info using compartment and display name
data "oci_database_db_systems" "source" {
   compartment_id = data.oci_identity_compartments.source.compartments.0.id
    display_name = var.db_source_name
}


// Get DB Home information using DB System info
data "oci_database_db_homes" "source" {
    compartment_id = data.oci_identity_compartments.source.compartments.0.id
    db_system_id = data.oci_database_db_systems.source.db_systems.0.id
}


// Get DB information using DB Home info
data "oci_database_databases" "source" {
    compartment_id = data.oci_identity_compartments.source.compartments.0.id
    system_id = data.oci_database_db_systems.source.db_systems.0.id
    db_home_id = data.oci_database_db_homes.source.db_homes.0.id
}

// Get Pluggable DB information using DB information and PDB name
data "oci_database_pluggable_databases" "source" {
    database_id = data.oci_database_databases.source.databases.0.id
    pdb_name = var.db_source_pdb_name
}

########################################
#   Get variables for Destination Database
#--------------------------------------#

// Get the compartment for Destination Database
data "oci_identity_compartments" "dest" {
    compartment_id = var.tenancy_ocid
    compartment_id_in_subtree = true
    filter {
    name   = "name"
    values = [var.compartment_name_dest]
    }
}

// Get the DB System info using compartment and display name
data "oci_database_db_systems" "dest" {
    compartment_id = data.oci_identity_compartments.dest.compartments.0.id
    display_name = var.db_dest_name
}

// Get DB Home information using DB System info
data "oci_database_db_homes" "dest" {
    compartment_id = data.oci_identity_compartments.dest.compartments.0.id
    db_system_id = data.oci_database_db_systems.dest.db_systems.0.id
}

// Get DB information using DB Home info
data "oci_database_databases" "dest" {
    compartment_id = data.oci_identity_compartments.dest.compartments.0.id
    system_id = data.oci_database_db_systems.dest.db_systems.0.id
    db_home_id = data.oci_database_db_homes.dest.db_homes.0.id
}

// Get Pluggable DB information using DB information and PDB name so PDB can be deleted in destination
data "oci_database_pluggable_databases" "dest" {
    database_id = data.oci_database_databases.dest.databases.0.id
    pdb_name = var.db_dest_pdb_name
    state = "AVAILABLE" // Only take available databases
}

locals {
   // Taking all existing PDB OCIDs to a local variable
    dest_pdb_ids = {for k, v in data.oci_database_pluggable_databases.dest.pluggable_databases : k => v.id}
    source_pdb_ids = {for k, v in data.oci_database_pluggable_databases.source.pluggable_databases : k => v.id}
}

resource "null_resource" "delete_pdb" {
     // Force null resource to run always via trigger
    triggers = {
        always_run = timestamp()
    }
    for_each = local.dest_pdb_ids // Using for_each to do this only if pluggable database exists in destination with same name
    provisioner "local-exec" {
            command = "ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook --extra-vars 'pluggable_database_id=${each.value}'  ${var.playbook_path}"
  }
}

########################################
#   Create Remote Clone
#--------------------------------------#

// This will fail if PDB exists with the same name.. hence deleting it above if we use the same name with existing PDB
resource "oci_database_pluggable_databases_remote_clone" "this" {
    cloned_pdb_name = var.db_dest_pdb_name
    pluggable_database_id = data.oci_database_pluggable_databases.source.pluggable_databases.0.id
    source_container_db_admin_password = var.source_container_db_admin_password
    target_container_database_id = data.oci_database_databases.dest.databases.0.id
    pdb_admin_password = var.pdb_admin_password 
    should_pdb_admin_account_be_locked = false
    target_tde_wallet_password = var.target_tde_wallet_password 

    depends_on = [null_resource.delete_pdb] // Let's wait that the existing PDB is deleted first
}
