# Remote Clone Oracle Database PDB via OCI Resource Manager

Easy way to start cloning your PDB's with Oracle Database to other Container Databases using OCI Resource Manager. The Stack takes care on deleting existing PDB with same name in the destination using Ansible which is integrated with OCI Resource Manager.

You need to modify variables accordingly to match your environment and have source and destination databases created. 

Modify values either in the variables.tf file or provide them during stack execution.

STACK MUST BE DESTROYED AFTER EACH RUN. This is due to Terraform keeping state of the clone operation always and not updating it with the deleted destination.

## Required Variables

| Variable      | Purpose |
| ----------- | ----------- |
| compartment_name_source      | Source Database compartment       |
| compartment_name_dest   | Destination Database compartment        |
| db_source_name  | Source Database name  |
| db_dest_name  | Destination Database name  |
| db_source_pdb_name  |  Source PDB name  |
| db_dest_pdb_name  | Destination PDB name  |
| source_container_db_admin_password  | Source CDB Admin Password  |
| pdb_admin_password  | Admin Password for the new PDB  |
| target_tde_wallet_password  | TDE Password on target database  |
| playbook_path  | Path for the Ansible   |

## Removal of stack

In case you want to remove created resources run Destroy for the stack. This is needed for any additional clones to same destination using same existing stack.

## TO-DO

* Investigate possibility to use Ansible to clone PDB instead of Terraform so stack could be run without destroying it first. Initial tests failed with this.

