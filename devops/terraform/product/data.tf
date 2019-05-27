data "credhub_user" "cloudfoundry_org_owner" {
  name = "/concourse/main/pipeline-controller/CLOUD_FOUNDRY_DEPLOY_USER"
}

data "credhub_value" "cloudfoundry_org_owner_guid" {
  name = "/concourse/main/pipeline-controller/CLOUD_FOUNDRY_DEPLOY_USER_GUID"
}

data "cloudfoundry_org" "org_netsensia" {
  name = "netsensia"
}
