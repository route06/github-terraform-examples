# このファイルは、既存のリソースを Terraform 管理下に置くための特別な構成ファイルです。  
# 既存のリポジトリを Terraform 管理下に置くためには import ブロックを使用する必要があります。
# `terraform-operations` と `terraform-state-files`はそれぞれ作成したリポジトリ名に変更してください。( リソース名も同様 )
# `<Organization Name>` と `< GitHub Username >` 部分は適切な値に置き換えてください。
import {
  to = github_repository.terraform_operations
  id = "terraform-operations"
}
import {
  to = github_repository.terraform_state_files
  id = "terraform-state-files"
}
import {
  to = github_membership.org_owner["< GitHub Username >"]
  id = "<Organization Name>:< GitHub Username >"
}
