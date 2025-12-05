resource "aws_s3_bucket" "bucket_from_terraform" {
  bucket = "my-terraform-poc-bucket-123456"
  tags = {
    Name        = "terraform-poc-bucket"
    Environment = "poc"
  }
}
