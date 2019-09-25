# Recreate Concourse Instance

## Set environment from "Concourse Deployment Environment Variables"

Grab the variables, then source them, e.g.

    source .env
    
## Backup Credhub credentials

    ./credhub-backup.sh > credhub-restore.sh

## Destroy Concourse
    
    control-tower destroy --iaas aws --region eu-west-2 netsensia-concourse

## Deploy Concourse

    control-tower deploy --iaas aws --worker-size medium --region eu-west-2 --domain concourse.wonderpath.com --github-auth-client-id ${GITHUB_AUTH_CLIENT_ID} --github-auth-client-secret ${GITHUB_AUTH_CLIENT_SECRET} netsensia-concourse

## Grab the new Credhub admin password

This will be one of the last lines from the command above.

Update the value in 

    * your password manager
    * ~/.bashrc
    * Credhub - CONCOURSE_ADMIN_PASSWORD
    
## Grab the environment

    control-tower info --region eu-west-2  --iaas AWS --env netsensia-concourse
    
Replace the variables in .bashrc with the new environment, then

    source ~/.bashrc
    
Replace CREDHUB_CLIENT_SECRET in CredHub for all instances.

## Restore Credentials

    sh credhub-restore.sh
    
## Create pipeline team for admin user

    fly --target $CONCOURSE_NAME login -n main --insecure --concourse-url $CONCOURSE_SERVER -u admin -p $CONCOURSE_ADMIN_PASSWORD
    fly -t netsensia-concourse set-team --non-interactive -n pipeline --config pipeline-team.yml
    
## Restore pipelines

    cd ../devops/concourse
    ../init-me.sh
    