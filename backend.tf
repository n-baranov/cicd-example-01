terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "2.15.0"
    }
  }

  #push the .tfstate to the pre-created S3 bucket
  backend "s3" {
    bucket = "laravel-tfstate-bucket"
    key    = "terraform.tfstate"
    region = "eu-west-3"
  }
}
