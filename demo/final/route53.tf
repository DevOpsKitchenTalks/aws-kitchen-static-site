resource "aws_route53_zone" "this" {
  name = var.domain
}
resource "aws_route53_record" "this" {
  zone_id = aws_route53_zone.this.zone_id
  name    = aws_route53_zone.this.name
  type    = "A"

  alias {
    name                   = module.cloudfront.cloudfront_distribution_domain_name
    evaluate_target_health = true
    zone_id                = module.cloudfront.cloudfront_distribution_hosted_zone_id
  }
}
# We issue wildcard certificate for the zone
module "acm" {
  source  = "registry.terraform.io/terraform-aws-modules/acm/aws"
  version = "~> 4.0"

  domain_name               = "*.${aws_route53_zone.this.name}"
  zone_id                   = aws_route53_zone.this.id
  subject_alternative_names = [aws_route53_zone.this.name]

  providers = {
    aws = aws.us-east-1
  }
}
# I manage top level domain on the CloudFlare, so we need to create the record there
data "cloudflare_zone" "this" {
  name = var.domain_zone
}

resource "cloudflare_record" "this" {
  zone_id = data.cloudflare_zone.this.id
  name    = replace(var.domain, ".${var.domain_zone}", "")
  value   = aws_route53_zone.this.name_servers[0]
  type    = "NS"
  ttl     = 300
}
