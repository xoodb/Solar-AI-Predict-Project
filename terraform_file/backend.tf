# tfstate backend
terraform {
  backend "s3" {
    bucket = "<tf status 저장할 S3 버킷>"
    key    = "terraform.state"
    region = "ap-northeast-2"
  }
}