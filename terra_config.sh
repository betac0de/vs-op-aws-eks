#cd bootstrap/github_actions_oidc
cd aws_eks
#terraform init -reconfigure
terraform init -upgrade
terraform validate
terraform fmt -recursive
terraform plan -out=tfplan
terraform show -no-color tfplan > tfplan.txt
#terraform apply -auto-approve tfplan
terraform destroy -auto-approve