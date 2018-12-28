#Creating S3 Bucket with versioning enable

resource "aws_s3_bucket" "terraform-s3" {

  bucket = "saqlainmushtaq.com"

  acl    = "private"


  versioning {

    enabled = true

  }



  lifecycle {

    prevent_destroy = true

  }



  tags {

    Name = "S3 Remote store"

  }

}