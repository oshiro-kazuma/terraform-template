variable "access_key" {}
variable "secret_key" {}
variable "region" {}
variable "key_name" {}
variable "base_name" {}
variable "db_passsword" {}

# account
provider "aws" {
  access_key = var.access_key
  secret_key = var.secret_key
  region     = var.region
}
