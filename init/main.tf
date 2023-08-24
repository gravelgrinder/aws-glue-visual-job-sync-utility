### Development Account 
provider "aws" {
  alias   = "dev"
  profile = "default"
  region  = "us-east-1"
}

### Test Account 
provider "aws" {
  alias   = "test"
  profile = "default"
  region  = "us-east-1"

  assume_role {
    role_arn = "arn:aws:iam::758373647921:role/djl-tf-assume_role"
  }
}



###############################################################################
### Create S3 Development Bucket
###############################################################################
resource "aws_s3_bucket" "dev_bucket" {
  provider = aws.dev
  bucket = "tf-djl-dev-glue"
  force_destroy = true

  tags = {
      Name        = "tf-djl-dev-glue"
      Environment = "Dev"
  }
}

resource "aws_s3_bucket_acl" "dev_bucket" {
  provider = aws.dev
  bucket = aws_s3_bucket.dev_bucket.id
  acl    = "private"
}

resource "aws_s3_bucket_versioning" "dev_bucket" {
  provider = aws.dev
  bucket = aws_s3_bucket.dev_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "dev_bucket" {
  provider = aws.dev
  bucket = aws_s3_bucket.dev_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "AES256"
    }
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "dev_bucket" {
  provider = aws.dev
  bucket = aws_s3_bucket.dev_bucket.id

  rule {
    id      = "expire_version"
    filter {
      prefix = ""
    }
    expiration {days = 1}
    noncurrent_version_expiration {noncurrent_days = 1}
    abort_incomplete_multipart_upload { days_after_initiation = 1 }
    status = "Enabled"
  }

  rule {
    id      = "delete_version"
    filter {
      prefix = ""
    }
    expiration {expired_object_delete_marker = true}
    status = "Enabled"
  }
}

resource "aws_s3_bucket_public_access_block" "dev_bucket" {
  provider = aws.dev
  bucket = aws_s3_bucket.dev_bucket.id

  block_public_acls   = true
  ignore_public_acls  = true
  block_public_policy = true
  restrict_public_buckets = true
}
###############################################################################



###############################################################################
### Create S3 Test Bucket
###############################################################################
resource "aws_s3_bucket" "test_bucket" {
  provider = aws.test
  bucket = "tf-djl-test-glue"
  force_destroy = true

  tags = {
      Name        = "tf-djl-dev-glue"
      Environment = "Dev"
  }
}

resource "aws_s3_bucket_acl" "test_bucket" {
  provider = aws.test
  bucket = aws_s3_bucket.test_bucket.id
  acl    = "private"
}

resource "aws_s3_bucket_versioning" "test_bucket" {
  provider = aws.test
  bucket = aws_s3_bucket.test_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "test_bucket" {
  provider = aws.test
  bucket = aws_s3_bucket.test_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "AES256"
    }
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "test_bucket" {
  provider = aws.test
  bucket = aws_s3_bucket.test_bucket.id

  rule {
    id      = "expire_version"
    filter {
      prefix = ""
    }
    expiration {days = 1}
    noncurrent_version_expiration {noncurrent_days = 1}
    abort_incomplete_multipart_upload { days_after_initiation = 1 }
    status = "Enabled"
  }

  rule {
    id      = "delete_version"
    filter {
      prefix = ""
    }
    expiration {expired_object_delete_marker = true}
    status = "Enabled"
  }
}

resource "aws_s3_bucket_public_access_block" "test_bucket" {
  provider = aws.test
  bucket = aws_s3_bucket.test_bucket.id

  block_public_acls   = true
  ignore_public_acls  = true
  block_public_policy = true
  restrict_public_buckets = true
}
###############################################################################