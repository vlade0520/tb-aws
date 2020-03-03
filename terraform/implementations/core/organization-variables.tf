variable "aws_organizations_account_sharedservices_name" {
    description = "Shared Services name"
    default ="sharedservice"
}
variable "aws_organizations_account_sharedservices_email" {
    description = "Shared Services email"
    default = "tl93372@gmail.com"
}

variable "aws_organizations_account_logarchive_name" {
    description = "Log Archive accounts name"
    default = "testing"
}

variable "aws_organizations_account_logarchive_email" {
    description = "Log Archive accounts email"
    default = "tb.test.logging.01@gmail.com"
}

variable "aws_organizations_account_security_name" {
    description = "Security accounts name"
    default = "security"
}
variable "aws_organizations_account_security_email" {
    description = "Security accounts email"
    default = "test.gft.aws.03@gmail.com"
}
variable "aws_organizations_account_network_name" {
    description = "Network accounts name"
    default = "network"
}
variable "aws_organizations_account_network_email" {
    description = "Network accounts email"
    default = "test.gft.aws.04@gmail.com"
}