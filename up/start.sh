#!/bin/bash

usage()
{
  (echo "Usage: $0 [options]"
   echo "Available options:"
   echo "  --help                       prints this"
   echo "  --destroy                    destroy infra"
   echo "  -r, --run XXX              start to deploy infra"
   echo "  -s, --shell             run command and enter shell") 1>&2
}

destroyit(){
    echo "Start to Detroy the Infra"
    terraform destroy -auto-approve >> .logs
}

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
      
    -s|--shell)
      oldip=$(cat .logs | grep -Eo '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | tail -n 1)
      ssh -o StrictHostKeyChecking=no -l ubuntu $oldip
      exit 0
      ;;

    -r|--run)
      if [ $# -lt 2 ]; then
        usage
        exit 1
      fi

      modfile="${2}"

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

if [ -f $CONFIGDIR/${modfile} ]
then
    echo "Start to building the infra with module: ${modfile}"
    # cat $CONFIGDIR/${modfile} > .tmp.sync.sh
    
    terraform apply  -auto-approve >> .logs
    
    newip=$(cat .logs | grep -Eo '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | tail -n 1)
    
    # ansible-playbook playbook/test.yml --tags "${modfile},test"
    # rm .tmp.sync.sh .logs

    ansible all -i $newip, -m shell -a "sudo nohup bash /tmp/${modfile} &&" --user=ubuntu 
    # ssh -o StrictHostKeyChecking=no -l ubuntu $newip

else
    echo "Your Module is Not Exists, Please make sure it was exist in configs folder"
fi

