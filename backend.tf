terraform {
    backend "s3" {
        bucket = "1407-aish-tf-bucket"
        key = "terraform.tfstate"
        region = "eu-central-1"
    }
}

