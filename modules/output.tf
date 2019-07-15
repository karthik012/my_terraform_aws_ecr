output "ecr_repository_arn" {
  value       = "${element(concat(aws_ecr_repository.default.*.arn, list(""), 0)}"
  description = "Full ARN of the repository."
}

output "ecr_repository_name" {
  value       = "${element(concat(aws_ecr_repository.default.*.name, list(""), 0)}"
  description = "The name of the repository."
}

output "ecr_repository_registry_id" {
  value       = "${element(concat(aws_ecr_repository.default.*.registry_id, list(""), 0)}"
  description = "The registry ID where the repository was created."
}

output "ecr_repository_url" {
  value       = "${element(concat(aws_ecr_repository.default.*.repository_url, list(""), 0)}"
  description = "The URL of the repository (in the form aws_account_id.dkr.ecr.region.amazonaws.com/repositoryName)"
}
