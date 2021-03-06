#!/bin/bash

RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
YELLOW=$(tput setaf 3)
HIGHLIGHT=$(tput setab 7 -T linux)
NC=$(tput sgr0)
DIR="$(cd "$(dirname "$0")" && pwd)"
CONFIGDIR="$DIR/scripts"
AMIUSED="ubuntu"

mkdir -p .logs

if [ $AMIUSED = "ubuntu" ]; then
  sed -i '' -e 's/kali/ubuntu/g' ec2.tf
else
  if [ $AMIUSED = "kali" ]; then
    sed -i '' -e 's/ubuntu/kali/g' ec2.tf
  else
    echo "Please Select ${RED}${HIGHLIGHT}Ubuntu or Kali${NC}, Default was Ubuntu"
    exit 1
  fi
fi

usage() {
  (
    echo "Usage: $0 [options]"
    echo "Available options:"
    echo "  --destroy                    destroy infra"
    echo "  -h, --help                   prints this"
    echo "  -s, --shell                  enter shell"
    echo "  -m, --module XXX             work with module"
  ) 1>&2
}

destroyit() {
  echo "${RED}${HIGHLIGHT}[Warning]${NC}: Start to Detroy the Infra"
  terraform destroy -auto-approve >>.logs/.terraform.log
}

sshtoremote() {
  oldip=$(cat terraform.tfstate | grep -Eo '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | head -n 1)
  if [ -z $oldip ]; then
    echo "${RED}${HIGHLIGHT}[Error]${NC}: Your Instances was not exists, Please use './start.sh -m init' to create instance"
    exit 1
  else
    ssh -o StrictHostKeyChecking=no -l ${AMIUSED} $oldip
  fi
}

if [ -z ${1} ]; then
  usage
  exit 1
fi

while [ $# -gt 0 ]; do
  case $1 in

  --destroy)
    destroyit
    exit 0
    ;;

  -h | --help)
    usage
    exit 0
    ;;

  -s | -shell)
    sshtoremote
    exit 0
    ;;

  -m | --module)
    if [ $# -lt 2 ]; then
      usage
      exit 1
    fi

    modfile="${2}"
    otherargs="${*:3}"
    shift 1
    ;;

    # *) usage && exit 1 ;;

  esac
  shift 1
done

# check whether if the instances was exists
grep -Eo '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' terraform.tfstate >/dev/null
if [ $? -eq 0 ]; then
  # echo "${GREEN}[Info]${NC}: Instances Exists"
  : # pass
else

  # only allowed to use init to create instance
  if [ ${modfile} != "init" ]; then
    echo "${RED}${HIGHLIGHT}[Error]${NC}: Your Instances was not exists, Please use './start.sh -m init' to create instance"
    exit 0
  else
    echo "${YELLOW}[Info]${NC}: Start to Create Instances with OS: ${AMIUSED}"
    terraform apply -auto-approve >>.logs/.terraform.log

    if [ $? -eq 0 ]; then
      echo "${GREEN}[Succeed]${NC}: Instances Created"
    else
      echo "${RED}${HIGHLIGHT}[ERROR]${NC}: Instances Created FAILED, Please check it now"
      exit 1
    fi
  fi
fi

newip=$(cat .logs/.terraform.log | grep -Eo '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | tail -n 1)

if [ ${modfile} == "download" ]; then
  echo "${YELLOW}[Info]${NC}: Start Syncing"
  rsync -qchavzP -e 'ssh -o StrictHostKeyChecking=no' ${AMIUSED}@${newip}:${otherargs}
  echo "${GREEN}[Succeed]${NC}: Data Synced"
  exit 0
else
  # if instances was exists then was able to load modules
  if [ -f $CONFIGDIR/${modfile} ]; then

    rsync -c -e "ssh -o StrictHostKeyChecking=no" $CONFIGDIR/${modfile} ${AMIUSED}@${newip}:/tmp/

    echo "${GREEN}[Succeed]${NC}: Loading module: ${modfile}"
    # command="source /etc/profile; sudo nohup bash /tmp/${modfile} ${otherargs} &"
    command="source /etc/profile; bash /tmp/${modfile} ${otherargs} &" # colored, i got it
    ssh -o StrictHostKeyChecking=no -o LogLevel=quiet ${AMIUSED}@${newip} ${command}
  else
    echo "${RED}${HIGHLIGHT}[Error]${NC}: Your Module was Not Exists, Please put it into configs folder"
  fi
fi
