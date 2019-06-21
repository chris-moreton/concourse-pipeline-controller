data "credhub_value" "aws_terraform_access_key_id" {
  name = "/concourse/main/pipeline-controller/AWS_ACCESS_KEY_ID"
}

data "credhub_value" "aws_terraform_secret_access_key" {
  name = "/concourse/main/pipeline-controller/AWS_SECRET_ACCESS_KEY"
}

data "aws_vpc" "default" {
  default = true
}

data "aws_subnet_ids" "all" {
  vpc_id = "${data.aws_vpc.default.id}"
}

data "aws_region" "current" {}

data "aws_caller_identity" "current" {}

data "credhub_user" "cloudfoundry_org_owner" {
  name = "/concourse/main/pipeline-controller/CLOUD_FOUNDRY_DEPLOY_USER"
}

data "credhub_value" "cloudfoundry_org_owner_guid" {
  name = "/concourse/main/pipeline-controller/CLOUD_FOUNDRY_DEPLOY_USER_GUID"
}

data "credhub_value" "org_netsensia_guid" {
  name = "/concourse/main/pipeline-controller/CLOUD_FOUNDRY_ORGANISATION_GUID"
}

data "credhub_user" "cloudfoundry_ibm_org_owner" {
  name = "/concourse/main/pipeline-controller/CLOUD_FOUNDRY_IBM_DEPLOY_USER"
}

data "credhub_value" "cloudfoundry_ibm_org_owner_guid" {
  name = "/concourse/main/pipeline-controller/CLOUD_FOUNDRY_IBM_DEPLOY_USER_GUID"
}

data "credhub_value" "org_ibm_netsensia_guid" {
  name = "/concourse/main/pipeline-controller/CLOUD_FOUNDRY_IBM_ORGANISATION_GUID"
}

