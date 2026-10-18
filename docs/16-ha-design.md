# Stage 16 — High-Availability Production Design

## Architecture
- VPC CIDR: 10.30.0.0/16 in us-east-1.
- Two Availability Zones, each with a public and private subnet.
- Internet-facing Application Load Balancer routes traffic to private EC2 instances.
- Each AZ has its own NAT Gateway and private-subnet route.
- Auto Scaling Group desired capacity: 2; minimum: 2; maximum: 4.
- EC2 instances use encrypted gp3 storage, IMDSv2, and an IAM instance profile.

## Traffic and Health
- HTTP redirects to HTTPS.
- HTTPS listener uses an imported self-signed certificate.
- HTTPS health endpoint: /health on port 8080.
- Both deployed targets were healthy.
- Target AZs: us-east-1a and us-east-1b.
- Private IPs: 10.30.11.176 and 10.30.12.251.
- Neither instance has a public IPv4 address.
- Public certificate trust and domain-based ACM validation remain incomplete.

## Scaling and Recovery
- ASG desired capacity is 2, minimum 2, maximum 4.
- Instance refresh uses a 100% minimum healthy percentage, 150% maximum healthy percentage, and 600-second warm-up.
- During refresh, temporary extra instances can exist while replacements warm up and old instances drain.
- The Nginx failure drill demonstrated target-health failure, ASG replacement, warm-up, and recovery.
- Client-request impact and zero downtime were not measured.

## Monitoring
- CloudWatch bootstrap and service log groups use seven-day retention.
- Service health is published as a custom CloudWatch metric.
- CloudWatch alarms monitor service health and ASG in-service capacity.
- SNS email confirmation is intentionally left pending.

## Limitations
- Two instances alone do not guarantee availability; load-balancer health checks, AZ diversity, capacity, and recovery behavior also matter.
- HTTPS encryption is functional, but a self-signed certificate is not publicly trusted by default.
- Private instances reduce direct exposure but do not alone guarantee secure access.
- No application data durability guarantee is established by this compute-focused design.

## Cost and Teardown
- Cost-bearing resources include EC2, the ALB, two NAT Gateways, CloudWatch logs/metrics/alarms, and related networking resources.
- Record the spending limit, teardown deadline, and observed or estimated costs before declaring the lab complete.
- To stop ongoing lab costs, destroy resources through the approved Terraform workflow after preserving required evidence and state. Confirm any shared resources before teardown.
