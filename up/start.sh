#!/bin/bash

RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
YELLOW=$(tput setaf 3)
HIGHLIGHT=$(tput setab 7 -T linux)
NC=$(tput sgr0)
DIR="$(cd "$(dirname "$0")" && pwd)"
CONFIG_DIR="$DIR/configs"
ANSIBLE_CONFIG="./ansible.cfg"
HOSTS="./inventory/hosts"

# let's ansible.cfg use $HOSTS as the inventory path.
sed -i '' -e 's/inventory.*/inventory = \.\/inventory\/hosts/' ansible.cfg 

usage() {
  (
    echo "Usage: $0 [options]"
    echo "Available options:"
    echo "  --destroy                    destroy infra"
    echo "  -h, --help                       prints this"
    echo "  -s, --shell                  enter shell"
    echo "  -m, --module XXX             work with module"
  ) 1>&2
}

destroyit() {
  echo "${RED}${HIGHLIGHT}[Warning]${NC}: Start to Detroy the Infra"
  terraform destroy -auto-approve >>.logs
  echo > inventory/hosts 
  echo "${GREEN}${HIGHLIGHT}[Succeed]${NC}: Destroyed"
}

sshtoremote() {
  # TODO: need pass server ip to function
  oldip=$(cat terraform.tfstate | grep -Eo '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | head -n 1)
  if [ -z $oldip ]; then
    echo "${RED}${HIGHLIGHT}[Error]${NC}: Your Instances was not exists, Please use './start.sh -m init' to create instance"
    exit 1
  else
    ssh -o StrictHostKeyChecking=no -l ubuntu $oldip
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
    echo "${YELLOW}[Info]${NC}: Start to Create Instances with OS: ubuntu"
    terraform apply -auto-approve >>.logs
    # server_ip was defined at output.tf
    echo '[cloud]' > ${HOSTS} && cat terraform.tfstate | jq -r '.outputs.server_ip.value[]' >> ${HOSTS}

    if [ $? -eq 0 ]; then
      echo "${GREEN}[Info]${NC}: Instances Created"
      exit 0
    else
      echo "${RED}${HIGHLIGHT}[ERROR]${NC}: Instances Created FAILED, Please check it now"
      exit 1
    fi
  fi
fi

# if instances was exists then was able to load modules
if [ -f $CONFIG_DIR/${modfile} ]; then

  newip=$(cat .logs | grep -Eo '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | tail -n 1)

  rsync -c -e "ssh -o StrictHostKeyChecking=no" $CONFIG_DIR/${modfile} ubuntu@${newip}:/tmp/

  echo "${GREEN}[Succeed]${NC}: Loading module: ${modfile}"

  # ansible all -i $newip, -m ansible.builtin.script -a "$CONFIG_DIR/${modfile} ${otherargs}" --user=ubuntu
  command=" source /etc/profile && sudo nohup bash /tmp/${modfile} ${otherargs} &"
  ssh -o StrictHostKeyChecking=no -o LogLevel=quiet ubuntu@${newip} ${command}

  # ansible all -i $newip, -m shell -a "${command}" --user=ubuntu
  # ssh -o StrictHostKeyChecking=no -l ubuntu $newip
  ansible all -m shell -a "ls -al" --user=ubuntu

else
  echo "${RED}${HIGHLIGHT}[Error]${NC}: Your Module was Not Exists, Please make sure it was exist in configs folder"
fi
