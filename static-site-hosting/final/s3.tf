# We need to generate some random suffix for our bucket name
resource "random_pet" "s3" {}
locals { bucket = "dkt-static-site-${random_pet.s3.id}" }
# Here we define the s3 bucket policy
data "aws_iam_policy_document" "bucket" {
  statement {
    actions   = ["s3:GetObject"]
    resources = [format("arn:aws:s3:::%s/*", local.bucket)]
    principals {
      type        = "AWS"
      identifiers = module.cloudfront.cloudfront_origin_access_identity_iam_arns
    }
  }
}
# And create the s3 bucket itself
module "s3" {
  source        = "registry.terraform.io/terraform-aws-modules/s3-bucket/aws"
  version       = "~> 3"
  bucket        = local.bucket
  attach_policy = true
  policy        = data.aws_iam_policy_document.bucket.json
  force_destroy = true
}
