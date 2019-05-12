import yaml
import sys
import os

f = open(sys.argv[1])
aws_id = sys.argv[2]
aws_key = sys.argv[3]
concourse_admin_password = sys.argv[4]

yaml_file = yaml.safe_load(f)
for repo in yaml_file["repos"]:
    dir=os.path.dirname(os.path.realpath(__file__))
    f = open("deploy.key","w")
    f.write(repo["deploy_key_credhub_location"])
    os.system("sh " + dir + "/clone.sh " + repo["name"] + " " + repo["deploy_key_credhub_location"] + " " + aws_id + " " + aws_key + " " + concourse_admin_password)
