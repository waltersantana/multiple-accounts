resource "aws_docdb_subnet_group" "service" {
  name       = "${local.abbr}-${var.docdb_name}-sgr"
  subnet_ids = var.database_subnets
}

resource "aws_docdb_cluster_instance" "service" {
  count              = 1
  identifier         = "${local.abbr}-${var.docdb_name}-${count.index}"
  cluster_identifier = aws_docdb_cluster.service.id
  instance_class     = var.docdb_instance_class
}

resource "aws_docdb_cluster" "service" {
  cluster_identifier              = "${local.abbr}-${var.docdb_name}"
  skip_final_snapshot             = true
  db_subnet_group_name            = aws_docdb_subnet_group.service.name
  engine                          = "docdb"
  master_username                 = "${replace(var.docdb_name, "-", "_")}_admin"
  master_password                 = random_password.master_password.result
  db_cluster_parameter_group_name = aws_docdb_cluster_parameter_group.service.name
  vpc_security_group_ids          = ["${aws_security_group.shared_service.id}"]
}

resource "aws_docdb_cluster_parameter_group" "service" {
  family = "docdb4.0"
  name   = "${var.docdb_name}-pgr"

  #TODO: Review this parameter
  parameter {
    name  = "tls"
    value = "disabled"
  }
}

# Random string to use as master password
resource "random_password" "master_password" {
  length  = 12
  special = false # Include Symbols
  numeric = true  # Include Numbers
  # override_special = "_%@"
}