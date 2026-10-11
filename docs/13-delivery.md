# Stage 13 — Controlled Infrastructure Delivery

## Problem and objective
Infrastructure changes can cause outages, expose resources, or modify the
wrong environment. Delivery must verify changes before any deployment.

## Triggers and stages
- Pull requests: formatting, Terraform initialization without a backend,
  validation, configured tests, and Gitleaks secret scanning.
- Dev planning: manual workflow dispatch or qualifying pushes to main.
- Cloud identity: GitHub Actions OIDC assumes an approved AWS IAM role
  using short-lived credentials, not a long-lived AWS access key.
- Review: inspect the saved plan, commit SHA, run ID, plan hash, and state
  fingerprint before making a deployment decision.
- Post-deployment: verify health and intended access; investigate failures
  as incidents rather than automatically destroying resources.

## Credentials and trust
Untrusted/fork pull requests must not receive cloud deployment credentials.
The OIDC authentication test uses
GitHubActions-OIDC-AuthOnly. Dev planning uses
GitHubActions-Terraform-DevPlan. Verify the actual assumed role in the
successful CI identity-check logs. A local AWS identity does not prove OIDC.

## Approval boundary
The workflow generates dev-plan-approval.md, but this record is not an
enforced approval gate. A reviewer must approve the exact commit and saved
plan before any separately authorized deployment. If code, inputs, state,
or relevant infrastructure conditions change, create and review a new plan.

## Artifacts and concurrency
The dev plan artifact is retained for one day and may contain sensitive
information. Keep access restricted and download it only when needed.
The dev planning workflow uses the terraform-dev-state concurrency group
to serialize that workflow's runs. Backend state locking is still required;
other writers must also be controlled.

## Failure response
Stop on formatting, validation, test, secret-scanning, identity, or plan
verification failures. Do not bypass checks to continue. Inspect logs,
correct the cause, rerun checks, and generate a fresh plan when necessary.

## Recovery owner
The repository maintainer is responsible for investigating failures,
restoring the last known-good configuration where appropriate, and
coordinating recovery. Validate health and access before closing an incident.

## Deployment policy
"Plan on every commit; apply anything immediately" is not the policy.
Plans are review evidence, not authorization to deploy. Changes require
validation, restricted credentials, review of the exact saved plan, and
a deliberate deployment decision. Changes after approval require a new plan.
