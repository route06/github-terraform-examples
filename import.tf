# このファイルは、既存のリソースを Terraform 管理下に置くための特別な構成ファイルです。  
# 既存のリポジトリを Terraform 管理下に置くためには import ブロックを使用する必要があります。
# `<Organization Name>` と `< GitHub Name >` 部分は適切な値に置き換えてください。
import {
  to = github_repository.terraform_operations
  id = "terraform-state-files"
}
import {
  to = github_repository.terraform_state_files
  id = "terraform-state-files"
}
import {
  to = github_membership.org_owner["< GitHub Name>"]
  id = "<Organization Name>:< GitHub Name>"
}
