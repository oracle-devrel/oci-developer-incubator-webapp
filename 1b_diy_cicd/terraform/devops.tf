## ----- Project ----- ##
resource "oci_ons_notification_topic" "notification-topic" {
    compartment_id = var.compartment_ocid
    name = "${var.resource_naming_prefix}-notification-topic"
}

resource "oci_devops_project" "devops-project" {
    compartment_id = var.compartment_ocid
    name = "${var.resource_naming_prefix}-devops-project"
    notification_config {
        topic_id = oci_ons_notification_topic.notification-topic.id
    }
    description = "DevOps project for Webapp"
}

## ----- Environment ----- ##
resource "oci_devops_deploy_environment" "oke-environment" {
    project_id = oci_devops_project.devops-project.id
    cluster_id = oci_containerengine_cluster.oke-cluster.id
    deploy_environment_type = "OKE_CLUSTER"
    description = "OKE Environment"
    display_name = "${var.resource_naming_prefix}-oke-environment"
}

## ----- Artifacts ----- ##
resource oci_devops_deploy_artifact k8s-manifest-artifact {
    argument_substitution_mode = "SUBSTITUTE_PLACEHOLDERS"
    deploy_artifact_source {
        deploy_artifact_source_type = "INLINE"
        base64encoded_content = "---\napiVersion: v1\nkind: Service\nmetadata:\n  name: php\n  namespace: cloudnative-webapp\n  labels:\n    tier: app\nspec:\n  ports:\n  - port: 9000\n    protocol: TCP\n  selector:\n    app: php\n    tier: app\n---\napiVersion: v1\nkind: Service\nmetadata:\n  name: nginx\n  namespace: cloudnative-webapp\n  labels:\n    tier: web\n  annotations:\n    oci.oraclecloud.com/load-balancer-type: \"lb\"\n    service.beta.kubernetes.io/oci-load-balancer-shape: \"flexible\"\n    service.beta.kubernetes.io/oci-load-balancer-shape-flex-min: \"10\"\n    service.beta.kubernetes.io/oci-load-balancer-shape-flex-max: \"15\"\nspec:\n  type: LoadBalancer\n  ports:\n  - port: 5000\n  selector:\n    app: nginx\n    tier: web\n---\napiVersion: apps/v1\nkind: Deployment\nmetadata:\n  name: php\n  namespace: cloudnative-webapp\n  labels:\n    tier: app\nspec:\n  replicas: 3\n  selector:\n    matchLabels:\n      app: php\n      tier: app\n  template:\n    metadata:\n      labels:\n        app: php\n        tier: app\n    spec:\n      containers:\n      - name: php\n        image: lhr.ocir.io/apaccpt01/php-webapp-mds:arik3za\n        resources:\n          requests:\n            memory: \"100Mi\"\n            cpu: \"0.25\"\n          limits:\n            memory: \"200Mi\"\n            cpu: \"0.5\"\n        ports:\n        - containerPort: 9000\n        env:\n        - name: MDS_HOST\n          valueFrom:\n            configMapKeyRef:\n              name: mysql-host-configmaps\n              key: mysql-host\n        - name: MDS_DATABASE\n          valueFrom:\n            secretKeyRef:\n              name: mysql-secret\n              key: mysql-database\n        - name: MDS_USER\n          valueFrom:\n            secretKeyRef:\n              name: mysql-secret\n              key: mysql-user\n        - name: MDS_PASSWORD\n          valueFrom:\n            secretKeyRef:\n              name: mysql-secret\n              key: mysql-password\n---\napiVersion: apps/v1\nkind: Deployment\nmetadata:\n  name: nginx\n  namespace: cloudnative-webapp\n  labels:\n    tier: web\nspec:\n  replicas: 3\n  selector:\n    matchLabels:\n      app: nginx\n      tier: web\n  template:\n    metadata:\n      labels:\n        app: nginx\n        tier: web\n    spec:\n      containers:\n      - name: nginx\n        image: lhr.ocir.io/apaccpt01/nginx-php-mds:qwtcc2h\n        ports:\n        - containerPort: 5000\n        resources:\n          requests:\n            memory: \"100Mi\"\n            cpu: \"0.25\"\n          limits:\n            memory: \"200Mi\"\n            cpu: \"0.5\"\n---"
    }
    deploy_artifact_type = "KUBERNETES_MANIFEST"
    project_id = oci_devops_project.devops-project.id
    description = "K8s manifest file to deploy webapp"
    display_name = "${var.resource_naming_prefix}-k8s-manifest-artifact"
}

