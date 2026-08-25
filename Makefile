.PHONY: help lint format generate breaking clean check

BUF := buf

help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-12s\033[0m %s\n", $$1, $$2}'

lint: ## Lint all protos
	$(BUF) lint

format: ## Format protos in place
	$(BUF) format -w

generate: ## Regenerate Go code into gen/go
	$(BUF) generate

breaking: ## Check for breaking changes against main
	$(BUF) breaking --against '.git#branch=main'

check: lint breaking ## Everything CI runs

clean: ## Remove generated code
	rm -rf gen/
