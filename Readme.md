# SetUp
A project was aim to set up testing env quickly in cloud. 

## Requirement
1. Install `awscli` with `pip3 install awscli`
2. Install `terraform` depends on [Terraform install](https://learn.hashicorp.com/tutorials/terraform/install-cli)
3. Create IAM role and get AK, put it into `~/.aws/credentials`
4. Create security group and get id, put it into `var.tf`
5. Config region into `var.tf` and ``~/.aws/config`
6. (Optional) Change instace type and size

## setup

```bash
git clone https://github.com/mylamour/setup
cd setup/up && terraform init
```

## Useage

1. show help
`./start.sh -h`

2. create instances
`./start.sh -m init`

3. exec command to remote
`./start.sh -m shell 'ls -al'`

4. exec tgbot (you need to write a bot)
`./start.sh -m tgbot`

5. install tools
`./start.sh -m tools `



# Resources
* [Terraform install](https://learn.hashicorp.com/tutorials/terraform/install-cli)
* [EC2 Prices](https://aws.amazon.com/ec2/pricing/on-demand/)
