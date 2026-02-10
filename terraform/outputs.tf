output "dev_flask_url" {
  description = "Development環境のFlask API URL"
  value       = module.dev.flask_url
}

output "staging_flask_url" {
  description = "Staging環境のFlask API URL"
  value       = module.staging.flask_url
}

output "qa_flask_url" {
  description = "QA環境のFlask API URL"
  value       = module.qa.flask_url
}
