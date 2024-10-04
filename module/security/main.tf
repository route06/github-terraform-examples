# プロバイダーのバージョン情報を記載
terraform {
  required_providers {
    github = {
      source = "integrations/github"
    }
  }
}

# ユーザー情報のチェック
## 変数として渡された全てのユーザーの GitHub Username と GitHub id（ GitHub 登録時に発行される変更不能な整数）の組が意図したものである時のみ Organization に追加する
locals {
  users_map = { for user in var.users_defined : user.username => user }
  users_with_unexpected_id = [
    for username, user_info in data.github_user.this :
    username if user_info.id != local.users_map[username].id
  ]
  all_users_have_correct_id = length(local.users_with_unexpected_id) == 0
}

# GitHub からユーザー情報を取得
data "github_user" "this" {
  for_each = { for user in var.users_defined : user.username => user }
  username = each.value.username
}

#  評価されるとエラーを送出する
resource "null_resource" "fail_with_unexpected_user_id" {
  # 全てのユーザーの name-id が意図通りなら count が 0 になるので評価されない(エラーにならないので Action が失敗せず apply できる) 
  count = local.all_users_have_correct_id ? 0 : 1

  provisioner "local-exec" {
    command     = "echo 'Error: One or more users have mismatching IDs.' && exit 1"
    interpreter = ["/bin/sh", "-c"]
  }

  triggers = {
    always_run = timestamp() # timestamp() の内容は常に変化するので count が 1 ならば毎回評価される
  }
}

# Users.tfvars の全ユーザー情報
variable "users_defined" {
  description = "List of users"
  type = list(object({
    username = string
    id       = string
  }))
}
