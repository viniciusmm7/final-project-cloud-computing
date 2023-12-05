# Cloud Computing Final Project

## Project Overview
This project automates the provisioning of scalable and resilient public cloud infrastructure on AWS using Terraform. It is designed to deploy a simple Python-based RESTful API, supported by a robust backend infrastructure that includes an Application Load Balancer (ALB), EC2 instances with auto-scaling, and a MySQL RDS database.

## Auxiliary Repositories
The code for the Python-based RESTful API using Flask is available [here](https://github.com/viniciusmm7/generic-flask-rest-api).

## User Manual

### Creating Infrastructure on AWS
First, the user is expected to have an AWS account and obtain the `access_key_id` and `secret_access_key`, then:

```shell
export AWS_ACCESS_KEY_ID=<USER-ACCESS-KEY>
export AWS_SECRET_ACCESS_KEY=<USER-SECRET-ACCESS-KEY>
export AWS_DEFAULT_REGION=<USER-DEFAULT-REGION>
```

For more details, refer to the [official AWS documentation](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-envvars.html).

The user also needs an **S3 Bucket** named `terraform-bucket-viniciusmm7`, which must be manually created on AWS. It is necessary to store Terraform backend information.

Now, execute:

```shell
cd final-project-cloud-computing
terraform init
terraform apply -auto-approve
```

> [!TIP]
> This execution will take several minutes, possibly around 20 minutes to finish. Grab a coffee or take your guinea pig for a walk.

Once finished, copy the **Load Balancer's** DNS available in the terminal and test the connection directly in the browser. If it's not available, simply run the command below and copy the `dns_name` value:

```shell
terraform state show module.ec2.aws_lb.load_balancer
```

The expected response is `{message: "Connected successfully!"}`

### Destroying Infrastructure on AWS
> [!WARNING]
> This step is time-consuming, similar to creating infrastructure. Exercise caution before executing.

```shell
terraform destroy -auto-approve
```

## Infrastructure

### Region Choice
The chosen region for this project is `us-east-1` (Northern Virginia). Despite being the most famous region and having more interruptions, we choose it for its cost-effectiveness, good latency for the project's needs, and a wide range of available services that can be useful for scaling up this project.

### Network
The network has a customized **VPC** (Virtual Private Cloud) for the CIDR `10.0.0.0/16` and four **subnets**, two public (`10.0.1.0/24`, `10.0.2.0/25`) and two private (`10.0.7.0/24`, `10.0.8.0/24`) available in two regions for higher availability (HA). Thus, four more public and four private subnets can be added in the future if needed.

### EC2 Instances and Autoscaling
Instances are provisioned automatically through a **Launch Template**, using an **Autoscaling Group** to manage a minimum of 2 instances available 24/7 and a maximum of 5. Additional instances are provisioned as usage for each available instance increases, with a rule when the CPU average reaches 70% or ALB Request Count Per Target reaches 200. Additional instances are turned off as instance usage decreases, with a rule when the CPU average reaches 10%.

### Load Balancer
Necessary to distribute traffic proportionally across available instances, taking into account efficiency and fault tolerance.

### RDS with MySQL Database
MySQL database instance configured with **Multi-AZ** for high availability (HA), with backup settings every 7 days and a maintenance window scheduled for Sunday 04:00-05:00 UTC. Sensitive database credentials are managed by **Secrets Manager**.

### Security Groups
Three security groups are defined, one for the **Load Balancer**, one for EC2 instances, and one for RDS. This way, RDS only accepts requests made on port 3306 (MySQL default), while the others only accept inputs on port 80 (HTTP).

## Cost Analysis
The estimated cost using the official AWS calculator was: $134.83/month. More details [here](My%20Estimate%20-%20AWS%20Pricing%20Calculator.pdf).

## Infrastructure Diagram
![Infrastructure Diagram](diagram.png)