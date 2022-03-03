#!/bin/bash

RED=`tput setaf 1`
GREEN=`tput setaf 2`
YELLOW=`tput setaf 3`
NC=`tput sgr0`

usage()
{
  (echo "Usage: $0 [options]"
   echo "Available options:"
   echo "  --help                       prints this"
   echo "  --destroy                    destroy infra"
   echo "  -s, --shell                  enter shell"
   echo "  -m, --module XXX             work with module"
   ) 1>&2
}

destroyit(){
    echo "${RED}[Warning]${NC}: Start to Detroy the Infra"
    terraform destroy -auto-approve >> .logs
}

if [ -z ${1} ]
then
  usage
  exit 1
fi

while [ $# -gt 0 ]
do
  case $1 in

    --help)
      usage
      exit 0
      ;;
        
    --destroy)
      destroyit
      exit 0
      ;;
      
    -s|-shell)
      oldip=$(cat .logs | grep -Eo '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | tail -n 1)
      ssh -o StrictHostKeyChecking=no -l ubuntu $oldip
      exit 0
      ;;

    -m|--module)
      if [ $# -lt 2 ]; then
        usage
        exit 1
      fi

      modfile="${2}"
      otherargs="${*:3}"

      shift 1
      ;;

    # -t|--team)
    #   if [ $# -lt 2 ]; then
    #     usage
    #     exit 1
    #   fi
    #   team="${2}"
    #   shift 1
    #   ;;

    *)
  esac
  shift 1
done

DIR="$( cd "$( dirname "$0" )" && pwd )" 
CONFIGDIR="$DIR/configs"

grep -Eo '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' terraform.tfstate > /dev/null
# check whether if the instances was exists
if [ $? -eq 0 ]; then
    echo "${GREEN}[Info]${NC}: Instances Exists"
    # :  # pass
else
    echo "${YELLOW}[Info]${NC}: Start to Create Instances"
    terraform apply  -auto-approve >> .logs
    
    if [ $? -eq 0 ]; then
        echo "${GREEN}[Info]${NC}: Instances Created"
    else
        echo "${RED}[ERROR]${NC}: Instances Created FAILED, Please Check it now"
        exit 1
    fi

fi

if [ -f $CONFIGDIR/${modfile} ]
then
    echo "${GREEN}[Info]${NC}: Start to building with module: ${modfile}"
    
    newip=$(cat .logs | grep -Eo '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | tail -n 1)

    rsync $CONFIGDIR/${modfile} ubuntu@${newip}:/tmp/
    # ansible all -i $newip, -m ansible.builtin.script -a "$CONFIGDIR/${modfile} ${otherargs}" --user=ubuntu
   
    command="sudo nohup bash /tmp/${modfile} ${otherargs} &"
    ssh -o StrictHostKeyChecking=no -o LogLevel=quiet ubuntu@${newip} ${command}

    # ansible all -i $newip, -m shell -a "${command}" --user=ubuntu 
    # ssh -o StrictHostKeyChecking=no -l ubuntu $newip

else
    echo "${RED}[Error]${NC}: Your Module was Not Exists, Please make sure it was exist in configs folder"
fi