# Stage 16 — Private, Highly Available Service

## Architecture and deployment

- Terraform root: `infra/prod-lab`
- Region: `us-east-1`
- VPC: `vpc-06087ecc41f71c892`
- Application runs on private subnets across two Availability Zones.
- Application Load Balancer provides HTTP-to-HTTPS redirection and HTTPS forwarding.
- Auto Scaling Group desired capacity: two instances.
- Launch Template uses a pinned Amazon Linux 2023 AMI, encrypted gp3 root storage, and IMDSv2.
- Application release reported by `/health`: `v1.0.0`.

## Logging and monitoring

- CloudWatch log groups:
  - `/terraform-status-lab/prod-lab/bootstrap`
  - `/terraform-status-lab/prod-lab/service`
- Retention: seven days.
- Bootstrap and Nginx access/error logs are configured for CloudWatch delivery.
- ASG capacity alarm `terraform-status-lab-prod-asg-capacity-low` monitors whether fewer than two instances are InService.
- Unstable per-instance EC2 alarms were removed because ASG instance IDs change during replacement.
- Service alarm: `terraform-status-lab-prod-service-unhealthy`.
- The ASG capacity alarm was added in the final Terraform apply; its alarm transition has not been independently verified here.
- Service-health alarm was observed in `OK` state after recovery; the drill did not establish that it entered `ALARM`.
- SNS email subscription was configured as `PendingConfirmation` by design. Email delivery was not tested.

## Failure and recovery drill

- Used Systems Manager Run Command on instance `i-0e42d15548e40a6e1` to stop Nginx.
- Command output confirmed the Nginx service became `inactive`.
- The ALB/ELB health check failed and the Auto Scaling Group took the instance out of service.
- ASG activity recorded launching replacement instance `i-0f8966ce2d51410db` in response to an unhealthy instance.
- Follow-up initially showed two instances `InService` and `Healthy`. After the final Terraform apply, three instances briefly appeared InService and Healthy against desired capacity two; allow the ASG refresh to settle and verify the final count.
- HTTPS `/health` subsequently returned HTTP 200 with:
  - `status: healthy`
  - `release: v1.0.0`
- This demonstrated load-balancer health detection and ASG replacement/recovery. The original instance was replaced before a service-alarm transition to `ALARM` could be verified.

## HTTPS and DNS status

- HTTP listener redirects requests to HTTPS.
- HTTPS `/health` returned HTTP 200 when tested with `curl -k`.
- The listener currently uses an imported self-signed certificate for the ALB hostname.
- `curl -k` bypasses certificate trust validation. Public certificate trust is therefore **not verified**.
- ACM public-certificate DNS validation could not be completed with the available FreeDNS hostname. End-to-end HTTPS with a publicly trusted certificate remains unverified.

## Release-to-commit correlation

- Application release reported by the service: `v1.0.0`.
- Repository HEAD during evidence collection: `4a6208d866a86dcadd3e455e684bf2f5c1b7a902` (`Document Stage 15 release-to-commit correlation`).
- No Git tag was listed for `v1.0.0`; the repository HEAD is recorded as the evidence/documentation commit, **not asserted to be the exact source commit used to build the deployed release**.
- Add an immutable release tag or build/deployment manifest in a future release pipeline to establish stronger provenance.

## Requirement 8: Design comparison

### Prebuilt AMI vs. bootstrap

- Current design: a pinned Amazon Linux 2023 AMI; bootstrap installs and configures the service at instance launch.
- Benefit: bootstrap is easy to revise without building a new image.
- Trade-off: package downloads increase startup time and depend on network/repository availability.
- Alternative: build a versioned prebuilt AMI containing the application and dependencies. This improves repeatability but requires image patching and a build pipeline.

### NAT gateways vs. VPC endpoints

- Current design: two NAT gateways, one per Availability Zone, with private subnets routed through their same-zone gateway.
- Alternative: use VPC endpoints for supported AWS services, such as Systems Manager, CloudWatch, and S3 where required.
- Endpoints can reduce NAT dependency for supported AWS traffic but do not provide general internet access to arbitrary external package repositories.

## Final status

- [x] Verify log shipping was configured and service log streams were observed.
- [x] Configure EC2 status-check and service-health alarms.
- [x] Perform the SSM-based Nginx failure and ASG recovery drill.
- [x] Verify HTTPS response and HTTP redirect behavior.
- [x] Record design comparison and release evidence.
- [ ] Verify service-health alarm enters `ALARM` during a controlled failure.
- [ ] Complete publicly trusted ACM certificate validation and HTTPS verification.
- [ ] Confirm SNS email subscription and test notification delivery (intentionally left pending).
- [x] Review and apply the final Terraform plan; verify HTTP 200 and healthy ASG instances.
- [ ] Commit the intended Stage 16 changes.
- [ ] Record final spending/teardown details.
