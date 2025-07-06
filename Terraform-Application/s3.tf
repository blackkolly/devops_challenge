resource "aws_s3_bucket" "app_bucket" {
  bucket        = "flask-ecommerce-app-${random_id.suffix.hex}"
  force_destroy = true
  tags = { Name = "flask-ecommerce-app-bucket" }
}

resource "random_id" "suffix" {
  byte_length = 4
}
