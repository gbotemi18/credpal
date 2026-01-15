TERRAFORM_DIR ?= terraform
TERRAFORM_BIN ?= terraform
TF_PLUGIN_TIMEOUT ?= 5m

.PHONY: tf-fmt tf-init tf-validate tf-plan tf-apply

tf-fmt:
	cd $(TERRAFORM_DIR) && TF_PLUGIN_TIMEOUT=$(TF_PLUGIN_TIMEOUT) $(TERRAFORM_BIN) fmt -recursive

tf-init:
	cd $(TERRAFORM_DIR) && TF_PLUGIN_TIMEOUT=$(TF_PLUGIN_TIMEOUT) $(TERRAFORM_BIN) init -backend=false

tf-validate:
	cd $(TERRAFORM_DIR) && TF_PLUGIN_TIMEOUT=$(TF_PLUGIN_TIMEOUT) $(TERRAFORM_BIN) validate

# Add -var/-var-file flags as needed; example:
# make tf-plan EXTRA_ARGS='-var "container_image=..." -var "domain_name=..." -var "hosted_zone_id=..."'
tf-plan:
	cd $(TERRAFORM_DIR) && TF_PLUGIN_TIMEOUT=$(TF_PLUGIN_TIMEOUT) $(TERRAFORM_BIN) plan $(EXTRA_ARGS)

tf-apply:
	cd $(TERRAFORM_DIR) && TF_PLUGIN_TIMEOUT=$(TF_PLUGIN_TIMEOUT) $(TERRAFORM_BIN) apply $(EXTRA_ARGS)

