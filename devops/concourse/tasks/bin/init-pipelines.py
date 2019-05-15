import yaml
import os
from io import open
import sys
import boto3
import git

repo_yml_filename = "repositories.yml"

os.system("cp ../../../../" + repo_yml_filename + " .")

f = open(repo_yml_filename)

yaml_file = yaml.safe_load(f)

s3 = boto3.client('s3')

tmp_file = "/tmp/temp.yml"

try:
    s3.download_file('pipeline-initialiser', 'repositories.yml', tmp_file)
    state_file = open(tmp_file)
    state_yaml_file = yaml.safe_load(state_file)
except:
    print ("Unable to download repository state file")
    state_yaml_file = yaml_file

for repo in yaml_file["repos"]:

    print("Getting deploy key from CredHub...")

    if ('PYCHARM_HOSTED' in os.environ.keys() and os.environ['PYCHARM_HOSTED'] == "1"):
        deploy_key_file = "/tmp/id_rsa"
    else:
        deploy_key_file = "/root/.ssh/id_rsa"

    print("Overwriting deploy key at " + deploy_key_file)
    sed = "sed -e 's/\(KEY-----\)\s/\\1\\n/g; s/\s\(-----END\)/\\n\\1/g' | sed -e '2s/\s\+/\\n/g'"
    os.system("credhub get -q -n " + repo["deploy_key_credhub_location"] + " -k private_key | " + sed + " > " + deploy_key_file)
    os.system("chmod 600 ~/.ssh/id_rsa")

    os.system("ssh -o \"StrictHostKeyChecking=no\" git@github.com")
    os.system("rm -rf /tmp/" + repo["pipeline_name"])
    os.system("git clone " + repo["uri"] + " " + "/tmp/" + repo["pipeline_name"])

    repo_object = git.Repo("/tmp/" + repo["pipeline_name"])
    current_head_revision = repo_object.head.commit.name_rev.split()[0]

    if "head_revision" in repo.keys():
        if current_head_revision == repo["head_revision"]:
            print("We've done this one before...")
        else:
            print("Looking for a pipeline.yml...")
            pipeline_config = "/tmp/" + repo["pipeline_name"] + "/devops/concourse/pipeline.yml"
            if os.path.isfile(pipeline_config):
                print("Updating pipeline...")
                os.system("fly --target netsensia-concourse set-pipeline --non-interactive -c " + pipeline_config + " -p " + repo["pipeline_name"])
                print("Unpausing pipeline...")
                os.system("fly --target netsensia-concourse unpause-pipeline -p " + repo["pipeline_name"])
                print("Triggering build job...")
                os.system("fly --target netsensia-concourse trigger-job -j " + repo["pipeline_name"] + "/build")
            else:
                print("No pipeline.yml found.")
                sys.exit(1)

    repo["head_revision"] = current_head_revision

stream = open(tmp_file, "w")
yaml.dump(yaml_file, stream)

with open(tmp_file, "rb") as f:
    s3.upload_fileobj(f, "pipeline-initialiser", "repositories.yml")

os.system("rm  " + repo_yml_filename)