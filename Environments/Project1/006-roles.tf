# ECS task execution role data
data "aws_iam_policy_document" "ecs_task_execution_role" {
  version = "2012-10-17"
  statement {
    sid     = ""
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

# ECS task execution role
resource "aws_iam_role" "ecs_task_execution_role" {
  name               = "${local.abbr}-${var.ecs_task_execution_role_name}"
  assume_role_policy = data.aws_iam_policy_document.ecs_task_execution_role.json
}

# ECS task execution role policy attachment
resource "aws_iam_role_policy_attachment" "ecs_task_execution_role" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# ECS rds  policy attachment
resource "aws_iam_role_policy_attachment" "rds_task_read_role" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonRDSFullAccess"
}

# ECS Secret Access  policy attachment
resource "aws_iam_role_policy_attachment" "secret_access_permission" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = aws_iam_policy.secret_access_permission.arn
}

# ECS Secret Access  policy 
resource "aws_iam_policy" "secret_access_permission" {
  name        = "secret_access_permission"
  description = "Secret Access Permission"
  policy      = data.aws_iam_policy_document.secret_access_permission.json
}

# ECS Secret Access  policy document
data "aws_iam_policy_document" "secret_access_permission" {
  version = "2012-10-17"
  statement {
    sid       = ""
    effect    = "Allow"
    actions   = ["ssm:GetParameters"]
    resources = ["${aws_ssm_parameter.master_account_db.arn}"]
  }
}