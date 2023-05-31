resource "oci_core_instance" "mysql_instance" {
	agent_config {
		is_management_disabled = "false"
		is_monitoring_disabled = "false"
		plugins_config {
			desired_state = "ENABLED"
			name = "OS Management Service Agent"
		}
		plugins_config {
			desired_state = "ENABLED"
			name = "Custom Logs Monitoring"
		}
		plugins_config {
			desired_state = "ENABLED"
			name = "Compute Instance Run Command"
		}
		plugins_config {
			desired_state = "ENABLED"
			name = "Compute Instance Monitoring"
		}
		plugins_config {
			desired_state = "ENABLED"
			name = "Bastion"
		}
	}
	availability_config {
		recovery_action = "RESTORE_INSTANCE"
	}
	availability_domain = data.oci_identity_availability_domain.AD-1.name
	compartment_id = var.compartment_ocid
	create_vnic_details {
		assign_private_dns_record = "true"
		assign_public_ip = "false"
		subnet_id = oci_core_subnet.oke-nodepool-subnet.id
		private_ip = "10.1.2.126"
	}
	display_name = "${var.resource_naming_prefix}-mysql-instance"
	instance_options {
		are_legacy_imds_endpoints_disabled = "false"
	}
    metadata = {
		"ssh_authorized_keys" = var.ssh_public_key
	}
	shape = "VM.Standard.E4.Flex"
	shape_config {
		memory_in_gbs = "4"
		ocpus = "1"
	}
	source_details {
		source_id = var.image_os_id
		source_type = "image"
	}
}