resource "cloudfoundry_space" "product_space" {
  name = "${var.product}-${var.environment}"
  org = "${data.credhub_value.org_netsensia_guid.value}"
  managers = [
    "${data.credhub_value.cloudfoundry_org_owner_guid.value}"
  ]
  developers = [
    "${data.credhub_value.cloudfoundry_org_owner_guid.value}"
  ]
}

resource "aws_s3_bucket" "private_bucket" {
  bucket = "${var.product}-${var.component}-${var.environment}-private"
  acl    = "private"

  region = "eu-west-2"

  versioning {
    enabled = true
  }
}

