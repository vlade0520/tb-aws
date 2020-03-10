
data "aws_iam_policy_document" "cloudtrail_assume_policy" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "cloudtrail_cloudwatch_policy" {
  statement {
    effect    = "Allow"
    actions   = ["logs:CreateLogStream"]
    resources = ["arn:aws:logs:${var.region}:${var.bucket_account_id}:log-group:*:log-stream:*"]
  }

  statement {
    effect    = "Allow"
    actions   = ["logs:PutLogEvents"]
    resources = ["arn:aws:logs:${var.region}:${var.bucket_account_id}:log-group:*:log-stream:*"]
  }
}

data "aws_iam_policy_document" "cloudtrail_sns_policy" {
  statement {

    sid = "AWSLZCloudTrailSNSPolicy"
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }

    actions = ["SNS:Publish","SNS:SetTopicAttributes"]
    
    resources = [var.sns_topic_arn]

    condition {
      test     = "StringEquals"
      variable = "AWS:SourceOwner"
      values   = ["${var.bucket_account_id}"]
    }
  }
}

