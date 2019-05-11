# Concourse Repository Scanner
    
Put a deploy key in CredHub 
    
    credhub set -n /concourse/main/directorzone-api/GITHUB_DEPLOY_KEY --type ssh --private ~/.ssh/directorzone_api_deploy --public ~/.ssh/directorzone_api_deploy.pub


 ## Control Tower
 
 Ensure credentials are stored in 
 
 	~/.aws/credentials
 
 Info
 
     control-tower info --iaas aws --region eu-west-2 netsensia-concourse
 
 Environment variables
 
     control-tower info --iaas aws --region eu-west-2 netsensia-concourse --env
     
 Login to CredHub
 
     eval "$(control-tower info --iaas aws --env --region eu-west-2 netsensia-concourse)"
