resource "oci_bastion_bastion" "oci_bastion" {
	bastion_type = "standard"
	client_cidr_block_allow_list = ["0.0.0.0/0"]
	compartment_id = var.compartment_ocid
	max_session_ttl_in_seconds = "3600"
	name = "${var.resource_naming_prefix}-bastion"
	target_subnet_id = oci_core_subnet.oke-service_lb-subnet.id
}

resource "time_sleep" "wait_60_seconds" {
    depends_on = [oci_mysql_mysql_db_system.mysql_db]
    create_duration = "60s"
}

resource "oci_bastion_session" "oci_bastion_session" {
    depends_on = [time_sleep.wait_60_seconds]
    #Required
    bastion_id = oci_bastion_bastion.oci_bastion.id
    key_details {
        #Required
        public_key_content = var.ssh_public_key
    }
    target_resource_details {
        #Required
        session_type = "PORT_FORWARDING"
        target_resource_port = "3306"
        target_resource_private_ip_address = oci_mysql_mysql_db_system.mysql_db.ip_address
    }

    #Optional
    display_name = "${var.resource_naming_prefix}-bastion-mysql-session"
    key_type = "PUB"
    session_ttl_in_seconds = "3600"
}

output "bastion_url" {
    value = "https://cloud.oracle.com/security/bastion/bastions/${oci_bastion_bastion.oci_bastion.id}"
}