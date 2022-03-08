#!/bin/bash

RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
YELLOW=$(tput setaf 3)
HIGHLIGHT=$(tput setab 7 -T linux)
NC=$(tput sgr0)
DIR="$(cd "$(dirname "$0")" && pwd)"
SCRIPT_DIR="$DIR/scripts"
ANSIBLE_CONFIG="./ansible.cfg"
HOSTS="./inventory/hosts"

# let's ansible.cfg use $HOSTS as the inventory path.
sed -i '' -e 's/inventory.*/inventory = \.\/inventory\/hosts/' ansible.cfg

usage() {
  (
    echo "Usage: $0 [options]"
    echo "Available options:"
    echo "  --destroy                    destroy infra"
    echo "  -h, --help                   prints this"
    echo "  -i, --init                   init"
    echo "  -s, --shell                  enter shell"
    echo "  -m, --module XXX             work with module"
  ) 1>&2
}

destroyit() {
  echo "${RED}${HIGHLIGHT}[Warning]${NC}: Start to Detroy the Infra"
  terraform destroy -auto-approve >>.logs/.terraform.log
  echo >inventory/hosts
  echo "${GREEN}[Succeed]${NC}: Destroyed"
}

sshtoremote() {
  ssh -o StrictHostKeyChecking=no -l "ubuntu" "$host"
}

check_instance() {
  # check whether if the instances was exists
  grep -Eo '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' terraform.tfstate >/dev/null
  if [ $? -eq 0 ]; then
    echo "${GREEN}[Info]${NC}: Instances Exists"
  else
    echo "${RED}${HIGHLIGHT}[Info]${NC}: Your Instances was not exists. Please use './start.sh --init' to create instance"
    exit 1
  fi
}

initialize() {
  echo "${YELLOW}[Info]${NC}: Start to Create Instances with OS: ubuntu"
  terraform apply -auto-approve >>.logs/.terraform.log
  # server_ip was defined at output.tf
  echo '[cloud]' >${HOSTS} && cat terraform.tfstate | jq -r '.outputs.server_ip.value[]' >>${HOSTS}

  if [ $? -eq 0 ]; then
    echo "${GREEN}[Succeed]${NC}: Instances Created"
    exit 0
  else
    echo "${RED}${HIGHLIGHT}[ERROR]${NC}: Instances Created FAILED, Please check it now"
    exit 1
  fi
}

load_scripts() {
  # if instances was exists then was able to load modules
  # TODO: use Playbook to support complex task and process logical locally
  if [ -f $SCRIPT_DIR/${modfile} ]; then

    echo "${GREEN}[Info]${NC}: Loading module: ${modfile}"
    ansible-playbook playbooks/utils.yml --extra-vars "script=${modfile}" --tags "upload" >/dev/null
    echo "${GREEN}[Succeed]${NC}: ${modfile} was loaded"
    # ansible all -i $newip, -m ansible.builtin.script -a "$SCRIPT_DIR/${modfile} ${otherargs}" --user=ubuntu
    command="nohup bash /tmp/${modfile} ${otherargs} &"
    ansible all -m shell -a "${command}" --user=ubuntu
    echo "${GREEN}[Succeed]${NC}: ${modfile} was running"

  else
    echo "${RED}${HIGHLIGHT}[Error]${NC}: Your Module was Not Exists, Please make sure it was exist in configs folder"
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

  -i | --init)
    initialize
    exit 0
    ;;

  -s | -shell)
    if [ $# -lt 2 ]; then
      echo "${YELLOW}[Info]${NC}: Please selected ip and ./start.sh -s ip"
      cat terraform.tfstate | jq -r '.outputs.server_ip.value[]'
      exit 1
    fi
    check_instance
    host="${2}"
    sshtoremote
    exit 0
    ;;

  -m | --module)
    if [ $# -lt 2 ]; then
      usage
      exit 1
    fi
    check_instance
    modfile="${2}"
    otherargs="${*:3}"
    load_scripts
    # shift 1
    ;;

    # *) usage && exit 1 ;;

  esac
  shift 1
done