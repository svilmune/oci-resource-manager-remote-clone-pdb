########################################
#   Variables required for Remote Cloning
#--------------------------------------#

variable "compartment_name_source" {
  default = "MySourceCompartment"
}

variable "compartment_name_dest" {
  default = "MyDestCompartment"
}

variable "db_source_name" {
  default = "MySourceDB"
}

variable "db_dest_name" {
  default = "MyDestDB"
}

variable "db_source_pdb_name" {
  default = "MySourcePDB"
}

variable "db_dest_pdb_name" {
  default = "MyDestPDB"
}

variable "source_container_db_admin_password" {
  default = "MyCDBPass"
}

// For destination PDB
variable "pdb_admin_password" {
  default = "MyPDBPass"
}

// For Destination
variable "target_tde_wallet_password" {
  default = "MyTDEPass"
}

// Ansible Playbook to delete existing PDB
variable "playbook_path" {
  default = "./delete_pdb.yaml"
}
