# Deployment Path: Mix and Match

## How It Works

![webapp_mixmatch_arch_diagram.png](img/webapp_mixmatch_arch_diagram.png)

## Let's build it

**a. Create OKE Kubernetes cluster. VCN and corresponding network resources will be created automatically.**
    
1. Click the Navigation Menu in the upper left, navigate to Developer Services, select Kubernetes Clusters (OKE)

![oke_cluster](img/oke_cluster.png)

![create_oke_cluster](img/create_oke_cluster.png)

2. Choose Quick Create as it will create the new cluster along with the new network resources such as Virtual Cloud Network (VCN), Internet Gateway (IG), NAT Gateway (NAT), Regional Subnet for worker nodes, and a Regional Subnet for load balancers. Select Launch Workflow

3. Keep the name to cluster1 and the other default values, click Next to review the cluster settings.

4. Click Create

![quick_create_oke](img/quick_create_oke.png)

**b. Create a bastion host compute instance**

1. Click the Navigation Menu in the upper left, navigate to Compute, select Instances

![instances.png](img/instances.png)

2. Click Create Instance

3. Change Name to Operator

4. In Networking section, select VCN and public subnet created with OKE

5. In Add SSH keys section, click Save Private Key and Save Public Key to save private and public keys for SSH access

![ssh_key.png](img/ssh_key.png)

6. Click Create

**c. Create a MySQL Database Service instance**

1. Click the Navigation Menu in the upper left, navigate to Databases, select MySQL DB Systems

![create_mds.png](img/create_mds.png)

2. Click Create MySQL DB System

![create_mds_db.png](img/create_mds_db.png)

3. In Create Administrator credentials section, enter admin username and password

4. In Configure networking section, select the VCN and private subnet created with OKE

5. Click Create

**d. Set up schema and data in MySQL DB System**

1. SSH to bastion host from cloud shell

2. Install MySQL Shell on bastion host

3. Connect to MySQL DB System with MySQL Shell
    ```
    mysqlsh -h <MDS host> -p ‘<MDS password>' -u <MDS user>
    ```

4. Create database and table
    ```
    \sql
	CREATE DATABASE webappdb;
    use webappdb;
    CREATE TABLE `employee_data`( `id` int(11) NOT NULL AUTO_INCREMENT PRIMARY KEY, `first_name` VARCHAR(50) NOT NULL, `last_name` VARCHAR(50) NOT NULL, `gender` VARCHAR(50) NOT NULL, `email` VARCHAR(50) NOT NULL, `hire_date` VARCHAR(50) NOT NULL, `department` VARCHAR(50) NOT NULL, `job` VARCHAR(50) NOT NULL, `salary` DECIMAL(10,2) NOT NULL )AUTO_INCREMENT=1;
    show tables;
    ```

**e. Build webapp container images and push them to OCI Container Registry**

1. Create container registries

    1.1 Click the Navigation Menu on the upper left, navigate to Developer Services, select Container Registry.

    1.2 Click Create repository.

    1.3 Create 2 public repositories named `webapp/php` and `webapp/nginx`.

2. Build container images

    2.1 Navigate to Cloud Shell.

    2.2 Clone this git repo.

    2.3 Go to Nginx source folder.
    ```
    cd 2a_mixmatch/src/nginx
    ```

    2.4 Build Nginx container image.
    ```
    docker build -t <region_key>.ocir.io/<tenancy_namespace>/webapp/nginx:1.0 .
    ```
    Note: <region_key> can be found using OCI CLI command `oci iam region list --output table` then refer to the key of the region and <tenancy_namespace> using `oci os ns get`.

    2.5 Go to PHP source folder.
    ```
    cd ../php
    ```

    2.6 Build PHP container image.
    ```
    docker build -t <region_key>.ocir.io/<tenancy_namespace>/webapp/php:1.0 .
    ```
    Note: <region_key> can be found using OCI CLI command `oci iam region list --output table` then refer to the key of the region and <tenancy_namespace> using `oci os ns get`.

3. Push container images

    3.1 Login to OCI Container Registry
    ```
    docker login <region_key>.ocir.io -u <tenancy_namespace>/oracleidentitycloudservice/<username> -p <auth_token>
    ```
    Note: <region_key> can be found using OCI CLI command `oci iam region list --output table` then refer to the key of the region and <tenancy_namespace> using `oci os ns get`. For <auth_token>, click Profile on the top right corner of OCI console, then click on your username. On the bottom left pane, click Auth Token and Generate Token.

    2.7 Push Nginx and PHP container images to container registries
    ```
    docker push <region_key>.ocir.io/<tenancy_namespace>/webapp/nginx:1.0
    docker push <region_key>.ocir.io/<tenancy_namespace>/webapp/php:1.0
    ```

**f. Deploy application to OKE Cluster**

1. Set up OKE cluster access on cloud shell

    1.1 Click on the OKE cluster you created

    1.2 Click Access Cluster

    ![access_cluster.png](img/access_cluster.png)

    1.3 Follow the steps to set up OKE cluster access on cloud shell

    ![access_cluster_shell.png](img/access_cluster_shell.png)

    1.4 Update the MySQL host IP address in deploy/mysql_config.yml, credentials in deploy/mysql_secret.yml and container image locations of php and nginx in 2a_mixmatch/deploy/deploy-webapp.yml

    1.5 Deploy the application
    ```
    kubectl apply -f 2a_mixmatch/deploy/mysql_config.yml
    kubectl apply -f 2a_mixmatch/deploy/mysql_secret.yml
    kubectl apply -f 2a_mixmatch/deploy/deploy-webapp.yml
    ```

## Resources

`Additional Resources here`

For example

[LiveLabs](https://apexapps.oracle.com/pls/apex/dbpm/r/livelabs/view-workshop?wid=709)

[Refernce Architecture](https://docs.oracle.com/en/solutions/ha-web-app/index.html)

[MAD Framwork](https://docs.oracle.com/en/solutions/mad-web-mobile/index.html)

[OKE Documentation](https://docs.oracle.com/en-us/iaas/Content/ContEng/home.htm)

[MDS Documentation](https://docs.oracle.com/en-us/iaas/mysql-database/index.html)