# Stage 16 — Budget and Teardown Record

## Cost-bearing resources
- Two EC2 instances under normal operation; ASG can temporarily launch extra instances during refresh.
- One Application Load Balancer.
- Two NAT Gateways and their Elastic IPs.
- CloudWatch log groups, custom metrics, alarms, and SNS notifications.
- VPC networking resources and data transfer.

## Budget and deadline
- Spending limit: NOT YET SET
- Teardown deadline: NOT YET SET
- Observed AWS cost: NOT YET RECORDED
- Estimated cost: NOT YET CALCULATED

## Teardown plan
1. Preserve required evidence and confirm Terraform state is accessible.
2. Review the Terraform destroy plan for the prod-lab workspace/root.
3. Confirm all listed resources belong to this lab and no shared resources will be affected.
4. Apply the approved teardown plan.
5. Verify the lab EC2 instances, load balancer, NAT Gateways, and related billable resources are removed.
6. Check AWS Billing and Cost Explorer later for delayed or remaining charges.

## Important
Setting ASG desired capacity to zero does not stop charges for the ALB, NAT Gateways, CloudWatch resources, or other retained resources.
