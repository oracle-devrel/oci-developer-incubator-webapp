## ------- Virtual Cloud Network -------- ##

resource oci_core_vcn oke-vcn {
  cidr_blocks = [
    var.oke_vcn_cidr_blocks,
  ]
  compartment_id = var.compartment_ocid
  display_name = "${var.resource_naming_prefix}-oke-vcn"
  dns_label    = "okecluster"
}

## ------- Internet Gateway -------- ##

resource oci_core_internet_gateway oke-igw {
  compartment_id = var.compartment_ocid
  display_name = "${var.resource_naming_prefix}-oke-igw"
  vcn_id = oci_core_vcn.oke-vcn.id
}

## ------- Service Gateway ------- ##
resource oci_core_service_gateway oke-sgw {
  compartment_id = var.compartment_ocid
  display_name = "${var.resource_naming_prefix}-oke-sgw"
  services {
    service_id = data.oci_core_services.all_services.services.0.id
  }
  vcn_id = oci_core_vcn.oke-vcn.id
}

## ------- NAT Gateway ------- ##
resource oci_core_nat_gateway oke-ngw {
  compartment_id = var.compartment_ocid
  display_name = "${var.resource_naming_prefix}-oke-ngw"
  vcn_id       = oci_core_vcn.oke-vcn.id
}

## ------- Default Public Route Table ------- ##
resource oci_core_default_route_table oke-public-routetable {
  compartment_id = var.compartment_ocid
  display_name = "Default Route Table for oke"
  manage_default_resource_id = oci_core_vcn.oke-vcn.default_route_table_id
  route_rules {
    description       = "traffic to/from internet"
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_internet_gateway.oke-igw.id
  }
}

## ------- Private Route Table ------- ##
resource oci_core_route_table oke-private-routetable {
  compartment_id = var.compartment_ocid
  display_name = "Private Route Table for oke"
  route_rules {
    description       = "traffic to the internet"
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_nat_gateway.oke-ngw.id
  }
  route_rules {
    description       = "traffic to OCI services"
    destination       = data.oci_core_services.all_services.services.0.cidr_block
    destination_type  = "SERVICE_CIDR_BLOCK"
    network_entity_id = oci_core_service_gateway.oke-sgw.id
  }
  vcn_id = oci_core_vcn.oke-vcn.id
}

## ----- OKE Subnets and Security Lists ----- ##

resource oci_core_subnet oke-k8sapiendpoint-subnet {
  cidr_block = var.oke_k8sapiendpoint_subnet_cidr_block
  compartment_id = var.compartment_ocid
  vcn_id = oci_core_vcn.oke-vcn.id
  display_name = "${var.resource_naming_prefix}-oke-k8sapiendpoint-subnet"
  route_table_id =  oci_core_default_route_table.oke-public-routetable.id
  security_list_ids = [oci_core_security_list.oke-k8sapiendpoint-sl.id]
}

resource oci_core_subnet oke-service_lb-subnet {
  cidr_block = var.oke_service_lb_subnet_cidr_block
  compartment_id = var.compartment_ocid
  vcn_id = oci_core_vcn.oke-vcn.id
  display_name = "${var.resource_naming_prefix}-oke-service_lb-subnet"
  route_table_id = oci_core_default_route_table.oke-public-routetable.id
  security_list_ids = [oci_core_security_list.oke-service_lb-sl.id]
}

resource oci_core_subnet oke-nodepool-subnet {
  cidr_block = var.oke_nodepool_cidr_block
  compartment_id = var.compartment_ocid
  vcn_id = oci_core_vcn.oke-vcn.id
  display_name = "${var.resource_naming_prefix}-oke-nodepool-subnet"
  route_table_id = oci_core_route_table.oke-private-routetable.id
  security_list_ids = [oci_core_security_list.oke-nodepool-sl.id]
  prohibit_internet_ingress = "true"
  prohibit_public_ip_on_vnic = "true"
}

resource oci_core_security_list oke-k8sapiendpoint-sl {
  compartment_id = var.compartment_ocid
  vcn_id = oci_core_vcn.oke-vcn.id
  display_name = "${var.resource_naming_prefix}-oke-k8sapiendpoint-sl"
  
  egress_security_rules {
		description = "Allow Kubernetes Control Plane to communicate with OKE"
		destination = data.oci_core_services.all_services.services.0.cidr_block
		destination_type = "SERVICE_CIDR_BLOCK"
		protocol = "6"
		stateless = "false"
	}
	egress_security_rules {
		description = "All traffic to worker nodes"
		destination = var.oke_nodepool_cidr_block
		destination_type = "CIDR_BLOCK"
		protocol = "6"
		stateless = "false"
	}
	egress_security_rules {
		description = "Path discovery"
		destination = var.oke_nodepool_cidr_block
		destination_type = "CIDR_BLOCK"
		icmp_options {
			code = "4"
			type = "3"
		}
		protocol = "1"
		stateless = "false"
	}
	ingress_security_rules {
		description = "External access to Kubernetes API endpoint"
		protocol = "6"
		source = "0.0.0.0/0"
		stateless = "false"
	}
	ingress_security_rules {
		description = "Kubernetes worker to Kubernetes API endpoint communication"
		protocol = "6"
		source = var.oke_nodepool_cidr_block
		stateless = "false"
	}
	ingress_security_rules {
		description = "Kubernetes worker to control plane communication"
		protocol = "6"
		source = var.oke_nodepool_cidr_block
		stateless = "false"
	}
	ingress_security_rules {
		description = "Path discovery"
		icmp_options {
			code = "4"
			type = "3"
		}
		protocol = "1"
		source = var.oke_nodepool_cidr_block
		stateless = "false"
	}
}

