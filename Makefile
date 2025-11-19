# Makefile for dropshiping-system- (cursor-1 branch)
# Common development tasks: env sync, dev server, tests, AI checks, security audit.

# Default shell
SHELL := /bin/bash

# Directory for scripts
SCRIPTS_DIR := scripts

# Path to env sync script
SYNC_ENV_SCRIPT := $(SCRIPTS_DIR)/sync_env.sh

# Helper: choose package runner (pnpm > npm > yarn)
define run_js
if command -v pnpm >/dev/null 2>&1; then \
  pnpm $(1); \
elif command -v npm >/dev/null 2>&1; then \
  npm run $(1); \
elif command -v yarn >/dev/null 2>&1; then \
  yarn $(1); \
else \
  echo "No pnpm / npm / yarn found. Install one of them."; \
  exit 1; \
fi
endef

.PHONY: help
help:
	@echo "Available targets:"
	@echo "  make sync-env    - Generate .env from Bitwarden CLI"
	@echo "  make dev         - Start dev server"
	@echo "  make test        - Run tests"
	@echo "  make lint        - Run linter"
	@echo "  make audit       - Run dependency security audit"
	@echo "  make ai-check    - Run AI pipeline (lint + test + audit)"
	@echo "  make install     - Install JS deps"
	@echo "  make check-tools - Verify required tools (bw, jq, node, git, .gitignore)"

.PHONY: sync-env
sync-env:
	@if [ ! -x "$(SYNC_ENV_SCRIPT)" ]; then \
	  echo "Fixing permissions for $(SYNC_ENV_SCRIPT)..."; \
	  chmod +x $(SYNC_ENV_SCRIPT); \
	fi
	@if [ -z "$$BW_SESSION" ]; then \
	  echo "BW_SESSION is not set."; \
	  echo "Run: export BW_SESSION=$$(bw unlock --raw)"; \
	  exit 1; \
	fi
	@echo "Syncing .env from Bitwarden..."
	@$(SYNC_ENV_SCRIPT)

.PHONY: dev
dev:
	@echo "Starting dev server..."
	@$(call run_js,dev)

.PHONY: test
test:
	@echo "Running tests..."
	@$(call run_js,test)

.PHONY: lint
lint:
	@echo "Running linter..."
	@$(call run_js,lint)

.PHONY: install
install:
	@echo "Installing JS dependencies..."
	@if command -v pnpm >/dev/null 2>&1; then \
	  pnpm install; \
	elif command -v npm >/dev/null 2>&1; then \
	  npm install; \
	elif command -v yarn >/dev/null 2>&1; then \
	  yarn install; \
	else \
	  echo "No pnpm / npm / yarn found. Install one of them."; \
	  exit 1; \
	fi

.PHONY: audit
audit:
	@echo "Running security audit..."
	@if command -v pnpm >/dev/null 2>&1; then \
	  pnpm audit --prod || true; \
	elif command -v npm >/dev/null 2>&1; then \
	  npm audit --production || true; \
	else \
	  echo "Skipping audit (no node package manager found)"; \
	fi
	@echo "✅ Security audit completed (check output above for any issues)."

.PHONY: ai-check
ai-check:
	@echo "Running AI check pipeline..."
	@$(MAKE) lint
	@$(MAKE) test
	@$(MAKE) audit
	@echo "🚀 AI Pipeline: lint + test + audit done."

.PHONY: check-tools
check-tools:
	@echo "Checking development tools..."
	@command -v git >/dev/null && echo "✅ git found" || echo "❌ git missing"
	@command -v node >/dev/null && echo "✅ node found" || echo "❌ node missing"
	@command -v bw >/dev/null && echo "✅ bw (Bitwarden) found" || echo "❌ bw missing"
	@command -v jq >/dev/null && echo "✅ jq found" || echo "❌ jq missing"
	@if [ -f .gitignore ]; then echo "✅ .gitignore exists"; else echo "❌ .gitignore MISSING (Security Risk)"; fi

