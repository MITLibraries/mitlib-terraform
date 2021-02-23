# libraries-assets.tf

module "label" {
  source = "github.com/mitlibraries/tf-mod-name?ref=0.12"
  name   = "libraries-assets"
}

# Create the CloudFront CDN and S3 bucket
module "libraries_assets_cdn" {
  source = "github.com/mitlibraries/tf-mod-cdn-s3?ref=0.12"
  name   = "libraries-assets"
  #  aliases              = ["libraries-assets.mitlib.net"] #certificate error generated when this line is left active
  ext_aliases          = ["libraries-assets.mit.edu"]
  parent_zone_name     = "mitlib.net"
  cors_allowed_origins = ["libraries-assets.mit.edu"]
  tags                 = module.label.tags
  custom_error_response = [
    {
      error_code            = "404"
      response_code         = "200"
      response_page_path    = "/index.html"
      error_caching_min_ttl = "0"
    },
  ]
  # The certificate was created manually (via MIT) and imported manually
  acm_certificate_arn = var.certificate_arn
}

# Create the Route53 DNS A records for the Cloudfront distribution's domain name
resource "aws_route53_record" "libraries_assets_dns_pub" {
  name    = "libraries-assets.mitlib.net"
  zone_id = var.dns_zone_id_pub
  type    = "A"
  alias {
    name                   = module.libraries_assets_cdn.cf_domain_name
    zone_id                = module.libraries_assets_cdn.cf_hosted_zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "libraries_assets_dns_pri" {
  name    = "libraries-assets.mitlib.net"
  zone_id = var.dns_zone_id_pri
  type    = "A"
  alias {
    name                   = module.libraries_assets_cdn.cf_domain_name
    zone_id                = module.libraries_assets_cdn.cf_hosted_zone_id
    evaluate_target_health = false
  }
}

# Upload a generic index.html file to the S3 bucket
resource "aws_s3_bucket_object" "libraries-assets" {
  bucket = module.libraries_assets_cdn.s3_bucket
  key    = "index.html"
  source = "./index.html"
  etag   = filemd5("./index.html")
  tags   = module.label.tags
}
