.DEFAULT_GOAL:=help
.PHONY: help plan apply output

TF=terraform

-include .make.env

help:  ## Display this help
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make \033[36m\033[0m\n"} /^[a-zA-Z_-]+:.*?##/ { printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' $(MAKEFILE_LIST)

##@ Terraform

init: ## Initialize terraform
	# NOTE: we don't need to use ${TF} here since we're not doing anything with AWS yet
	terraform init

plan: ## Run terraform plan
	${TF} plan ${args}

apply: ## Run terraform apply
	${TF} apply ${args}

yolo: ## Run terraform apply with auto-approve
	${TF} apply --auto-approve ${args}

destroy: ## Destroy the infrastructure
	${TF} destroy

output: ## Run terraform output
	@${TF} output ${args}

##@ Utils

loadtest:
	siege -c 10 -t 10m $(shell cat terraform.tfstate | jq '.outputs.app1.value["lb-url"]')
