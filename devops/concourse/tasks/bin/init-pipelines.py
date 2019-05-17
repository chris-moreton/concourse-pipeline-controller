import sys
import git
import yaml
import boto3
import os

def GetState(yaml_file):
    s3 = boto3.client('s3')
    tmp_file_location = "/tmp/temp.yml"
    try:
        s3.download_file('pipeline-initialiser', 'repositories.yml', tmp_file_location)
        state_file = open(tmp_file_location)
        state_yaml_file = yaml.safe_load(state_file)
    except:
        print("Unable to download repository state file")
        state_yaml_file = yaml_file
    return state_yaml_file

def GetRepos():
    repo_yml_filename = "repositories.yml"
    os.system("cp ../../../../" + repo_yml_filename + " .")
    f = open(repo_yml_filename)
    yaml_file = yaml.safe_load(f)
    return yaml_file


def GetStateRepoRevisions(state_yaml_file):
    state_repos = {}
    for state_repo in state_yaml_file["repos"]:
        previous_head_revision = ""
        if ("head_revision" in state_repo.keys()):
            previous_head_revision = state_repo["head_revision"]
        state_repos[state_repo["pipeline_name"]] = previous_head_revision
    return state_repos

def SaveState(yaml_file):
    s3 = boto3.client('s3')
    tmp_file_location = "/tmp/temp.yml"
    stream = open(tmp_file_location, "w")
    yaml.dump(yaml_file, stream)
    print("Saving state")
    with open(tmp_file_location, "rb") as f:
        s3.upload_fileobj(f, "pipeline-initialiser", "repositories.yml")

yaml_file = GetRepos()
state_yaml_file = GetState(yaml_file)
state_repos = GetStateRepoRevisions(state_yaml_file)

def InitialisePipeline(filename, directory_name, pipeline_name):
    print("Looking for " + filename + "...")
    pipeline_config = "/tmp/" + directory_name + "/devops/concourse/" + filename
    if os.path.isfile(pipeline_config):
        print("Updating pipeline " + pipeline_name + "...")
        os.system(
            "fly --target netsensia-concourse set-pipeline --non-interactive -c " + pipeline_config + " -p " + pipeline_name
        )
        print("Unpausing pipeline...")
        os.system("fly --target netsensia-concourse unpause-pipeline -p " + pipeline_name)
        print("Triggering build job...")
        os.system("fly --target netsensia-concourse trigger-job -j " + pipeline_name + "/build")
    else:
        print("No " + filename + " found.")

for repo in yaml_file["repos"]:

    print("Getting deploy key from CredHub...")

    if ("deploy_key_credhub_location" in repo.keys()):
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

    previous_head_revision = ""

    if (repo["pipeline_name"] in state_repos.keys()):
        previous_head_revision = state_repos[repo["pipeline_name"]]

    print("Current = " + current_head_revision)
    print("Previous = " + previous_head_revision)
    if current_head_revision == previous_head_revision:
        print("We've done this one before...")
    else:
        InitialisePipeline('pipeline.yml', repo["pipeline_name"], repo["pipeline_name"])
        InitialisePipeline('pipeline-shared-infra.yml', repo["pipeline_name"], repo["pipeline_name"] + "-shared-infra")

    repo["head_revision"] = current_head_revision

SaveState(yaml_file)

