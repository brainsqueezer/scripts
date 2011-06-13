import subprocess

command="uvccapture"
args=" -q100"
subprocess.call([command+args,args],shell=True)
