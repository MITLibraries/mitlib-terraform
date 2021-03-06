# The certificate was created manually (via MIT) and imported manually

module "grand_web" {
  source               = "github.com/mitlibraries/tf-mod-cdn-s3?ref=0.12"
  name                 = "grandchallenges"
  aliases              = ["grandchallenges.mitlib.net"]
  ext_aliases          = ["grandchallenges.mit.edu"]
  parent_zone_name     = "mitlib.net"
  cors_allowed_origins = ["grandchallenges.mit.edu"]

  custom_error_response = [
    {
      error_code            = "404"
      response_code         = "200"
      response_page_path    = "/index.html"
      error_caching_min_ttl = "0"
    },
  ]

  acm_certificate_arn = "arn:aws:acm:us-east-1:672626379771:certificate/cdb62536-c66f-4eff-940a-d90ecc869b0b"
}
