provider "aws" {
  access_key = var.AWS_ACCESS_KEY
  secret_key = var.AWS_SECRET_KEY
  region = var.AWS_REGION
}

resource "aws_instance" "aws-test" {
  ami = "ami-18b5a562"
  instance_type = "t2.micro"
  tags = {
    Name= "aws-nginx-host-1"
    "Scheduled" = "Yes"
  }
  key_name = "myfirstkeypair"
  root_block_device {
    volume_size = 20
  }
}

resource "aws_iam_role" "role" {
  name = "ec2-stop-start-role-tf"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_policy" "policy" {
  name = "ec2-start-stop-policy-tf"
  description = "ec2 policy"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": "arn:aws:logs:*:*:*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "ec2:Start*",
        "ec2:Stop*",
        "ec2:Describe*"
      ],
      "Resource": "*"
    }
  ]
}
EOF
}


resource "aws_iam_role_policy_attachment" "policy-attach" {
  role       = aws_iam_role.role.name
  policy_arn = aws_iam_policy.policy.arn
}

resource "aws_lambda_function" "ec2-lambda" {
  filename = "lambda/lambda.zip"
  function_name = "ec2-stop-start-labda-function"
  handler = "ec2-start-stop.main"
  role = aws_iam_role.role.arn
  runtime = "python3.8"
}

resource "aws_cloudwatch_event_rule" "start-schedule" {
  name                = "ec2-start-tf"
  description         = "Fires every 10 minutes"
  schedule_expression = "cron(35 1 * * ? *)"
}

resource "aws_cloudwatch_event_target" "start-target" {
  rule      = aws_cloudwatch_event_rule.start-schedule.name
  target_id = "ec2-lambda"
  arn       = aws_lambda_function.ec2-lambda.arn
  input = "{\"Action\": \"Start\"}"
}

resource "aws_cloudwatch_event_rule" "stop-schedule" {
  name                = "ec2-stop-tf"
  description         = "Fires every 10 minutes"
  schedule_expression = "cron(30 1 * * ? *)"
}

resource "aws_cloudwatch_event_target" "stop-target" {
  rule      = aws_cloudwatch_event_rule.stop-schedule.name
  target_id = "ec2-lambda"
  arn       = aws_lambda_function.ec2-lambda.arn
  input = "{\"Action\": \"Stop\"}"
}

resource "aws_lambda_permission" "allow_cloudwatch_start_to_call_lambda_function" {
  statement_id  = "AllowExecutionFromCloudWatchForStart"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.ec2-lambda.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.start-schedule.arn
}

resource "aws_lambda_permission" "allow_cloudwatch_stop_to_call_lambda_function" {
  statement_id  = "AllowExecutionFromCloudWatchForStop"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.ec2-lambda.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.stop-schedule.arn
}