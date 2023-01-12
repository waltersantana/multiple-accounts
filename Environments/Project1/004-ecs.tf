resource "aws_ecs_cluster" "shared_main" {
  name = local.cluster_name
}

resource "aws_ecs_task_definition" "shared_app" {
  for_each = { for each in var.apps : each.abbr => each }

  family                   = "${each.value.abbr}-app-tsk"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = each.value.fargate_cpu
  memory                   = each.value.fargate_memory
  container_definitions = jsonencode([{
    name : "${each.value.abbr}-app",
    image : "${each.value.image}",
    cpu : tonumber("${each.value.fargate_cpu}"),
    memory : tonumber("${each.value.fargate_memory}"),
    networkMode : "awsvpc",
    environment : [
      {
        "name" : "DB_HOST"
        "value" : aws_docdb_cluster_instance.service[0].endpoint
      },
      {
        "name" : "DB_PORT",
        "value" : tostring("${aws_docdb_cluster.service.port}")
      },
      {
        "name" : "DB_USERNAME",
        "value" : aws_docdb_cluster.service.master_username

      },
      {
        "name" : "DB_OPTIONS",
        "value" : "replicaSet=rs0&readPreference=secondaryPreferred&retryWrites=false"
      },
      {
        "name" : "DB_NAME",
        "value" : local.abbr

      }
    ],
    secrets : [
      {
        "name" : "DB_PASSWORD",
        "valueFrom" : "${aws_ssm_parameter.master_account_db.arn}"
    }],
    logConfiguration : {
      logDriver : "awslogs",
      options : {
        awslogs-group : "/ecs/${each.value.abbr}-app",
        awslogs-region : "${local.region}",
        awslogs-stream-prefix : "ecs"
      }
    },
    healthCheck : {
      command : [
        "CMD-SHELL", "echo health"
      ],
      interval : 5,
      timeout : 2,
      retries : 3
    }
    portMappings : [
      {
        containerPort : tonumber("${each.value.containerPort}"),
        hostPort : tonumber("${each.value.appPort}")
      }
    ]
  }])
  tags = {
    Name = "${each.value.abbr}-app-tsk"
  }
}

resource "aws_ecs_service" "shared_main" {
  for_each = { for each in var.apps : each.abbr => each }

  name            = "${each.value.abbr}-svc"
  cluster         = aws_ecs_cluster.shared_main.id
  task_definition = aws_ecs_task_definition.shared_app[each.value.abbr].arn

  desired_count                      = each.value.count
  launch_type                        = "FARGATE"
  deployment_minimum_healthy_percent = 100
  deployment_maximum_percent         = 200
  platform_version                   = "LATEST"

  network_configuration {
    security_groups  = ["${aws_security_group.shared_ecs_tasks[each.value.abbr].id}"]
    subnets          = var.private_subnets
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_alb_target_group.shared_app[each.value.abbr].id
    container_name   = "${each.value.abbr}-app"
    container_port   = each.value.appPort
  }

  depends_on = [aws_alb_listener.back_end, aws_iam_role_policy_attachment.ecs_task_execution_role]
  lifecycle {
    ignore_changes = [task_definition]
  }
  tags = {
    Name = "${each.value.abbr}-svc"
  }
}