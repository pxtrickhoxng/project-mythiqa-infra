# Project Mythiqa Infrastructure

This repository contains the **Terraform code** for the cloud infrastructure supporting **Project Mythiqa** on AWS. It provides a modular, reusable setup to manage networking, compute, storage, and databases.

## Repository Structure
- **modules/** – Contains all reusable infrastructure modules:
  - **network/** – VPC, subnets, route tables, internet gateway, and NAT gateways
  - **compute/** – Auto Scaling Group with launch templates and scaling policies
  - **alb/** – Application Load Balancer, target groups, listeners, and health checks
  - **database/** – RDS instance with automated backups and encryption at rest
  - **storage/** – S3 bucket for frontend static website

## Architecture
Three-tier architecture across multiple availability zones: ALB in public subnets routes traffic to EC2 instances in private subnets, which connect to RDS in isolated database subnets. NAT gateways provide outbound internet access for private resources.

The infrastructure was designed with scalability in mind. To save costs, all resources are disabled by default.
