config {
  module = true
}

# awsのpluginでは以下のURLにある「Enabled by default」カラムのルールが適用されます。
# https://github.com/terraform-linters/tflint-ruleset-aws/tree/master/docs/rules
plugin "aws" {
    enabled = true
    version = "0.17.0"
    source  = "github.com/terraform-linters/tflint-ruleset-aws"
}

# terraform pluginで推奨とされるルールを適用します。
# ref.https://github.com/terraform-linters/tflint-ruleset-terraform/tree/main/docs/rules
# ref.https://github.com/terraform-linters/tflint-ruleset-terraform/blob/main/docs/configuration.md
plugin "terraform" {
    enabled = true
    preset = "recommended"
}