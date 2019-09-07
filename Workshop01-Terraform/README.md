# Workshop01 : Terraform

## Terraform installation
* Get it here : https://www.terraform.io/downloads.html
* Copy it with the other executables.
* `terraform -version`

## Commands
```
cd ./Workshop01-Terraform
aws configure --profile sandbox-admin
# be sure to be connected to the AWS accout you want

ssh-keygen
# put the key you want to associate in ~/.ssh

export AWS_PROFILE=sandbox-admin

terraform init
terraform plan -var-file=env.tfvars
terraform apply -var-file=env.tfvars
terraform destroy -var-file=env.tfvars
```
