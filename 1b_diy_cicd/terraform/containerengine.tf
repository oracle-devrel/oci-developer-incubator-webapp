##----- OKE Cluster -----##

resource oci_containerengine_cluster oke-cluster {
  compartment_id = var.compartment_ocid
  endpoint_config {
    is_public_ip_enabled = "true"
    subnet_id = oci_core_subnet.oke-k8sapiendpoint-subnet.id
  }
  image_policy_config {
    is_policy_enabled = "false"
  }
  cluster_pod_network_options {
    cni_type = "FLANNEL_OVERLAY"
  }
  kubernetes_version = var.kubernetes_version
  name               = "${var.resource_naming_prefix}-oke-cluster"
  options {
    admission_controller_options {
      is_pod_security_policy_enabled = "false"
    }
    kubernetes_network_config {
      pods_cidr     = "10.244.0.0/16"
      services_cidr = "10.96.0.0/16"
    }
    service_lb_subnet_ids = [
      oci_core_subnet.oke-service_lb-subnet.id
    ]
  }
  vcn_id = oci_core_vcn.oke-vcn.id
  type = "BASIC_CLUSTER"
}

## ----- OKE Node Pool ----- ##

resource oci_containerengine_node_pool oke-pool1 {
  cluster_id     = oci_containerengine_cluster.oke-cluster.id
  compartment_id = var.compartment_ocid
  initial_node_labels {
    key   = "name"
    value = "oke-cluster"
  }
  kubernetes_version = var.kubernetes_version
  name               = "oke-pool1"
  node_config_details {
    nsg_ids = [
    ]
    placement_configs {
      availability_domain = data.oci_identity_availability_domain.AD-1.name
      subnet_id           = oci_core_subnet.oke-nodepool-subnet.id
    }
    # placement_configs {
    #   availability_domain = data.oci_identity_availability_domain.AD-2.name
    #   subnet_id           = oci_core_subnet.oke-nodepool-subnet.id
    # }
    # placement_configs {
    #   availability_domain = data.oci_identity_availability_domain.AD-3.name
    #   subnet_id           = oci_core_subnet.oke-nodepool-subnet.id
    # }
    size = "2"
  }
  node_metadata = {
  }
  node_shape = var.node_shape
  node_shape_config {
    memory_in_gbs = var.shape_mems
    ocpus         = var.shape_ocpus
  }
  node_source_details {
    image_id    = var.image_os_id
    source_type = "IMAGE"
  }
  ssh_public_key = var.ssh_public_key
}

