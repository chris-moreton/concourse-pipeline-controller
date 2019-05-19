import os
import sys


def initialise_pipeline(filename, directory_name, pipeline_name, concourse_root):
    fullpath = concourse_root + "/" + directory_name + "/devops/concourse/" + filename
    print("Looking for " + fullpath + "...")
    os.system("echo `pwd`")
    pipeline_config = fullpath
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


project_name = sys.argv[1]
concourse_root = sys.argv[2]

initialise_pipeline('pipeline.yml', project_name, project_name, concourse_root)
initialise_pipeline('pipeline-shared-infra.yml', project_name, project_name + "-shared-infra", concourse_root)