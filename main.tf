# Terraform とプロバイダーのバージョン情報を記載
terraform {
  required_version = "~> 1.9.5" # be consistent with `.terraform-version`

  required_providers {
    github = {
      source  = "integrations/github"
      version = "~> 6.3"
    }
  }

  backend "local" {
    path = "./terraform.tfstate"
  }
}

# 構築するリソースのプロバイダー情報を記載
# `< Organization Name >` 部分は適切な Organization Name に置き換えてください。
provider "github" {
  owner = "< Organization Name >"
  app_auth {
    pem_file = var.pem_file
  }
}

locals {
  users_usernames     = [for user in var.users : user.username]                # user.tfvars から username を取得
  org_owner_usernames = setintersection(local.users_usernames, var.org_owners) # Organization owner の username
}

# Organization owner
# `depends_on` を設定することで module "security" が実行された後に処理されるようにしています
resource "github_membership" "org_owner" {
  for_each = toset(local.org_owner_usernames)

  username = each.value
  role     = "admin"

  depends_on = [
    module.security
  ]
}

# リポジトリの作成 Terraform 操作するリポジトリの作成（ terraform-operations ）
# `terraform-operations` は作成したリポジトリ名に変更してください。
# `terraform_operations` はリソース名になります。リポジトリ名と合わせた方が良いですが、`-`が使えないので`_`に置き換えてください。
# 各項目については公式ドキュメントを参考に変更してください。
# 公式ドキュメント → https://registry.terraform.io/providers/integrations/github/latest/docs/resources/repository
resource "github_repository" "terraform_operations" {
  name                   = "terraform-operations"
  description            = "Organization 配下のリソースを管理する Terraform ソースの置き場所"
  visibility             = "private"
  allow_auto_merge       = false
  allow_merge_commit     = true
  allow_rebase_merge     = true
  allow_squash_merge     = true
  allow_update_branch    = false
  delete_branch_on_merge = true
  has_discussions        = false
  has_issues             = true
  has_projects           = false
  has_wiki               = false
  homepage_url           = null
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

# tfstate ファイルを管理するリポジトリの作成（ terraform-state-files ）
# `terraform-state-files`は作成したリポジトリ名に変更してください。
# `terraform_state_files`はリソース名になります。リポジトリ名と合わせた方が良いですが、`-`が使えないので`_`に置き換えてください。
resource "github_repository" "terraform_state_files" {
  name                   = "terraform-state-files"
  description            = "リポジトリ `github-operations` の GitHub Actions から利用される Terraform state file を保管する"
  visibility             = "private"
  allow_auto_merge       = false
  allow_merge_commit     = true
  allow_rebase_merge     = true
  allow_squash_merge     = true
  allow_update_branch    = false
  delete_branch_on_merge = false
  has_discussions        = false
  has_issues             = false
  has_projects           = false
  has_wiki               = false
  homepage_url           = null
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

# ユーザーの GitHub Username と GitHub ID のチェック
module "security" {
  source = "./module/security"

  users_defined = var.users
}

# tfstate ファイル
## Terraform が管理しているリソースの現在の状態を記録したファイル
variable "pem_file" {
  description = "The content of the PEM file"
  type        = string
}

# Users.tfvars の Organization owner 情報
variable "org_owners" {
  description = "List of users to assign the 'owner' role for the organization"
  type        = list(string)
}

# Users.tfvars の全ユーザー情報
variable "users" {
  description = "List of users"
  type = list(object({
    username = string
    id       = string
  }))
}
