import yaml
import sys
import os

f = open(sys.argv[1])

dir=os.path.dirname(os.path.realpath(__file__))

yaml_file = yaml.safe_load(f)
for repo in yaml_file["repos"]:
    f = open("deploy.key","w")
    f.write(repo["deploy_key_credhub_location"])
    os.system("sh " + dir + "/clone.sh " + repo["name"] + " " + repo["deploy_key_credhub_location"])
