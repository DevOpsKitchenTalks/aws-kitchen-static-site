output "deploy-command" {
  description = "Deployment command"
  value       = "aws s3 cp --recursive ../../dist s3://${module.s3.s3_bucket_id}/"
}

output "site-url" {
  description = "final site url"
  value       = "https://${var.domain}/"
}