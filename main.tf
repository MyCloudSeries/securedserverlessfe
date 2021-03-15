resource "aws_s3_bucket" "logs" {
  bucket                = format("logs-%s", var.appurl)
  acl                   = "log-delivery-write"
}

resource "aws_s3_bucket" "feapp" {
  bucket                = var.appurl
  acl                   = "public-read"
  policy                = file("security/bucketpolicy.json")

  website {
    index_document      = "index.html"
    error_document      = "error.html"
  }

  tags = {
    Name                = "staticServerless"
    SiteURL             = var.appurl
  }

  cors_rule {
    allowed_headers     = ["*"]
    allowed_methods     = ["PUT","POST","GET", "HEAD"]
    allowed_origins     = [var.appurl]
    expose_headers      = ["ETag"]
    max_age_seconds     = 3000
  }

  versioning {
    enabled             = true
  }

  logging {
    target_bucket       = aws_s3_bucket.logs.id
    target_prefix       = "log/"
  }
}

locals {
  s3_origin_id = "myS3Origin"
}

resource "aws_cloudfront_distribution" "s3_distribution" {
  origin {
    domain_name       = aws_s3_bucket.feapp.bucket_regional_domain_name
    origin_id         = local.s3_origin_id
  
    
  }

  enabled             = true
  is_ipv6_enabled     = true
  comment             = "A Static S3 Website"
  default_root_object = "index.html"

  logging_config {
    include_cookies   = false
    bucket            =  format("%s.s3.amazonaws.com", var.appurl)
    prefix            = "cflogs/"
  }

  # Ensure a valid certificate for this URL is available before using it
  #aliases = ["var.appurl","var.wwwappurl"]

  default_cache_behavior {
    allowed_methods        = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = local.s3_origin_id

    forwarded_values {
      query_string         = false

      cookies {
        forward            = "none"
      }
    }

    viewer_protocol_policy = "allow-all"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  price_class = "PriceClass_200"

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  tags = {
    Environment            = "production"
    DeploymentType         = "static website"
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }
}

