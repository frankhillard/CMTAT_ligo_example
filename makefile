SHELL := /bin/bash

ligo_compiler?=docker run --rm -v "$(PWD)":"$(PWD)" -w "$(PWD)" ligolang/ligo:1.2.0
# ^ Override this variable when you run make command by make <COMMAND> ligo_compiler=<LIGO_EXECUTABLE>
# ^ Otherwise use default one (you'll need docker)
PROTOCOL_OPT?=

project_root=--project-root .
# ^ required when using packages

help:
	@grep -E '^[ a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | \
	awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-15s\033[0m %s\n", $$1, $$2}'

compile = $(ligo_compiler) compile contract $(project_root) ./contract/$(1) -o ./compiled/$(2) $(3) $(PROTOCOL_OPT)
# ^ compile contract to michelson or micheline

test = $(ligo_compiler) run test $(project_root) ./test/$(1) $(PROTOCOL_OPT)
# ^ run given test file

clean: ## clean up
	@rm -rf compiled

compile: ## compile contract
	@echo "Compiling example contract..."
	@if [ ! -d ./compiled/ ]; then mkdir -p ./compiled/ ; fi
	@$(call compile,./extended_cmtat_single_asset.mligo,extended_cmtat_single_asset.mligo.json,--michelson-format json)
	@echo "Compiled contract!"

deploy: deploy_deps deploy.js

deploy.js:
	@echo "Running deploy script\n"
	@cd deploy && npm i && npm run deploy_example

deploy_deps:
	@echo "Installing deploy script dependencies"
	@cd deploy && npm install
	@echo ""

install: ## install dependencies
	@$(ligo_compiler) install

lint: ## lint code
	@npx eslint ./scripts --ext .ts