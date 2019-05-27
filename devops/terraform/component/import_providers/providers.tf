provider "cloudfoundry" {
  api_url = "https://api.run.pivotal.io"
  user = "${var.cloudfoundry_org_owner_username}"
  password = "${var.cloudfoundry_org_owner_password}"
  skip_ssl_validation = true
}
