TERRAFORM ?= terraform
TFLINT ?= tflint
DIR ?= .
APP_ID = ""  # will be set in GitHub Actions
APP_INSTALLATION_ID = ""  # will be set in GitHub Actions
TERRAFORM_VARS = -var-file=pem.tfvars -var-file=users.tfvars
TERRAFORM_PLAN_PATH = .terraform/terraform.plan
GITHUB_ACTIONS ?= false

confirm:
	@read -p "Continue? [$(ENVIRONMENT)] : " environment && [ "$$environment" = "$(ENVIRONMENT)" ]

init:
	@cd $(DIR) && \
	$(TERRAFORM) init

.PHONY: prepare
prepare: init validate

.PHONY: plan
plan: prepare
	@cd $(DIR) && \
	$(if $(filter true,$(GITHUB_ACTIONS)), export GITHUB_APP_ID=$(APP_ID) && \
	export GITHUB_APP_INSTALLATION_ID=$(APP_INSTALLATION_ID) && ,) \
	$(TERRAFORM) plan -no-color -lock=false $(TERRAFORM_VARS) -out $(TERRAFORM_PLAN_PATH)

plan-with-lock: prepare
	@cd $(DIR) && \
	$(if $(filter true,$(GITHUB_ACTIONS)), export GITHUB_APP_ID=$(APP_ID) && \
	export GITHUB_APP_INSTALLATION_ID=$(APP_INSTALLATION_ID) && ,) \
	$(TERRAFORM) plan -no-color -lock=true $(TERRAFORM_VARS) -out $(TERRAFORM_PLAN_PATH)

.PHONY: apply-force
apply-force: plan-with-lock
	@cd $(DIR) && \
	$(if $(filter true,$(GITHUB_ACTIONS)), export GITHUB_APP_ID=$(APP_ID) && \
	export GITHUB_APP_INSTALLATION_ID=$(APP_INSTALLATION_ID) && ,) \
	$(TERRAFORM) apply -no-color -lock=true $(TERRAFORM_PLAN_PATH)

format:  # useful in local development
	@cd $(DIR) && \
	$(TERRAFORM) fmt -diff -recursive

format-check:
	@cd $(DIR) && \
	$(TERRAFORM) fmt -diff -recursive -check

lint:
	@cd $(DIR) && \
	$(TERRAFORM) get && $(TFLINT) -c $(PWD)/.tflint.hcl; \

validate:
	@cd $(DIR) && \
	$(if $(filter true,$(GITHUB_ACTIONS)), export GITHUB_APP_ID=$(APP_ID) && \
	export GITHUB_APP_INSTALLATION_ID=$(APP_INSTALLATION_ID) && ,) \
	echo $$GITHUB_APP_ID && \
	echo $$GITHUB_APP_INSTALLATION_ID && \
	$(TERRAFORM) validate
