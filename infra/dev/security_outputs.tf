output "runtime_role_name" {
  value = aws_iam_role.runtime.name
}

output "runtime_role_arn" {
  value = aws_iam_role.runtime.arn
}

output "runtime_instance_profile_name" {
  value = aws_iam_instance_profile.runtime.name
}

output "core_security_group_id" {
  value = aws_security_group.core.id
}

output "runtime_test_artifact_key" {
  value = module.storage.artifact_key
}
