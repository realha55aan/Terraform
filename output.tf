# outputs.tf
output "api_url" {
  value = aws_api_gateway_deployment.example_deployment.invoke_url
}
