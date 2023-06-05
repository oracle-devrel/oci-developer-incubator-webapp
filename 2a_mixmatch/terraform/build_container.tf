## Build Containers ##

resource null_resource build-nginx {
    depends_on = [oci_artifacts_container_repository.nginx_reg]
    provisioner "local-exec" {
        command = "docker login ${var.region_key}.ocir.io -u ${var.ocir_username} -p '${var.ocir_password}' "
    }

    provisioner "local-exec" {
        command = "docker build -t ${var.region_key}.ocir.io/${data.oci_objectstorage_namespace.os_namespace.namespace}/webapp/nginx:1.0 ."
        working_dir = "src/nginx"
    }

    provisioner "local-exec" {
        command = "docker push ${var.region_key}.ocir.io/${data.oci_objectstorage_namespace.os_namespace.namespace}/webapp/nginx:1.0"
        working_dir = "src/nginx"
    }
}

resource null_resource build-php {
    depends_on = [oci_artifacts_container_repository.php_reg]
    provisioner "local-exec" {
        command = "docker login ${var.region_key}.ocir.io -u ${var.ocir_username} -p '${var.ocir_password}' "
    }

    provisioner "local-exec" {
        command = "docker build -t ${var.region_key}.ocir.io/${data.oci_objectstorage_namespace.os_namespace.namespace}/webapp/php:1.0 ."
        working_dir = "src/php"
    }

    provisioner "local-exec" {
        command = "docker push ${var.region_key}.ocir.io/${data.oci_objectstorage_namespace.os_namespace.namespace}/webapp/php:1.0"
        working_dir = "src/php"
    }
}