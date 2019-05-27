resource "cloudfoundry_space" "product_space" {
  name = "${var.product}-${var.environment}"
  org = "${data.credhub_value.org_netsensia.value}"
  managers = [
    "${data.credhub_value.cloudfoundry_org_owner_guid.value}"
  ]
  developers = [
    "${data.credhub_value.cloudfoundry_org_owner_guid.value}"
  ]
}
