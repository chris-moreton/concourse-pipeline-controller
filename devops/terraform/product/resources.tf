resource "cloudfoundry_space" "product_space" {
  name = "${var.product}-${var.environment}"
  org = "${data.cloudfoundry_org.org_netsensia.id}"
  managers = [
    "${data.credhub_value.cloudfoundry_org_owner_guid.value}"
  ]
  developers = [
    "${data.credhub_value.cloudfoundry_org_owner_guid.value}"
  ]
}
