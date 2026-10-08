Provisioning identity:
terra-admin
arn:aws:iam::980819806665:user/terra-admin

Runtime role and instance profile:
Runtime role: terraform-status-lab-dev-runtime
Instance profile: terraform-status-lab-dev-runtime-profile

Trusted principal:
ec2.amazonaws.com

SSM policy and purpose:
AmazonSSMManagedInstanceCore
Purpose: Allows the EC2 instance to register with and communicate through AWS Systems Manager.

Application bucket and permitted prefix:
Bucket: terraform-status-lab-dev-artifacts-89d8355d6f6a
Prefix: artifacts/

Allowed S3 actions:
ListBucket with prefix condition
GetObject

Expected denied action:
PutObject

Inbound rules:
None

Outbound rules:
TCP 443 to 0.0.0.0/0

DNS:
Amazon-provided resolver

Package repositories:
HTTPS required

PassRole scope and policy-review evidence:
Provisioning identity must have iam:PassRole permission only for:
arn:aws:iam::980819806665:role/terraform-status-lab-dev-runtime
Condition:
iam:PassedToService = ec2.amazonaws.com

AWS configuration verification:
EC2 is using the runtime instance profile and is in the Terraform public subnet/VPC.
SSM connection verified.

Runtime read/write tests:
PASS
S3 GetObject: PASS
S3 PutObject: DENIED as expected

Secrets handling:
No secrets stored in Terraform code, AMI, or S3 artifact.
AWS credentials are supplied through the approved Terraform AWS CLI profile.

Wildcard justification:
S3 object access is restricted to:
artifacts/*
No broad S3 write/delete permission is granted.

Residual risks:
Outbound HTTPS is allowed to all IPv4 destinations.
SSM managed policy is AWS-managed and broader than the application's S3 permission.
Application artifacts under artifacts/ are readable by the runtime role.
