
data "aws_iam_policy_document" "aws_config_aggregator_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["config.amazonaws.com"]
    }

    effect = "Allow"
  }
}

resource "aws_iam_role" "aggregator_role" {
  count              = var.aggregate_organization ? 1 : 0
  name               = "${var.config_name}_${var.aggregator_role_name}"
  assume_role_policy = data.aws_iam_policy_document.aws_config_aggregator_role_policy.json
  tags = var.config_tags
}

resource "aws_iam_role_policy_attachment" "aggregator" {
  count      = var.aggregate_organization ? 1 : 0
  role       = aws_iam_role.aggregator_role[0].name
  policy_arn = var.policy_arn  
}

#
# Configuration Aggregator
#
resource "aws_config_configuration_aggregator" "organization" {
  count      = var.aggregate_organization ? 1 : 0
  name       = "${var.config_name}_${var.aggregator_name}"

  organization_aggregation_source {
    all_regions = true
    role_arn    = aws_iam_role.aggregator_role[0].arn
  }  
}

resource "aws_config_aggregate_authorization" "lz_config_aggregate_auth" {
  account_id = var.authorization_account_id
  region     = var.region
}