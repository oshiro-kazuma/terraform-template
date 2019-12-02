# terraform template

## overview

下記のサービスを使用した、一般的なAWSの構成を構築します。

 - VPC
   - route table
   - internet gateway
   - Private Subnet / Public Subnet
 - ALB
 - EC2
 - Aurora(MySQL 5.7)

## usage

```bash
# 準備
terraform init

# dry run
terraform plan

# 実行
terraform apply
```

## note

キーペアは予め作成して、 `terraform.tfvars` に記述しておくこと。
