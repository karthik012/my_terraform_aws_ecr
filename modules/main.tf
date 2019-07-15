# Terraform module which creates ECR resources on AWS.

resource "aws_ecr_repository" "default" {
 name = "${var.repository_name}"
}

resource "aws_ecr_repository" "default" {
 count = "${var.create_repo == "true" ?  length(var.repo_names) : 0}"
 name = "${var.repo_names[count.index]}"
}

resource "aws_ecr_repository_policy" "default" {
  count = length(var.repo_names)
  repository = "${aws_ecr_repository.default[count.index].name}"
  policy     = "${data.aws_iam_policy_document.push_and_pull.json}"
}

resource "aws_ecr_repository_policy" "default" {
  repository = "${aws_ecr_repository.default.name}"
  policy     = "${data.aws_iam_policy_document.push_and_pull.json}"
}

# Allows specific accounts to pull images
data "aws_iam_policy_document" "only_pull" {
  statement {
    sid    = "ElasticContainerRegistryOnlyPull"
    effect = "Allow"

    principals {
      identifiers = ["${concat(list(local.current_account), local.only_pull_accounts)}"]
      type        = "AWS"
    }

    actions = [
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage",
      "ecr:BatchCheckLayerAvailability",
    ]
  }
}

# Allows specific accounts to push and pull images
data "aws_iam_policy_document" "push_and_pull" {
  # An IAM policy document to import as a base for the current policy document
  source_json = "${data.aws_iam_policy_document.only_pull.json}"

  statement {
    sid    = "ElasticContainerRegistryPushAndPull"
    effect = "Allow"

    principals {
      identifiers = ["${concat(list(local.current_account), local.push_and_pull_accounts)}"]
      type        = "AWS"
    }

    actions = [
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage",
      "ecr:BatchCheckLayerAvailability",
      "ecr:PutImage",
      "ecr:InitiateLayerUpload",
      "ecr:UploadLayerPart",
      "ecr:CompleteLayerUpload",
    ]
  }
}

resource "aws_ecr_lifecycle_policy" "default" {
  repository = "${aws_ecr_repository.default.name}"
  policy     = "${data.template_file.ecr_lifecycle_policy.rendered}"
}

data "template_file" "ecr_lifecycle_policy" {
  template = "${file("${path.module}/ecr_lifecycle_policy.json")}"

  vars {
    max_untagged_image_count = "${var.max_untagged_image_count}"
    max_tagged_image_count   = "${var.max_tagged_image_count}"
    tag_prefix_list          = "${jsonencode(var.tag_prefix_list)}"
  }
}

locals {
  only_pull_accounts     = "${formatlist("arn:aws:iam::%s:root", var.only_pull_accounts)}"
  push_and_pull_accounts = "${formatlist("arn:aws:iam::%s:root", var.push_and_pull_accounts)}"
  current_account        = "${format("arn:aws:iam::%s:root", data.aws_caller_identity.current.account_id)}"
}

data "aws_caller_identity" "current" {}
