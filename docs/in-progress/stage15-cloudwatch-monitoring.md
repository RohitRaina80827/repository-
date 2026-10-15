# Stage 15 — Operations and Failure Monitoring

Status: In progress

## 1. Monitoring Dashboard and Metrics
- Dashboard name:
- EC2 instance-status metric:
- Service-health signal:
- Alarm thresholds:
- Threshold rationale:

## 2. Log Collection and Retention
- CloudWatch log group: /terraform-status-lab/dev/status-service
- Retention: 7 days
- Bootstrap log: /var/log/status-bootstrap.log
- Nginx access log: /var/log/nginx/access.log
- Nginx error log: /var/log/nginx/error.log
- Actual log delivery verified: Pending

## 3. Notifications
- Notification mechanism:
- Notification owner/address:
- Subscription confirmed: Pending
- Alarm notification test: Pending

## 4. Release Identification
- Project: terraform-status-lab
- Release ID:
- Git commit:
- Deployment timestamp:

## 5. Lab Recovery Target
- Practice recovery target:
- Target rationale:
- This is a lab exercise target, not a business-approved SLA.

## 6. Failure Drill and Test Timeline
| Time | Action or observation | Result |
|---|---|---|
| TBD | Record maintenance window | Pending |
| TBD | Record initial service and EC2 health | Pending |
| TBD | Stop service through SSM | Pending |
| TBD | Observe alarm and log evidence | Pending |
| TBD | Restart service | Pending |
| TBD | Confirm recovery and notifications | Pending |

## 7. Recovery Instructions
1. Observe EC2 status checks and SSM connectivity.
2. Check whether the service responds locally.
3. Inspect service status and relevant logs.
4. Check CloudWatch metrics, alarms, and log streams.
5. Restart the service only after recording the failure evidence.
6. Confirm service health, alarm recovery, and notification outcome.

## 8. Troubleshooting Decision Tree
### SSM offline
- Observation:
- Evidence:
- Next action:

### Tunnel connects but HTTP fails
- Observation:
- Evidence:
- Next action:

### Local HTTP works but load balancer reports unhealthy
- Observation:
- Evidence:
- Next action:

### Alarm missing
- Observation:
- Evidence:
- Next action:

### Log stream empty
- Observation:
- Evidence:
- Next action:

## 9. Cost Record
- Log ingestion and storage:
- Metrics:
- Alarms:
- Notifications:
- Estimate date and assumptions:

## 10. Recovery Measurement and Gap
- Failure start time:
- Detection time:
- Recovery start time:
- Service restored time:
- Measured recovery duration:
- Difference from practice target:
- Explanation of the gap:

## 11. Completion Evidence
- Terraform validation:
- Alarm configuration:
- Live log delivery:
- Failure detection:
- Notification delivery:
- Recovery verified:
- Remaining untested items:


## Failure Drill — Observed Results (2026-10-15)

**Environment:** Sandbox, `us-east-1`  
**EC2 instance:** `i-0085e5b03c2eee2df`  
**Maintenance window started:** 2026-10-15 11:38 UTC  
**Git commit at drill start:** `08e686611fa1280952d4e9d69165e288ce5503b9`

### 1. Deliberate service failure
- Used AWS SSM Run Command (`AWS-RunShellScript`) to execute `systemctl stop nginx`.
- SSM command succeeded; Nginx reported `inactive`.
- Local `/health` endpoint returned HTTP `000`.

### 2. Monitoring observations
- CloudWatch `ServiceHealthy` metric reported `0` at 11:41, 11:45, and 11:49 UTC.
- The service-health alarm entered `ALARM`.
- The EC2 status-check alarm remained `OK`.
- This demonstrated that EC2 infrastructure health does not guarantee application health.

### 3. Recovery
- Used SSM Run Command to execute `systemctl start nginx`.
- SSM returned `Success`; Nginx reported `active`.
- `/health` returned `status: healthy`, release `v1.0.0`.
- The service-health alarm subsequently returned to `OK`.

### 4. Outcome and limitation
- **Failure detection:** Demonstrated.
- **Manual recovery:** Demonstrated.
- **Alarm recovery:** Demonstrated.
- **Automatic Nginx restart:** Not configured or tested.
- **Notification delivery during this drill:** Not tested.

## CloudWatch Cost and Retention Notes

### Log storage and retention
- The `/terraform-status-lab/dev/status-service` log group uses 7-day retention to limit stored log volume and cost.
- CloudWatch Logs costs depend on the volume ingested, storage retained, and any additional query or export features used.
- Estimate monthly ingestion as average log volume per day multiplied by 30. Estimate retained storage from daily ingestion multiplied by the retention period; actual billed storage can vary with compression and AWS billing rules.
- Keep useful bootstrap, Nginx access, and Nginx error logs. Avoid unnecessarily verbose logging, and review ingestion volume before increasing retention.

### Metrics and alarms
- The custom `ServiceHealthy` metric is published periodically by a systemd timer. Custom metrics and API requests may incur CloudWatch charges.
- The EC2 status-check alarm and service-health alarm may incur per-alarm charges.
- Keep metric dimensions limited and avoid creating a new metric series for every instance or release unless needed.

### Notifications
- SNS email notifications may incur charges depending on delivery type and volume. Email delivery is not considered demonstrated by the failure drill unless an actual notification is observed.
- Avoid noisy alarms and unnecessary repeated notifications.

### Cost review
- Check current AWS CloudWatch and SNS pricing for the region before estimating exact costs; rates and free-tier eligibility can change.
- Review log ingestion, stored bytes, metric count, alarm count, and notification volume periodically.

## 4. Release Identification
- Project: terraform-status-lab
- Release ID: `v1.0.0`
- Git commit: `08e686611fa1280952d4e9d69165e288ce5503b9`
- Deployment timestamp: Not yet recorded
