# Secured Serverless Orchestration

Configures Amazon VPC Flow Logs for a Particular VPC and send the logs over to CloudWatch Logs. 

The follow Terraform template creates the following AWS resources  

- An Amazon S3 Bucket
- An Amazon Cloudfront Distribution
- A Lambda@Edge for Web Application Security

To use ensure you have [Terraform](https://terraform.io) binary installed in your Windows, Mac or Linux operation. Use the following command to deploy/run the Terraform script

``- terraform init``
``- terraform plan -var "appurl=example.com" -var "wwwappurl=www.example.com" -out cf.plan``
``- terraform apply cf.plan``