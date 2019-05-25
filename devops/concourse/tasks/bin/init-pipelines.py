import git
import yaml
import boto3
import os


def get_state(yaml_file):
    s3 = boto3.client('s3')
    tmp_file_location = "/tmp/temp.yml"
    try:
        s3.download_file(os.environ['STATE_BUCKET'], 'repositories.yml', tmp_file_location)
        state_file = open(tmp_file_location)
        state_yaml_file = yaml.safe_load(state_file)
    except:
        print("Unable to download repository state file")
        state_yaml_file = {"repos": yaml_file["repos"]}
    return state_yaml_file


def get_repos():
    repo_yml_filename = "repositories.yml"
    system_call("cp ../../../../" + repo_yml_filename + " .")
    f = open(repo_yml_filename)
    yaml_file = yaml.safe_load(f)
    return yaml_file


def get_state_repo_revisions():
    state_yaml_file = get_state(yaml_file)
    state_repo_revisions = {}
    for state_repo in state_yaml_file["repos"]:
        previous_head_revision = ""
        if ("head_revision" in state_repo.keys()):
            previous_head_revision = state_repo["head_revision"]
        state_repo_revisions[state_repo["pipeline_name"]] = previous_head_revision
    return state_repo_revisions


def save_state(yaml_file):
    s3 = boto3.client('s3')
    tmp_file_location = "/tmp/temp.yml"
    stream = open(tmp_file_location, "w")
    yaml.dump(yaml_file, stream)
    print("Saving state")
    with open(tmp_file_location, "rb") as f:
        s3.upload_fileobj(f, os.environ['STATE_BUCKET'], "repositories.yml")

def system_call(call_string):
    print("Running command: " + call_string)
    return_code = os.system(call_string)
    print("Exit code was: " + str(return_code))
    if return_code != 0:
        exit(return_code)


def initialise_pipeline(filename, directory_name, pipeline_name, first_job):
    print("Looking for " + filename + "...")
    pipeline_config = "/tmp/" + directory_name + "/devops/concourse/" + filename
    if os.path.isfile(pipeline_config):
        print("Updating pipeline " + pipeline_name + "...")
        system_call(
            "fly --target netsensia-concourse set-pipeline --non-interactive -c " + pipeline_config + " -p " + pipeline_name
        )
        print("Unpausing pipeline...")
        system_call("fly --target netsensia-concourse unpause-pipeline -p " + pipeline_name)
        print("Triggering build job...")
        system_call("fly --target netsensia-concourse trigger-job -j " + pipeline_name + "/" + first_job)
    else:
        print("No " + filename + " found.")


def get_deploy_key():
    print("Getting deploy key from CredHub...")
    if ("deploy_key_credhub_location" in repo.keys()):
        if ('PYCHARM_HOSTED' in os.environ.keys() and os.environ['PYCHARM_HOSTED'] == "1"):
            deploy_key_file = "/tmp/id_rsa"
        else:
            deploy_key_file = "/root/.ssh/id_rsa"

        prepare_deploy_key(deploy_key_file)


def prepare_deploy_key(deploy_key_file):
    print("Overwriting deploy key at " + deploy_key_file)
    sed = "sed -e 's/\(KEY-----\)\s/\\1\\n/g; s/\s\(-----END\)/\\n\\1/g' | sed -e '2s/\s\+/\\n/g'"
    system_call("credhub get -q -n " + repo[
        "deploy_key_credhub_location"] + " -k private_key | " + sed + " > " + deploy_key_file)
    system_call("chmod 600 ~/.ssh/id_rsa")


def clone_repository():
    os.system("ssh -o \"StrictHostKeyChecking=no\" git@github.com")
    system_call("rm -rf /tmp/" + repo["pipeline_name"])
    clone_dir = "/tmp/" + repo["pipeline_name"]
    system_call("git clone " + repo["uri"] + " " + clone_dir)
    return clone_dir


def get_current_head_revision():
    get_deploy_key()
    repo_object = git.Repo(clone_repository())
    return repo_object.head.commit.name_rev.split()[0]


def get_previous_head_revision(pipeline_name):
    state_repo_revisions = get_state_repo_revisions()
    if pipeline_name in state_repo_revisions.keys():
        return state_repo_revisions[repo["pipeline_name"]]
    else:
        return ""


yaml_file = get_repos()

for repo in yaml_file["repos"]:

    current_head_revision = get_current_head_revision()

    if current_head_revision == get_previous_head_revision(repo["pipeline_name"]):
        print("We've done this one before...")
    else:
        initialise_pipeline('pipeline.yml', repo["pipeline_name"], repo["pipeline_name"], repo["first_job"])

    repo["head_revision"] = current_head_revision

save_state(yaml_file)
