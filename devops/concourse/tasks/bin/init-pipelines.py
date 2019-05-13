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
    os.system("sh " + dir + "/clone.sh " + repo["name"] + " " + repo["deploy_key_credhub_location"] + " " + repo["pipeline_name"])
    if os.path.isfile(repo["pipeline_name"] + "/devops/concourse/pipeline.yml"):
        os.system("sh " + dir + "/init-pipeline.sh " + repo["pipeline_name"])

s3 = boto3.resource('s3')
data = open('clone.sh')
s3.Bucket('pipeline-initialiser').put_object(Key='clone.sh', Body=data)
