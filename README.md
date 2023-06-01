# oci-developer-incubator

[![License: UPL](https://img.shields.io/badge/license-UPL-green)](https://img.shields.io/badge/license-UPL-green) [![Quality gate](https://sonarcloud.io/api/project_badges/quality_gate?project=oracle-devrel_oci-developer-incubator)](https://sonarcloud.io/dashboard?id=oracle-devrel_oci-developer-incubator)

## Introduction
This repository provides Web App use case with 6 different deployment paths for you to choose from based on your preference and requirements. As each path comes with its own benefits, refer to the table below to guide you in making an informed decision.

| Benefits | DIY | Mix & Match | Managed |
| :--- | :---: | :---: | :---: |
| Highly available and high performance infrastructure with autoscaling | :white_check_mark: | :white_check_mark: | :white_check_mark: |
| Ease of integration with OCI IaaS and PaaS services | :white_check_mark: | :white_check_mark: | :white_check_mark: |
| Highly customizable frontend and backend using programming language and framework of your choice | :white_check_mark: | :white_check_mark: | :x: |
| Automated database operations such as patching, upgrade and backup | :x: | :white_check_mark: | :white_check_mark: |
| Advanced data protection against external attacks and data breaches | :x: | :white_check_mark: | :white_check_mark: |
| Gain immediate access to the latest features from MySQL team | :x: | :white_check_mark: | :heavy_minus_sign: |
| Simple drag-and-drop interface to build a complete app including user interface, business logic and data service | :x: | :x: | :white_check_mark:  |
| Pre-built controls for security, authentication, database interaction, validation and session management | :x: | :x: | :white_check_mark: |

:white_check_mark: = Supported

:x: = Not supported

:heavy_minus_sign: = Not applicable

Continuous Integration and Continuous Delivery **(CI/CD)** accelerates app development by introducing automation into the stages of app development including build, test and deploy. Choose this option to adopt agile app development principles.

* [**1a. DIY**](1a_diy)

    Deploy a containerized webapp based on Nginx & PHP on Oracle Container Enginer for Kubernetes (OKE) and connect to self-hosted MySQL Community Edition (CE).

    [![Deploy to Oracle Cloud](https://oci-resourcemanager-plugin.plugins.oci.oraclecloud.com/latest/deploy-to-oracle-cloud.svg)](https://cloud.oracle.com/resourcemanager/stacks/create?zipUrl=https://<replace_zipfile>)     

* [**1b. DIY with CI/CD**](1b_diy_cicd)

    Build, test and deploy a containerized webapp based on Nginx & PHP on Oracle Container Enginer for Kubernetes (OKE) using OCI DevOps and connect to self-hosted MySQL Community Edition (CE).

    [![Deploy to Oracle Cloud](https://oci-resourcemanager-plugin.plugins.oci.oraclecloud.com/latest/deploy-to-oracle-cloud.svg)](https://cloud.oracle.com/resourcemanager/stacks/create?zipUrl=https://<replace_zipfile>)

* [**2a. Mix and Match**](2a_mixmatch)

    Deploy a containerized webapp based on Nginx & PHP on Oracle Container Enginer for Kubernetes (OKE) and connect to fully-managed OCI MySQL Database Service (MDS).

    [![Deploy to Oracle Cloud](https://oci-resourcemanager-plugin.plugins.oci.oraclecloud.com/latest/deploy-to-oracle-cloud.svg)](https://cloud.oracle.com/resourcemanager/stacks/create?zipUrl=https://<replace_zipfile>)

* [**2b. Mix and Match with CI/CD**](2b_mixmatch_cicd)

    Build, test and deploy a containerized webapp based on Nginx & PHP on Oracle Container Enginer for Kubernetes (OKE) and connect to fully-managed OCI MySQL Database Service (MDS).

    [![Deploy to Oracle Cloud](https://oci-resourcemanager-plugin.plugins.oci.oraclecloud.com/latest/deploy-to-oracle-cloud.svg)](https://cloud.oracle.com/resourcemanager/stacks/create?zipUrl=https://<replace_zipfile>)

* [**3a. Managed**](3a_managed)

    Deploy a fully functional webapp using a low code development platform called Application Express (APEX) on Autonomous Database.

    [![Deploy to Oracle Cloud](https://oci-resourcemanager-plugin.plugins.oci.oraclecloud.com/latest/deploy-to-oracle-cloud.svg)](https://cloud.oracle.com/resourcemanager/stacks/create?zipUrl=https://<replace_zipfile>)

* [**3b. Managed with CI/CD**](3b_managed_cicd)

    Build, test and deploy a fully functional webapp using a low code development platform called Application Express (APEX) on Autonomous Database.

    [![Deploy to Oracle Cloud](https://oci-resourcemanager-plugin.plugins.oci.oraclecloud.com/latest/deploy-to-oracle-cloud.svg)](https://cloud.oracle.com/resourcemanager/stacks/create?zipUrl=https://<replace_zipfile>)

## Getting Started
Click on the deployment path of your choice for more details and deployment instructions. You may also click on the ![Deploy to Oracle Cloud](https://oci-resourcemanager-plugin.plugins.oci.oraclecloud.com/latest/deploy-to-oracle-cloud.svg) button above to automate the deployment using OCI Resource Manager. 

### Prerequisites
Familiarity with webapp development and Oracle Cloud Infrastructure (OCI) is desireable but not required.

## Notes/Issues
Architectures shown are not meant for production deployment. Please refer to [Oracle Reference Architecture](https://docs.oracle.com/en/solutions/ha-web-app/index.html) for best practices.

## URLs
* [Oracle Reference Architecture](https://docs.oracle.com/en/solutions/ha-web-app/index.html)
* [OCI Container Engine for Kubernetes](https://docs.oracle.com/en-us/iaas/Content/ContEng/Concepts/contengoverview.htm)
* [MySQL Database Service](https://docs.oracle.com/en-us/iaas/mysql-database/doc/overview-mysql-database-service.html)
* [Oracle APEX](https://docs.oracle.com/en/database/oracle/apex/index.html)

## Contributing
This project is open source.  Please submit your contributions by forking this repository and submitting a pull request!  Oracle appreciates any contributions that are made by the open source community.

## License
Copyright (c) 2022 Oracle and/or its affiliates.

Licensed under the Universal Permissive License (UPL), Version 1.0.

See [LICENSE](LICENSE) for more details.

ORACLE AND ITS AFFILIATES DO NOT PROVIDE ANY WARRANTY WHATSOEVER, EXPRESS OR IMPLIED, FOR ANY SOFTWARE, MATERIAL OR CONTENT OF ANY KIND CONTAINED OR PRODUCED WITHIN THIS REPOSITORY, AND IN PARTICULAR SPECIFICALLY DISCLAIM ANY AND ALL IMPLIED WARRANTIES OF TITLE, NON-INFRINGEMENT, MERCHANTABILITY, AND FITNESS FOR A PARTICULAR PURPOSE.  FURTHERMORE, ORACLE AND ITS AFFILIATES DO NOT REPRESENT THAT ANY CUSTOMARY SECURITY REVIEW HAS BEEN PERFORMED WITH RESPECT TO ANY SOFTWARE, MATERIAL OR CONTENT CONTAINED OR PRODUCED WITHIN THIS REPOSITORY. IN ADDITION, AND WITHOUT LIMITING THE FOREGOING, THIRD PARTIES MAY HAVE POSTED SOFTWARE, MATERIAL OR CONTENT TO THIS REPOSITORY WITHOUT ANY REVIEW. USE AT YOUR OWN RISK. 