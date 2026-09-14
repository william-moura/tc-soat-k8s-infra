variable "aws_region" {
  default     = "us-east-1"
  description = "Região da AWS"
}

variable "lambda_auth_arn" {
  type        = string
  description = "ARN da Lambda de Autenticação"
  default     = "arn:aws:lambda:us-east-1:123456789012:function:techchallenge-auth-lambda"
}