resource "aws_route53_zone" "main" {
  name = local.child_zone

}

resource "aws_route53_record" "rms" {
  zone_id = aws_route53_zone.main.zone_id
  name    = local.abbr
  type    = "A"

  alias {
    name                   = aws_alb.main.dns_name
    zone_id                = aws_alb.main.zone_id
    evaluate_target_health = true
  }
}

data "aws_route53_zone" "selected" {
  provider = aws.Root

  name         = var.root_zone
  private_zone = false
}

resource "aws_route53_record" "example" {
  provider = aws.Root

  allow_overwrite = true
  name            = aws_route53_zone.main.name
  ttl             = 172800
  type            = "NS"
  zone_id         = data.aws_route53_zone.selected.zone_id

  records = [
    aws_route53_zone.main.name_servers[0],
    aws_route53_zone.main.name_servers[1],
    aws_route53_zone.main.name_servers[2],
    aws_route53_zone.main.name_servers[3],
  ]
}