resource oci_core_security_list oke-service_lb-sl {
  compartment_id = var.compartment_ocid
  vcn_id = oci_core_vcn.oke-vcn.id
  display_name = "${var.resource_naming_prefix}-oke-service_lb-sl"

  egress_security_rules {
	  description = "Allow all traffic"
	  destination = "0.0.0.0/0"
	  protocol = "all"
	  stateless = "false"
  }

  ingress_security_rules {
	  description = "Allow all traffic"
	  source = "0.0.0.0/0"
	  protocol = "all"
	  stateless = "false"
  }
}

resource oci_core_security_list oke-nodepool-sl {
  compartment_id = var.compartment_ocid
  vcn_id = oci_core_vcn.oke-vcn.id
  display_name = "${var.resource_naming_prefix}-oke-nodepool-sl"

  egress_security_rules {
		description = "Allow pods on one worker node to communicate with pods on other worker nodes"
		destination = var.oke_nodepool_cidr_block
		destination_type = "CIDR_BLOCK"
		protocol = "all"
		stateless = "false"
	}
	egress_security_rules {
		description = "Access to Kubernetes API Endpoint"
		destination = oci_core_subnet.oke-k8sapiendpoint-subnet.cidr_block
		destination_type = "CIDR_BLOCK"
		protocol = "6"
		stateless = "false"
    tcp_options {
      max = "6443"
      min = "6443"
      source_port_range {
        max = "65535"
        min = "1"
      }
    }
	}
	egress_security_rules {
		description = "Kubernetes worker to control plane communication"
		destination = oci_core_subnet.oke-k8sapiendpoint-subnet.cidr_block
		destination_type = "CIDR_BLOCK"
		protocol = "6"
		stateless = "false"
    tcp_options {
      max = "12250"
      min = "12250"
      source_port_range {
        max = "65535"
        min = "1"
      }
    }
	}
	egress_security_rules {
		description = "Path discovery"
		destination = oci_core_subnet.oke-k8sapiendpoint-subnet.cidr_block
		destination_type = "CIDR_BLOCK"
		icmp_options {
			code = "4"
			type = "3"
		}
		protocol = "1"
		stateless = "false"
	}
	egress_security_rules {
		description = "Allow nodes to communicate with OKE to ensure correct start-up and continued functioning"
		destination = data.oci_core_services.all_services.services.0.cidr_block
		destination_type = "SERVICE_CIDR_BLOCK"
		protocol = "6"
		stateless = "false"
    tcp_options {
      max = "443"
      min = "443"
      source_port_range {
        max = "65535"
        min = "1"
      }
    }
	}
	egress_security_rules {
		description = "ICMP Access from Kubernetes Control Plane"
		destination = "0.0.0.0/0"
		destination_type = "CIDR_BLOCK"
		icmp_options {
			code = "4"
			type = "3"
		}
		protocol = "1"
		stateless = "false"
	}
	egress_security_rules {
		description = "Worker Nodes access to Internet"
		destination = "0.0.0.0/0"
		destination_type = "CIDR_BLOCK"
		protocol = "all"
		stateless = "false"
	}
	ingress_security_rules {
		description = "Allow pods on one worker node to communicate with pods on other worker nodes"
		protocol = "all"
		source = var.oke_nodepool_cidr_block
		stateless = "false"
	}
	ingress_security_rules {
		description = "Path discovery"
		icmp_options {
			code = "4"
			type = "3"
		}
		protocol = "1"
		source = oci_core_subnet.oke-k8sapiendpoint-subnet.cidr_block
		stateless = "false"
	}
	ingress_security_rules {
		description = "TCP access from Kubernetes Control Plane"
		protocol = "6"
		source = oci_core_subnet.oke-k8sapiendpoint-subnet.cidr_block
		stateless = "false"
	}
	ingress_security_rules {
		description = "Inbound SSH traffic to worker nodes"
		protocol = "6"
		source = "0.0.0.0/0"
		stateless = "false"
    tcp_options {
      max = "22"
      min = "22"
      source_port_range {
        max = "65535"
        min = "1"
      }
    }
	}
}