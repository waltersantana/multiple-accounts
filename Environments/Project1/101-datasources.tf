data "aws_acm_certificate" "issued" {
  #provider = aws.QualityAssurance
  domain   = "*.${local.child_zone}"
  statuses = ["ISSUED"]
}