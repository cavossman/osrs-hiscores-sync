terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  profile = "default"
  region  = "us-east-1"
}

resource "aws_iam_role" "iam_for_lambda" {
  name = "iam_for_lambda"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_lambda_function" "osrs_hiscores_lambda" {
  filename      = "dist/osrs-hiscores-lambda.zip"
  function_name = "osrs_hiscores_lambda"
  role          = aws_iam_role.iam_for_lambda.arn
  handler       = "index.handler"

  source_code_hash = filebase64sha256("index.js")

  runtime = "nodejs20.x"
  timeout = 10
}

resource "aws_cloudwatch_event_rule" "schedule_every_hour" {
  name                = "schedule_every_hour_rule"
  description         = "trigger lambda every hour"
  schedule_expression = "cron(0 * ? * * *)"
}

resource "aws_cloudwatch_event_target" "lambda_target" {
  rule      = aws_cloudwatch_event_rule.schedule_every_hour.name
  target_id = "SendToLambda"
  arn       = aws_lambda_function.osrs_hiscores_lambda.arn
}

resource "aws_lambda_permission" "allow_eventbridge" {
  statement_id  = "AllowExecutionFromEventBridge"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.osrs_hiscores_lambda.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.schedule_every_hour.arn
}
