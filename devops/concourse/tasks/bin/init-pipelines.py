import yaml
import sys
import os
import boto3

f = open(sys.argv[1])

dir=os.path.dirname(os.path.realpath(__file__))

yaml_file = yaml.safe_load(f)
for repo in yaml_file["repos"]:
    f = open("deploy.key","w")
    f.write(repo["deploy_key_credhub_location"])
    os.system("sh " + dir + "/clone.sh " + repo["uri"] + " " + repo["deploy_key_credhub_location"] + " " + repo["pipeline_name"])
    if os.path.isfile(repo["pipeline_name"] + "/devops/concourse/pipeline.yml"):
        os.system("sh " + dir + "/init-pipeline.sh " + repo["pipeline_name"])

print "Putting in S3"

s3 = boto3.client('s3')

try:
    s3.download_file('pipeline-initialiser', 'repositories.yml', 'repositories.yml')
    state_file = open("repositories.yml")
    state_yaml_file = yaml.safe_load(state_file)
except:
    print "Unable to download repository state file"
    state_yaml_file = yaml_file

stream = file("repositories.yml", "w")
yaml.dump(state_yaml_file, stream)

with open("repositories.yml", "rb") as f:
    s3.upload_fileobj(f, "pipeline-initialiser", "repositories.yml")

