resource "cloudfoundry_space" "product_space" {
  name = "${var.product}-${var.environment}"
}
