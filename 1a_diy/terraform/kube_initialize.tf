## Initialize Kubernetes Cluster ##

resource "null_resource" "create_kubeconfig" {
    triggers  =  { 
        always_run = "${timestamp()}" 
    }
    depends_on = [oci_containerengine_node_pool.oke-pool1]
    provisioner "local-exec" {
        command = "oci ce cluster create-kubeconfig --cluster-id ${oci_containerengine_cluster.oke-cluster.id} --file $HOME/.kube/config --region ${var.region} --token-version 2.0.0  --kube-endpoint PUBLIC_ENDPOINT"
        interpreter = [ "/bin/bash","-c"]
    }
}

resource "null_resource" "check_context" {
    triggers  =  { 
        always_run = "${timestamp()}" 
    }
    depends_on = [null_resource.create_kubeconfig]
    provisioner "local-exec" {
        command = "kubectl config current-context"
        interpreter = [ "/bin/bash","-c"]
    }
}

resource "null_resource" "create_namespace" {
    depends_on = [null_resource.check_context]
    provisioner "local-exec" {
        command = "kubectl create namespace cloudnative-webapp"
        interpreter = [ "/bin/bash","-c"]
    }
}

resource "null_resource" "create_mysql_config" {
    depends_on = [null_resource.create_namespace]
    provisioner "local-exec" {
        command = "kubectl apply -f deploy/mysql_config.yml"
        interpreter = [ "/bin/bash","-c"]
    }
}

resource "null_resource" "create_mysql_secret" {
    depends_on = [null_resource.create_namespace]
    provisioner "local-exec" {
        command = "kubectl apply -f deploy/mysql_secret.yml"
        interpreter = [ "/bin/bash","-c"]
    }
}

resource "null_resource" "deploy_webapp_service" {
    depends_on = [null_resource.create_mysql_config, null_resource.create_mysql_secret, null_resource.build-nginx, null_resource.build-php]
    provisioner "local-exec" {
        command = "kubectl apply -f deploy/deploy-webapp.yml"
        interpreter = [ "/bin/bash","-c"]
    }
}

resource "time_sleep" "wait_60_seconds_webapp" {
    depends_on = [null_resource.deploy_webapp_service]
    create_duration = "60s"
}

resource "null_resource" "get_webapp_ip" {
    triggers  =  { 
        always_run = "${timestamp()}" 
    }
    depends_on = [time_sleep.wait_60_seconds_webapp]
    provisioner "local-exec" {
        command = "WEBAPP_IP=$(kubectl get svc nginx -n cloudnative-webapp --no-headers=true | awk -F ' ' '{print $4}') && echo -n 'http://'$WEBAPP_IP':5000/index.php' > data/webapp_url.txt"
        interpreter = [ "/bin/bash","-c"]
    }
}

data "local_file" "webapp_url" {
    depends_on = [null_resource.get_webapp_ip]
    filename = "data/webapp_url.txt" 
}

output "webapp_url" {
    value = data.local_file.webapp_url.content
}