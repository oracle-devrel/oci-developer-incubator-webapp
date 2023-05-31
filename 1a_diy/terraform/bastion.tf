resource "oci_bastion_bastion" "oci_bastion" {
	bastion_type = "standard"
	client_cidr_block_allow_list = ["0.0.0.0/0"]
	compartment_id = var.compartment_ocid
	max_session_ttl_in_seconds = "3600"
	name = "${var.resource_naming_prefix}-bastion"
	target_subnet_id = oci_core_subnet.oke-service_lb-subnet.id
}

resource "time_sleep" "wait_180_seconds" {
    depends_on = [oci_core_instance.mysql_instance]
    create_duration = "180s"
}

resource "oci_bastion_session" "oci_bastion_session" {
    depends_on = [time_sleep.wait_180_seconds]
    #Required
    bastion_id = oci_bastion_bastion.oci_bastion.id
    key_details {
        #Required
        public_key_content = var.ssh_public_key
    }
    target_resource_details {
        #Required
        session_type = "MANAGED_SSH"
        target_resource_id = oci_core_instance.mysql_instance.id
        target_resource_operating_system_user_name = "opc"
        target_resource_port = "22"
        target_resource_private_ip_address = oci_core_instance.mysql_instance.private_ip
    }

    #Optional
    display_name = "${var.resource_naming_prefix}-bastion-mysql-session"
    key_type = "PUB"
    session_ttl_in_seconds = "3600"
}

output "bastion_url" {
    value = "https://cloud.oracle.com/security/bastion/bastions/${oci_bastion_bastion.oci_bastion.id}"
}