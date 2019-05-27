resource "cloudfoundry_space" "product_space" {
  name = "${var.product}-${var.environment}"
  org = "${data.credhub_value.org_netsensia_guid.value}"
}

resource "aws_s3_bucket" "private_bucket" {
  bucket = "${var.product}-${var.component}-${var.environment}-private"
  acl    = "private"

  region = "eu-west-2"

  versioning {
    enabled = true
  }
}

resource "aws_s3_bucket" "public_bucket" {
  bucket = "${var.product}-${var.component}-${var.environment}-public"

  region = "eu-west-2"

  versioning {
    enabled = false
  }
}

resource "aws_s3_bucket_policy" "public_bucket" {
  depends_on = ["aws_s3_bucket.public_bucket"]
  bucket = "${aws_s3_bucket.public_bucket.id}"

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Id": "Terraform",
  "Statement": [
    {
      "Sid": "IPAllow",
      "Effect": "Allow",
      "Principal": "*",
      "Action": [
            "s3:GetObject"
        ],
        "Resource": [
            "arn:aws:s3:::${var.product}-${var.component}-${var.environment}-public",
            "arn:aws:s3:::${var.product}-${var.component}-${var.environment}-public/*"
        ],
      "Condition": {
         "IpAddress": {"aws:SourceIp": "0.0.0.0/0"}
      }
    }
  ]
}
POLICY
}

