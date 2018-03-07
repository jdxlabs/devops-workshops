# devops-workshops
Worshops around the devops methodology

## Terraform installation
* Get it here : https://www.terraform.io/downloads.html
* Copy it with the other executables.
* `terraform -version`

## Worshop1 : Terraform

### Commands
```
aws configure --profile sandbox-admin
# be sure to be connected to the AWS accout you want

export AWS_PROFILE=sandbox-admin

terraform init
terraform plan -var-file=env.tfvars
terraform apply -var-file=env.tfvars
```
