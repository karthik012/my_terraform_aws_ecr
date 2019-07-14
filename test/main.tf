provider "aws" {
  region = "us-east-1"
}  

module "ecr" {
  source          = "../modules/"
  name            = ""
  name_list       = ["testrepo1","testrepo2"]
  tag_prefix_list = ["release"]

  # If invalid account such as "123456789012" is specified, then cause error with following message.
  # Invalid parameter at 'PolicyText' failed to satisfy constraint: 'Invalid repository policy provided'
  only_pull_accounts       = []
  push_and_pull_accounts   = []
  max_untagged_image_count = 1
  max_tagged_image_count   = 50
}