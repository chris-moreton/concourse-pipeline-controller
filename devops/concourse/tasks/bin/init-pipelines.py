import yaml
import os
import boto3
import git

repo_yml_filename = "repositories.yml"
f = open(repo_yml_filename)

yaml_file = yaml.safe_load(f)

s3 = boto3.client('s3')

try:
    s3.download_file('pipeline-initialiser', 'repositories.yml', 'repositories.yml')
    state_file = open("repositories.yml")
    state_yaml_file = yaml.safe_load(state_file)
except:
    print "Unable to download repository state file"
    state_yaml_file = yaml_file

for repo in yaml_file["repos"]:
    f = open("deploy.key","w")
    f.write(repo["deploy_key_credhub_location"])
    os.system("sh clone.sh " + repo["uri"] + " " + repo["deploy_key_credhub_location"] + " " + repo["pipeline_name"])
    repo_object = git.Repo("/tmp/" + repo["pipeline_name"])
    repo["head_revision"] = repo_object.head.commit.name_rev
    if os.path.isfile("/tmp/" + repo["pipeline_name"] + "/devops/concourse/pipeline.yml"):
        os.system("sh init-pipeline.sh " + repo["pipeline_name"])

stream = file(repo_yml_filename, "w")
yaml.dump(state_yaml_file, stream)

with open(repo_yml_filename, "rb") as f:
    s3.upload_fileobj(f, "pipeline-initialiser", "repositories.yml")

