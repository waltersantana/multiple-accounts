############################
#   Author: Walter Santana #
#  Created: 11-11-2023     #  
# Modified: 01-12-2023     #
############################

resource "aws_dynamodb_table" "terraform_dynamodb_table" {
  name           = local.dynamodb_table_name
  billing_mode   = "PROVISIONED"
  read_capacity  = 5
  write_capacity = 5
  hash_key       = "LockID"

  lifecycle {
    prevent_destroy = true
  }

  attribute {
    name = "LockID"
    type = "S"
  }
}