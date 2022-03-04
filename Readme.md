# SetUp

## Install
1. terraform
2. ansible [optional]

```bash
cd up && terraform init
cd ..
python3 -m venv runenv
source runenv/bin/activate
pip3 install ansible awscli
```

## Configuration
* Create IAM role and get AK, put it into `~/.aws/credentials`
* Create security group and get id, put it into `var.tf`
* Config region into `var.tf` and ``~/.aws/config`
* (Optional) Change instace type and size


## Useage

1. show help
`./start.sh -h`

2. create instances
 you can use `terraform apply` or `./start.sh -m init`

3. exec command to remote
`./start.sh -m shell 'ls -al'`

4. exec tgbot
`./start.sh -m tgbot`

5. install tools
`./start.sh -m tools `

