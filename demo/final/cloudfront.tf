data "aws_cloudfront_cache_policy" "default" {
  name = "Managed-CachingOptimized"
}

module "cloudfront" {
  source  = "registry.terraform.io/terraform-aws-modules/cloudfront/aws"
  version = "~> 3"
  # Main parameters
  aliases                       = [var.domain]
  comment                       = "${var.domain} distribution"
  price_class                   = "PriceClass_All"
  create_origin_access_identity = true
  origin_access_identities = {
    format("%s", var.domain) = "CF access identity for ${var.domain}"
  }
  origin = {
    s3 = {
      domain_name = module.s3.s3_bucket_bucket_regional_domain_name
      s3_origin_config = {
        origin_access_identity = var.domain
      }
    }
  }
  default_cache_behavior = {
    target_origin_id       = "s3"
    viewer_protocol_policy = "redirect-to-https"
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    compress               = true
    use_forwarded_values   = false
    cache_policy_id        = data.aws_cloudfront_cache_policy.default.id
  }
  viewer_certificate = {
    acm_certificate_arn      = module.acm.acm_certificate_arn
    minimum_protocol_version = "TLSv1.2_2021"
    ssl_support_method       = "sni-only"
  }
  default_root_object = "index.html"
}
