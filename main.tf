# Terraform とプロバイダーのバージョン情報を記載
terraform {
  required_version = "~> 1.9.5" # be consistent with `.terraform-version`

  required_providers {
    github = {
      source  = "integrations/github"
      version = "~> 5.36"
    }
  }

  backend "local" {
    path = "./terraform.tfstate"
  }
}

# 構築するリソースのプロバイダー情報を記載
# `< Organization Name >` 部分は適切な Organization Name に置き換えてください。
provider "github" {
  owner = "route06"
  app_auth {
    pem_file = var.pem_file
  }
}

resource "github_repository" "github_terraform_examples" {
  name                   = "github-terraform-examples"
  visibility             = "private"
  description            = "For managing GitHub organization using Terraform."
  auto_init              = true
  archive_on_destroy     = true
  has_issues             = true
  has_projects           = false
  has_wiki               = false
  has_discussions        = false
  has_downloads          = false
  allow_auto_merge       = false
  allow_merge_commit     = true
  allow_rebase_merge     = true
  allow_squash_merge     = true
  allow_update_branch    = false
  delete_branch_on_merge = true
  homepage_url           = ""
  is_template            = false
  vulnerability_alerts   = true
  security_and_analysis {
    advanced_security {
      status = "disabled"
    }
    secret_scanning {
      status = "disabled"
    }
    secret_scanning_push_protection {
      status = "disabled"
    }
  }
}

# tfstate ファイル
## Terraform が管理しているリソースの現在の状態を記録したファイル
variable "pem_file" {
  description = "The content of the PEM file"
  type        = string
}

import {
  to = github_repository.github_terraform_examples
  id = "github-terraform-examples"
}
