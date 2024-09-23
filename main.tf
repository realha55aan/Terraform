# AWS API Gateway configuration
resource "aws_api_gateway_rest_api" "example" {
  name        = "example-api"
  description = "Example API Gateway"
}

# API Gateway Resource (e.g., /example)
resource "aws_api_gateway_resource" "example_resource" {
  rest_api_id = aws_api_gateway_rest_api.example.id
  parent_id   = aws_api_gateway_rest_api.example.root_resource_id
  path_part   = "example"
}

# Lambda function using ECR image
resource "aws_lambda_function" "example_lambda" {
  function_name = "example_lambda_function"
  role          = aws_iam_role.lambda_exec_role.arn
  package_type  = "Image"  # Specifies container-based Lambda
  image_uri     = "196249922469.dkr.ecr.us-east-1.amazonaws.com/my-lambda-repo:latest"  # Replace with your ECR image URI
}

resource "aws_lambda_permission" "allow_api_gateway" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.example_lambda.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "arn:aws:execute-api:${var.aws_region}:${var.aws_account_id}:${aws_api_gateway_rest_api.example.id}/*/*"
}

# API Gateway GET Method (proxy integration)
resource "aws_api_gateway_method" "get_method" {
  rest_api_id   = aws_api_gateway_rest_api.example.id
  resource_id   = aws_api_gateway_resource.example_resource.id
  http_method   = "GET"
  authorization = "NONE"
}

# Integration with Lambda for GET
resource "aws_api_gateway_integration" "get_lambda_integration" {
  rest_api_id             = aws_api_gateway_rest_api.example.id
  resource_id             = aws_api_gateway_resource.example_resource.id
  http_method             = aws_api_gateway_method.get_method.http_method
  type                    = "AWS_PROXY"
  integration_http_method = "GET"
  uri                     = aws_lambda_function.example_lambda.invoke_arn
}

# API Gateway Deployment
resource "aws_api_gateway_deployment" "example_deployment" {
  rest_api_id = aws_api_gateway_rest_api.example.id
  stage_name  = "dev"

  depends_on = [
    aws_api_gateway_integration.get_lambda_integration,
  ]
}



