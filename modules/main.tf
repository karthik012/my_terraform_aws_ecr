# Resource to create repo 

resource "aws_ecr_repository" "default" {
  count = "${var.create_repo == "true" ?  length(var.repo_names) : 0}"
  name  = "${var.repo_names[count.index]}"
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
  count      = "${var.create_repo == "true" ?  length(var.repo_names) : 0}"
  repository = "${aws_ecr_repository.default[count.index].name}"
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

resource "aws_ecr_repository_policy" "default" {
  count      = "${var.create_repo == "true" ?  length(var.repo_names) : 0}"
  repository = "${aws_ecr_repository.default[count.index].name}"
  policy     = "${data.aws_iam_policy_document.push_and_pull.json}"
}

data "aws_caller_identity" "current" {}
