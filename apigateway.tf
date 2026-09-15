# apigateway.tf

resource "aws_apigatewayv2_api" "auth_gw" {
  name          = "tc-soat-api-gateway"
  protocol_type = "HTTP"
}

resource "aws_apigatewayv2_integration" "lambda_auth_integration" {
  api_id           = aws_apigatewayv2_api.auth_gw.id
  integration_type = "AWS_PROXY"
  
  # Usa o ID da conta retornado dinamicamente pelo data.aws_caller_identity
  integration_uri  = "arn:aws:lambda:us-east-1:${data.aws_caller_identity.current.account_id}:function:tc-soat-auth-lambda"
  payload_format_version = "1.0"
}

resource "aws_apigatewayv2_route" "auth_route" {
  api_id    = aws_apigatewayv2_api.auth_gw.id
  route_key = "POST /auth"
  target    = "integrations/${aws_apigatewayv2_integration.lambda_auth_integration.id}"
}

resource "aws_apigatewayv2_stage" "default_stage" {
  api_id      = aws_apigatewayv2_api.auth_gw.id
  name        = "$default"
  auto_deploy = true
}

resource "aws_lambda_permission" "api_gw_lambda_permission" {
  statement_id_prefix = "AllowExecutionFromAPIGateway"
  action              = "lambda:InvokeFunction"
  function_name       = "tc-soat-auth-lambda"
  principal           = "apigateway.amazonaws.com"
  source_arn          = "${aws_apigatewayv2_api.auth_gw.execution_arn}/*/*"
}