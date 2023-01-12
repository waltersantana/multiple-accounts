resource "aws_ssm_parameter" "master_account_db" {
  name  = "DB_PASSWORD"
  type  = "SecureString"
  value = random_password.master_password.result
}