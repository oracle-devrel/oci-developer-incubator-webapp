resource "oci_mysql_mysql_db_system" "mysql_db" {
	admin_password = var.mysql_admin_password
	admin_username = var.mysql_admin_username
	availability_domain = data.oci_identity_availability_domain.AD-1.name
	backup_policy {
		is_enabled = "true"
		pitr_policy {
			is_enabled = "true"
		}
		retention_in_days = "7"
	}
	compartment_id = var.compartment_ocid
	crash_recovery = "ENABLED"
	data_storage_size_in_gb = "50"
	deletion_policy {
		automatic_backup_retention = "DELETE"
		final_backup = "SKIP_FINAL_BACKUP"
		is_delete_protected = "false"
	}
	display_name = "mysql_db"
	freeform_tags = {
		"Template" = "Development or testing"
	}
	port = "3306"
	port_x = "33060"
	shape_name = "MySQL.VM.Standard.E4.4.64GB"
	subnet_id = oci_core_subnet.oke-nodepool-subnet.id
	ip_address = "10.1.2.126"
}