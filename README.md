# Kestra Deployments

This repository gather different Kestra deployment recipes.

### AWS Cloudformation

AWS CloudFormation provides a fully automated way to deploy Kestra and its dependencies in your AWS account using an infrastructure-as-code approach.  
This template provisions all the required components—such as EC2 instances for the Kestra server, an RDS PostgreSQL database, and an S3 bucket for internal storage—so you can spin up a complete Kestra environment in a few minutes with a single stack deployment.

[🖇️ Link](aws/cloudformation/README.md)

### Azure Batch

[🖇️ Link](azure-batch/README.md)

### AWS Batch

[🖇️ Link](aws-batch/README.md)

### AWS EC2

[🖇️ Link](aws-ec2/README.md)

* **AWS EC2**: to host Kestra server
* **RDS Postgres**: the Kestra database backend
* **AWS S3**: the Kestra internal storage

<img src="aws-ec2/misc/deploy_aws.png" alt="deploy schema" width="500"/>
