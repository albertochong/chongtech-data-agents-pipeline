# ============================================================================
# AgentSpec — developer Makefile
# ============================================================================
# Single entry point for everything a contributor needs to do locally.
# Every target is idempotent and safe to re-run.
#
# Quick start:
#   make help          # show all targets
#   make build         # full plugin build (tests + generate + package)
#   make test          # pytest suite only
#   make check         # drift check (tests + --check on generators)
#   make lint          # shellcheck + markdown warnings
#
# No separate setup step after cloning: `build`, `test`, and `check` all
# depend on `install-hooks`, so the very first one you run also silently
# activates the versioned pre-push validation hook (scripts/git-hooks/).
# ============================================================================

# Use bash so we get [[ ]], set -u, etc. — not POSIX sh.
SHELL := /usr/bin/env bash

.DEFAULT_GOAL := help
.PHONY: help build test check lint clean generate plugin install-deps spec-lint spec-judge install-hooks sync-agents-md

# ----------------------------------------------------------------------------
# Help
# ----------------------------------------------------------------------------

help: ## Show this help
	@echo "AgentSpec — developer targets"
	@echo ""
	@awk 'BEGIN {FS = ":.*##"; printf "  %-18s %s\n", "TARGET", "DESCRIPTION"; printf "  %-18s %s\n", "------", "-----------"} /^[a-zA-Z_-]+:.*?##/ { printf "  \033[36m%-18s\033[0m %s\n", $$1, $$2 }' $(MAKEFILE_LIST)
	@echo ""
	@echo "Most-used: make build  |  make test  |  make check"

# ----------------------------------------------------------------------------
# Core targets
# ----------------------------------------------------------------------------

build: install-hooks ## Full plugin build (tests + regenerate agent-router + package)
	@./build-plugin.sh

test: install-hooks ## Run pytest suite
	@python3 -m pytest tests/ -v

check: install-hooks ## Drift check — tests + generators in --check mode (fails on drift)
	@python3 -m pytest tests/ -q
	@python3 scripts/generate-agent-router.py --check

generate: ## Regenerate agent-router artifacts (SKILL.md + routing.json)
	@python3 scripts/generate-agent-router.py

plugin: build ## Alias for `make build`

spec-lint: ## Run the spec-linter component test suite (tools/spec-linter)
	@if [ -x tools/spec-linter/.venv/bin/python ]; then \
		( cd tools/spec-linter && .venv/bin/python -m pytest -v ); \
	elif python3 -c "import pydantic, yaml" >/dev/null 2>&1; then \
		( cd tools/spec-linter && python3 -m pytest -v ); \
	else \
		echo "No tools/spec-linter/.venv and system python3 lacks pydantic/pyyaml."; \
		echo "One-time setup:"; \
		echo "  cd tools/spec-linter && uv venv --python 3.12 .venv && uv pip install -e '.[dev]'"; \
		echo "See tools/spec-linter/README.md."; \
		exit 1; \
	fi

spec-judge: ## Run the spec-judge component test suite (tools/spec-judge, offline)
	@if [ -x tools/spec-judge/.venv/bin/python ]; then \
		( cd tools/spec-judge && .venv/bin/python -m pytest -v ); \
	elif python3 -c "import pydantic, yaml, spec_linter" >/dev/null 2>&1; then \
		( cd tools/spec-judge && python3 -m pytest -v ); \
	else \
		echo "No tools/spec-judge/.venv and system python3 lacks pydantic/pyyaml/spec_linter."; \
		echo "One-time setup:"; \
		echo "  cd tools/spec-judge && uv venv --python 3.12 .venv && uv pip install -e '.[dev]' -e ../spec-linter"; \
		echo "See tools/spec-judge/README.md."; \
		exit 1; \
	fi

# ----------------------------------------------------------------------------
# Hygiene
# ----------------------------------------------------------------------------

lint: ## Lint shell scripts via shellcheck (skips gracefully if not installed)
	@if command -v shellcheck >/dev/null 2>&1; then \
		echo "Running shellcheck..."; \
		shellcheck -S warning \
			build-plugin.sh \
			.claude/skills/visual-explainer/scripts/share.sh \
			plugin-extras/scripts/init-workspace.sh; \
	else \
		echo "shellcheck not installed — brew install shellcheck"; \
		exit 0; \
	fi

sync-agents-md: ## Sync AGENTS.md <-> CLAUDE.md (newer file wins; must stay identical)
	@bash scripts/sync-agents-md.sh

clean: ## Remove generated plugin/ artifacts (keep .claude-plugin/)
	@find plugin -mindepth 1 -maxdepth 1 \
		! -name '.claude-plugin' \
		! -name 'README.md' \
		-exec rm -rf {} + 2>/dev/null || true
	@echo "Plugin artifacts cleaned. Run 'make build' to rebuild."

install-deps: ## Install optional dev dependencies (pytest, shellcheck)
	@echo "Installing pytest..."
	@python3 -m pip install --user pytest
	@if ! command -v shellcheck >/dev/null 2>&1; then \
		echo ""; \
		echo "shellcheck not installed. On macOS:  brew install shellcheck"; \
		echo "                        On Linux:    apt-get install shellcheck"; \
	fi

install-hooks: ## Activate the versioned pre-push hook (auto-run by build/test/check; safe to re-run)
	@if [ "$$(git config --get core.hooksPath 2>/dev/null)" != "scripts/git-hooks" ]; then \
		git config core.hooksPath scripts/git-hooks; \
		chmod +x scripts/git-hooks/*; \
		echo "[hooks] Activated: 'git push' now runs a build + test check first (bypass with --no-verify)."; \
	fi
