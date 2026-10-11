# Requirement 8 — Invalidate Stale Terraform Plans

## Problem statement
A Terraform plan may become outdated after it has been reviewed.
Using an old approval can authorize changes that were never reviewed.

## Invalidation rules
Treat an approval as invalid if any of the following changes after review:
- Terraform configuration or module code.
- The commit being reviewed.
- Input variables or other values used to generate the plan.
- Terraform state or relevant infrastructure conditions.
- The saved plan file or its recorded SHA-256 hash.

## Required process
1. Generate a fresh Terraform plan.
2. Record the repository, environment, commit SHA, run ID, and plan SHA-256.
3. Inspect the plan and verify its metadata against the trusted GitHub Actions run.
4. Record a new reviewer decision for that exact plan.
5. If relevant code, inputs, state, or infrastructure conditions change,
   discard the old approval and repeat the review.

## Current enforcement status
The dev workflow records the commit SHA and plan hash and uploads the saved
plan with metadata. It does not yet enforce reviewer approval or prevent
an old approval record from being reused.

A commit SHA check alone cannot detect every state or infrastructure change.
A matching hash confirms file integrity against the trusted recorded hash;
it does not prove the plan is current or approved.

No automatic apply or destroy is authorized by this requirement.
