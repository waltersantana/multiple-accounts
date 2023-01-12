# locals {
#   dynamodb_table_name = "${var.abbr}-${var.tf_dynamodb_table}"
# }

resource "aws_dynamodb_table" "terraform_dynamodb_table" {
  name           = local.dynamodb_table_name
  billing_mode   = "PROVISIONED"
  read_capacity  = 5
  write_capacity = 5
  hash_key       = "LockID"

  lifecycle {
    # Any Terraform plan that includes a destroy of this resource will
    # result in an error message.
    #
    prevent_destroy = false
  }
  #tags = local.tags

  attribute {
    name = "LockID"
    type = "S"
  }
}