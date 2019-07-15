variable "name" {
  type        = "string"
  description = "Name of repository names to be created"
}

variable "createrepo" {
  type        = "string"
  default     = "true"
  description = "Flag to create repository"
}

variable "repo_names" {
  type    = "list"
  description = "List of names of repository names to be created"
}

variable "tag_prefix_list" {
  type        = "list"
  description = "List of image tag prefixes on which to take action with lifecycle policy."
}

variable "only_pull_accounts" {
  default     = []
  type        = "list"
  description = "AWS accounts which pull only."
}

variable "push_and_pull_accounts" {
  default     = []
  type        = "list"
  description = "AWS accounts which push and pull."
}

variable "max_untagged_image_count" {
  default     = 1
  type        = "string"
  description = "The maximum number of untagged images that you want to retain in repository."
}

variable "max_tagged_image_count" {
  default     = 30
  type        = "string"
  description = "The maximum number of tagged images that you want to retain in repository."
}