## ----- Code Repo ----- ##
resource oci_devops_repository oci-code-repo {
    name = "${var.resource_naming_prefix}-oci-code-repo"
    project_id = oci_devops_project.devops-project.id
    default_branch = "refs/heads/main"
    description = "Code repo for webapp"
    repository_type = "HOSTED"
}

## ----- Deployment Pipeline ----- ##
resource "oci_devops_deploy_pipeline" "deploy-pipeline" {
    project_id = oci_devops_project.devops-project.id
    description = "Deployment pipeline for Webapp"
    display_name = "${var.resource_naming_prefix}-deploy-pipeline"
}

## ----- Deployment Stages ----- ## 

resource oci_devops_deploy_stage deploy-oke-stage {
    deploy_pipeline_id = oci_devops_deploy_pipeline.deploy-pipeline.id
    deploy_stage_predecessor_collection {
        items {
            id = oci_devops_deploy_pipeline.deploy-pipeline.id
        }
    }
    deploy_stage_type = "OKE_DEPLOYMENT"
    description = "Deploy webapp to OKE"
    display_name = "deploy-oke-stage"
    kubernetes_manifest_deploy_artifact_ids = [oci_devops_deploy_artifact.k8s-manifest-artifact.id]
    oke_cluster_deploy_environment_id = oci_devops_deploy_environment.oke-environment.id
    rollback_policy {
        policy_type = "NO_STAGE_ROLLBACK_POLICY"
    }
}

## ----- Build Pipeline ----- ## 
resource oci_devops_build_pipeline build-webapp-pipeline {
  description  = "build webapp Container"
  display_name = "build-webapp-pipeline"
  project_id = oci_devops_project.devops-project.id
}

## ----- Build Stages ----- ##

resource oci_devops_build_pipeline_stage build-webapp-stage {
  build_pipeline_id = oci_devops_build_pipeline.build-webapp-pipeline.id
  build_pipeline_stage_predecessor_collection {
    items {
      id = oci_devops_build_pipeline.build-webapp-pipeline.id
    }
  }
  build_pipeline_stage_type = "BUILD"
  build_source_collection {
    items {
      branch = "main"
      connection_type = "DEVOPS_CODE_REPOSITORY"
      name            = "main"
      repository_id   = oci_devops_repository.oci-code-repo.id
      repository_url  = oci_devops_repository.oci-code-repo.http_url
    }
  }
  build_spec_file = "1b_diy_cicd/build/build_spec.yml"
  description  = "build webapp"
  display_name = "build-webapp-stage"
  image = "OL7_X86_64_STANDARD_10"
  primary_build_source               = "main"
  stage_execution_timeout_in_seconds = "36000"
}

resource oci_devops_build_pipeline_stage trigger-deployment-pipeline {
  build_pipeline_id = oci_devops_build_pipeline.build-webapp-pipeline.id
  build_pipeline_stage_predecessor_collection {
    items {
      id = oci_devops_build_pipeline_stage.build-webapp-stage.id
    }
  }
  build_pipeline_stage_type = "TRIGGER_DEPLOYMENT_PIPELINE"
  deploy_pipeline_id = oci_devops_deploy_pipeline.deploy-pipeline.id
  description        = "Trigger Deployment Pipeline"
  display_name       = "trigger-deployment-pipeline"
  is_pass_all_parameters_enabled = "true"
}


output "build_pipeline_url" {
    value = "https://cloud.oracle.com/devops-build/projects/${oci_devops_project.devops-project.id}/build-pipelines/${oci_devops_build_pipeline.build-webapp-pipeline.id}"
}

output "code_repo_url" {
    value = "https://cloud.oracle.com/devops-coderepository/repositories/${oci_devops_repository.oci-code-repo.id}"
}