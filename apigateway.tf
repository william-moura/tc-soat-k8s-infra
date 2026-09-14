# Definição do HTTP API Gateway
resource "aws_apigatewayv2_api" "auth_gw" {
  name          = "tc-soat-api-gateway"
  protocol_type = "HTTP"
}

# Integração com a Lambda de Autenticação
resource "aws_apigatewayv2_integration" "lambda_auth_integration" {
  api_id           = aws_apigatewayv2_api.auth_gw.id
  integration_type = "AWS_PROXY"

  integration_method = "POST"
  integration_uri    = var.lambda_auth_arn
}

# Rota pública de login POST /auth
resource "aws_apigatewayv2_route" "auth_route" {
  api_id    = aws_apigatewayv2_api.auth_gw.id
  route_key = "POST /auth"
  target    = "integrations/${aws_apigatewayv2_integration.lambda_auth_integration.id}"
}

# Estágio de Deploy Automático
resource "aws_apigatewayv2_stage" "default_stage" {
  api_id      = aws_apigatewayv2_api.auth_gw.id
  name        = "$default"
  auto_deploy = true
}

# Permissão de Invocação para a Lambda
resource "aws_lambda_permission" "api_gw_lambda_permission" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = "tc-soat-auth-lambda"
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.auth_gw.execution_arn}/*/*"
}