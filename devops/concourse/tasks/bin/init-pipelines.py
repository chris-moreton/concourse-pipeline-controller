import yaml
import sys
import os

f = open(sys.argv[1])
yaml_file = yaml.safe_load(f)
for repo in yaml_file["repos"]:
    dir=os.path.dirname(os.path.realpath(__file__))
    f = open("deploy.key","w")
    f.write(repo["deploy_key"])
    os.system("sh " + dir + "/clone.sh " + repo["name"])
