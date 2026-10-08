# Stage 12 — Testing

## Formatting / Schema Checks

- `terraform fmt -check -recursive` — Formatting check — PASS
- `terraform validate` — Schema/configuration check — PASS

## Contract Tests

### Environment
- `reject_invalid_environment` — Contract — PASS

### Network
- `reject_duplicates` — Contract — PASS

### Subnets
- `validate_subnet_count` — Contract — PASS
- `validate_subnet_zone_distribution` — Contract — PASS
- `validate_private_subnet_public_ip_disabled` — Contract — PASS

### Compute
- `validate_imdsv2_required` — Contract — PASS
- `validate_root_volume_encrypted` — Contract — PASS
- `validate_optional_compute_output` — Contract — PASS

### Storage
- `validate_s3_public_access_protection` — Contract — PASS
- `validate_s3_encryption` — Contract — PASS
- `regression_s3_encryption_output_is_evaluable` — Regression — PASS

### Contract Test Result

`terraform test` — **11 passed, 0 failed**

## Acceptance Check

- `validate_s3_encryption` was tested with an incorrect encryption configuration.
- Incorrect configuration caused the test to FAIL.
- Correct configuration was restored.
- Final test run passed with **11/11 tests passing**.
- Acceptance requirement: **PASS**

## Integration Checks

- Status: **NOT EXECUTED**
- No real AWS resources were applied or verified.
- Mocked/plan tests do not prove AWS permissions or reachability.

## Operational Checks

- Status: **NOT EXECUTED**
- No resource replacement, recovery, or operational diagnosis exercise was performed.

## Repeat Test Suite

Working directory:

`~/terraform-infrastructure-lab/infra/dev`

Commands:

```bash
terraform fmt -check -recursive
terraform validate
terraform test

