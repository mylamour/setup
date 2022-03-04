# SetUp

## How to

## install
1. terraform
2. ansible [optional]

```bash
python3 -m venv runenv
source runenv/bin/activate
pip3 install ansible awscli
```

## configuration
* AWS AK

## useage
1. create instances
use `terraform apply` or `./start.sh -m init`

2. exec command to remote
`./start.sh -m shell ls -al`

3. exec tgbot
`./start.sh -m tgbot`

4. install tools
`./start.sh -m tools `

```bash
cd up
./start.sh
./start.sh -m init
./start.sh -m runtime docker
./start.sh -m shell ls -al
./start.sh -s
```
