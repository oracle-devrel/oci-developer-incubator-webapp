## Container Registry ##

resource oci_artifacts_container_repository nginx_reg {
    compartment_id = var.compartment_ocid
    display_name = "webapp/nginx"
    is_public = "true"
}

resource oci_artifacts_container_repository php_reg {
    compartment_id = var.compartment_ocid
    display_name = "webapp/php"
    is_public = "true"
}