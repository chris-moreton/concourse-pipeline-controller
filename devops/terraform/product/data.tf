data "credhub_user" "cloudfoundry_org_owner" {
  name = "/concourse/pipeline/controller/CLOUD_FOUNDRY_DEPLOY_USER"
}

data "credhub_value" "cloudfoundry_org_owner_guid" {
  name = "/concourse/pipeline/controller/CLOUD_FOUNDRY_DEPLOY_USER_GUID"
}

data "credhub_value" "org_netsensia_guid" {
  name = "/concourse/pipeline/controller/CLOUD_FOUNDRY_ORGANISATION_GUID"
}

data "credhub_user" "cloudfoundry_ibm_org_owner" {
  name = "/concourse/pipeline/controller/CLOUD_FOUNDRY_IBM_DEPLOY_USER"
}

data "credhub_value" "cloudfoundry_ibm_org_owner_guid" {
  name = "/concourse/pipeline/controller/CLOUD_FOUNDRY_IBM_DEPLOY_USER_GUID"
}

data "credhub_value" "org_ibm_netsensia_guid" {
  name = "/concourse/pipeline/controller/CLOUD_FOUNDRY_IBM_ORGANISATION_GUID"
}

