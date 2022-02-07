# awsMySQLtoRedisEnterpriseDMS
## Purpose

Demonstrates using AWS RDS mysql database service (Aurora or base RDS) as source for DMS to migrate data to Redis Enterprise.  Note:  Other source databases are offered as source options but other than the two MySQL options, the others have not been tested or fully implemented.

NOTE:  this is not currently working-problems with DMS Redis Endpoint
## Overview

Cloud formation template creates either an Aurora MySQL or an RDS MySQL database along with the appropriate DMS endpoint for this source MySQL database.  In addition to creating the required VPC components, a linux client and optionally a Redis Enterprise cluster with full DNS is created.  Scripts are provided to create sample mysql databases, Redis Endpoints and a migration task to bring the mysql data to Redis Enterprise.

## Outline

- [Overview](#overview)
- [AWS Services Used](#aws-services-used)
- [Technical Overview](#technical-overview)
- [Instructions](#instructions)
  - [Create Environment](#create-environment)
  - [Verify Databases](#verify-databases)
- [Windows Steps](#windows-steps)
- [SCT](#SCT)
- [Complete DMS Steps](#complete-dms-steps)
## AWS Services Used

* [AWS DMS Database Migration Service](https://aws.amazon.com/dms/)
* [AWS Cloudformation](https://aws.amazon.com/cloudformation/)

## Technical Overview

* Create S3 bucket using provided Cloudformation yaml file and script.   
* Bring up AWS RDS MySQL envrionment (can choose Aurora MySQL or RDS MySQL) using provided scripts and cloud formation yaml files.
* Create sample mysql databases using provided scripts
* A parameter is provided to choose to add Redis Enterprise database or not
* If selected, the required DNS entries for Redis Enterprise are included in the cloudformation script
* The RedisEnterprise EC2 resource uses the marketplace AMI with the Redis Enterprise Software pre-installed but does upgrade to the latest version
* This RE EC2 resource has UserData entries to create the Redis Cluster
* Two additional nodes are added to the cluster to make it a three node cluster
* Based on a flag, DMS replication instance and MySQL endpoint is created
* Use provided scripts, to create Redis Enterprise endpoint and the mysql to redis migration task

## Instructions
***IMPORTANT NOTE**: Creating this demo application in your AWS account will create and consume AWS resources, which **will cost money**.  Costing information is available at [AWS DMS Pricing](https://aws.amazon.com/dms/pricing/)   The template will cost money for the other resources as well.

### Create Environment
### Prepare the repository working directory
* Clone the repository
```bash
git clone https://github.com/jphaugla/awsMySQLtoRedisEnterpriseDMS.git
```
* Set up the environment file for use case.  Edit setEnvironment.sh file for your environment.  Some notes on the setEnvironment script...
    * Pay special attention to the DNS entries. The cloudformation sets up DNS using a hosted zone name.   Use the following link for a full explanation of [AWS Route53 DNS management with Redis Enterprise](https://docs.redis.com/latest/rs/installing-upgrading/configuring/configuring-aws-route53-dns-redis-enterprise/)  Port 53 is enabled in the Security Group for DNS
    * The LocalIp is used to limit ssh access to AWS resources.  The AWS checkip URL is used.  If you want this wide open, comment out this line and replace with "0.0.0.0/0"
    * The *CREATE_REDIS* parameter is defaulted to true.  If set to true, it will create the redis entprise cluster and Route 53 DNS entries
    * read through the comments in the setEnvironment.sh script for more details

### Create Environment
Instead of using the following scripts, CloudFormation can be used directly running the templates/MasterSource.yaml file.  However, the method below automates/simplifies the process setting all environment variable in an initial script and then packaging the template file to an S3 file before deploying the script.
```bash
#  sets up the environment
source setEnvironment.sh
#  sets up the ssh key needed based on environment setting.  Will download key to local directory.  Best to move this file to ~/.ssh/
./createKeyPair.sh
# deploy an s3 bucket
./cfns3deploy.sh
# package the nested stack up to the S3 bucket
./cfnpackage.sh
# deploy the stack
./cfndeploy.sh
```

### MySQL Databases setup
* Open the Client EC2 instance using ssh
```bash
ssh -i ~/.ssh/<pem file> ec2-user@<ClientEC2PublicDSN>
```
* Modify the mysql environment file created with the cloudformation script
* File example is below.  For the host name, use the target mariaDB source endpoint. This echo will add the host to the rest of the file which is pre-created by cloudformation
    *This is very wordy [mysql doc link](https://dev.mysql.com/doc/refman/8.0/en/option-files.html)
```bash
echo "host=<mariaDBEndpoint>" >> .my.cnf
```
* connect to the mariaDB database using the pre-installed mysql client
```bash
jphaugla1:~/environment $ mysql
Welcome to the MySQL monitor.  Commands end with ; or \g.
Your MySQL connection id is 127
Server version: 5.5.5-10.4.8-MariaDB-log Source distribution

Copyright (c) 2000, 2018, Oracle and/or its affiliates. All rights reserved.

Oracle is a registered trademark of Oracle Corporation and/or its
affiliates. Other names may be trademarks of their respective
owners.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

mysql>
```
### Install Test Databases
```bash
./testDB.sh
# ignore this error
ERROR 1419 (HY000) at line 214: You do not have the SUPER privilege and binary logging is enabled (you *might* want to use the less safe log_bin_trust_function_creators variable)
ERROR 1419 (HY000) at line 2213: You do not have the SUPER privilege and binary logging is enabled (you *might* want to use the less safe log_bin_trust_function_creators variable)

```

### Complete DMS Steps
The cloudFormation script does not set up the DMS endpoint for Redis Enterprise.  Using CLI bash scripts for the remaining setup
* NOTE:  each of these scripts needs to have the ARNs corrected for your current environment.  So, the createDocDBEndpoint.sh needs the documentDB cluster ARN and the ARN of the created cerficate.  The createReplicationTask.sh needs the ARN for the dynamoDB endpoint, the documentDB endpoint, and the replication instance ARN.
```bash
cd templates
# add IAM roles
# create the endpoint for Redis Enterprise
# edit the redis-settings.json file for the correct endpoint in the ServerName
./createRedistEndpoint.sh
# edit the pertinent arns for the source endpoint, target endpoint, replication instance and then run the create replication scripts
./createReplicationTask.sh
# edit the start replication script for ARN of the replication task
./startReplication.sh
```
### Results

Should see the bulk load tables statistics when clicking on the table statistics tab for the database migration task.
