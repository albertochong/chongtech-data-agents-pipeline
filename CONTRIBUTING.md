# Contributing to ChongTech Agent Data Pipeline

Thank you for your interest in ChongTech Agent Data Pipeline! This guide will help you contribute effectively.

## Quick Start

```bash
# Fork and clone
git clone https://github.com/YOUR_USERNAME/chongtech-data-agents-pipeline.git
cd chongtech-data-agents-pipeline
git checkout -b feature/your-feature

# The framework lives in .claude/
ls .claude/agents/      # 58 specialized agents
ls .claude/commands/    # 31 slash commands
ls .claude/skills/      # 19 source skills (15 distributed + 4 repo-local); + 1 plugin-only in plugin-extras/
ls .claude/sdd/         # SDD framework
ls .claude/kb/          # Knowledge Base
```

## Ways to Contribute

| Type           | Where                          | Guide                                    |
|----------------|--------------------------------|------------------------------------------|
| New Agent      | `.claude/agents/{category}/`   | [Adding Agents](#adding-a-new-agent)     |
| New KB Domain  | `.claude/kb/{domain}/`         | [Adding KB Domains](#adding-a-kb-domain) |
| New Command    | `.claude/commands/{category}/` | [Adding Commands](#adding-a-command)     |
| New Skill      | `.claude/skills/{skill}/`      | [Adding Skills](#adding-a-skill)         |
| Bug Fix        | Any file                       | [Bug Fixes](#bug-fixes)                  |
| Documentation  | `docs/`                        | [Docs Guide](#documentation)             |

## Adding a New Agent

1. Copy the template:

   ```bash
   cp .claude/agents/_template.md .claude/agents/{category}/your-agent.md
   ```

2. Fill in the required sections:
   - **Identity block** — name, domain, trigger threshold
   - **Capabilities** — what the agent does (2-8 capabilities)
   - **Quality gate** — pre-flight checklist
   - **Response format** — expected output structure
   - **Anti-patterns** — what to avoid

3. Choose the right category:
   - `workflow/` — SDD phase agents
   - `architect/` — system-level design and architecture
   - `cloud/` — AWS, GCP, CI/CD, deployment
   - `platform/` — Microsoft Fabric specialists
   - `python/` — code quality, prompts, documentation
   - `test/` — testing, data quality, data contracts
   - `data-engineering/` — DE implementation specialists
   - `dev/` — developer productivity tools

4. Test with Claude Code:

   ```bash
   # Verify agent is discoverable
   claude> "What agents are available?"
   ```

## Adding a KB Domain

Use the built-in command:

```bash
claude> /create-kb redis
```

Or create manually:

```text
.claude/kb/your-domain/
├── index.md              # Domain overview
├── quick-reference.md    # Cheat sheet (max 100 lines)
├── concepts/             # Core concepts (max 150 lines each)
│   └── your-concept.md
└── patterns/             # Implementation patterns (max 200 lines each)
    └── your-pattern.md
```

Templates are in `.claude/kb/_templates/`. Register your domain in `.claude/kb/_index.yaml`.

## Adding a Command

1. Create `.claude/commands/{category}/your-command.md`
2. Include YAML frontmatter:

   ```yaml
   ---
   name: your-command
   description: What this command does
   ---
   ```

3. Reference the appropriate agent if applicable
4. Test: `claude> /your-command`

## Adding a Skill

Skills are reusable capability packs that power slash commands with templates, references, and scripts.

Before adding any component, decide the layer first — agents execute, skills teach how, commands are entrypoints, KBs are source-of-truth. The canonical model lives in `.claude/kb/shared/component-model.md`; the `component-model` skill walks the decision.

1. Create a directory: `.claude/skills/your-skill/`
2. Add a `SKILL.md` with YAML frontmatter (`name`, `description`)
3. Add supporting files:
   - `references/` — reference docs and patterns
   - `templates/` — output templates
   - `scripts/` — automation scripts (optional)
4. Create corresponding commands in `.claude/commands/your-skill/`

See existing skills (`visual-explainer`, `excalidraw-diagram`) for examples, and the `create-skill` skill for this repository's authoring conventions (naming, placement tiers, frontmatter pitfalls, ship checklist).

## Bug Fixes

1. Check [existing issues](https://github.com/albertochong/chongtech-data-agents-pipeline/issues)
2. Create a branch: `git checkout -b fix/description`
3. Make your fix
4. Submit a PR with a clear description of the problem and solution

## Documentation

- Keep markdown files ATX-style (`#`, `##`, `###`)
- Use fenced code blocks with language identifiers
- Keep tables properly aligned
- Test all links before submitting

## Pull Request Process

1. Fork the repository
2. Create a feature branch from `main`
3. Make changes following the style guidelines above
4. Test with Claude Code to ensure commands and agents work
5. Submit a PR with:
   - Clear title (e.g., "Add redis KB domain" or "Fix brainstorm agent quality gate")
   - Description of what changed and why
   - Link to related issue if applicable

## Plugin Development

ChongTech Agent Data Pipeline is distributed as a Claude Code plugin. The development workflow:

1. **Develop in `.claude/`** — this is the source of truth
2. **Build the plugin** — run `bash build-plugin.sh` (or `make build`) to generate `plugin/`
3. **Test locally** — run `claude --plugin-dir ./plugin`
4. **Iterate** — make changes in `.claude/`, rebuild, reload with `/reload-plugins`

### Pre-Push Validation (activates automatically — nothing to run separately)

There is no extra setup step to remember. `make build`, `make test`, and `make check`
all depend on `install-hooks`, so the very first one you run — which you'd run anyway,
per the workflow above — silently points git at the repo's versioned hooks in
`scripts/git-hooks/` (via `git config core.hooksPath`). From then on, every `git push`
automatically rebuilds `plugin/` and runs the test suite first — the same checks CI
would run, but *before* the push leaves your machine, not after. A stale `plugin/` or
a failing test blocks the push with an explanation; a deliberate exception can bypass
it with `git push --no-verify`. The hook script itself lives at
`scripts/git-hooks/pre-push` if you want to read or extend it, and `make install-hooks`
still works standalone if you want to activate it without a full build.

### Key Concepts

- **`.claude/`** contains agents, commands, skills, KB, SDD — your development environment
- **`plugin/`** is the generated distributable (built from `.claude/` by the build script)
- **`plugin-extras/`** contains plugin-only content (new skills, hooks, scripts) that don't belong in `.claude/`
- **`build-plugin.sh`** copies `.claude/` → `plugin/`, rewrites `.claude/` paths to `${CLAUDE_PLUGIN_ROOT}/`, then merges `plugin-extras/`

### Path Convention

In `.claude/` (source), reference paths as `.claude/kb/dbt/index.md`.
In plugin output, these become `${CLAUDE_PLUGIN_ROOT}/kb/dbt/index.md`.
Workspace output paths (`.claude/sdd/features/`, `.claude/sdd/reports/`, `.claude/sdd/archive/`) stay as-is — they point to the user's project.

### Adding Plugin-Only Content

If you create something that only exists in the plugin (not in `.claude/`), add it to `plugin-extras/`:
- New skills → `plugin-extras/skills/{skill-name}/SKILL.md`
- Hooks → `plugin-extras/hooks/hooks.json`
- Scripts → `plugin-extras/scripts/{script-name}.sh`

### Dev Tooling Reference

Everything outside `.claude/`, `plugin/`, and `plugin-extras/` supports the build/release
process rather than being part of the distributed plugin itself. A visual walkthrough of
how it all connects is in [`pipeline-diagram.html`](pipeline-diagram.html) (open it directly
in a browser); the short version:

| Path | What it's for | Runs |
|---|---|---|
| `scripts/generate-agent-router.py` | Regenerates the agent-router skill from agent frontmatter | Automatically, as part of `build-plugin.sh` / `make build` |
| `scripts/judge.py` | Backend for the `/judge` command — sends a spec to another model via OpenRouter for a second opinion | On demand, when a user runs `/judge` inside Claude Code — never part of the build |
| `scripts/bump.sh` | Version-bump gate — checks `plugin.json`/`marketplace.json` version was correctly incremented | Manually (`bash scripts/bump.sh --check`) or automatically via `bump-gate.yml` on PRs |
| `scripts/git-hooks/pre-push` | The pre-push validation hook described above | Automatically on `git push`, once `make install-hooks` has been run |
| `tests/` | Pytest suite for `scripts/generate-agent-router.py` and `scripts/judge.py` (pure-function tests, no network calls) | `make test` |
| `tools/spec-linter`, `tools/spec-judge` | Independent Python packages (own `pyproject.toml`) — the contract Linter and behavioral Judger used by the SDD phase commands; copied into `plugin/tools/` during build | `make spec-lint` / `make spec-judge`; used at runtime by `/design --judge`, `/build --judge`, etc. |
| `.github/workflows/quality-checks.yml` | Runs `pytest`, agent-router drift check, `shellcheck`, and the `tools/` test suites | Automatically on push/PR |
| `.github/workflows/plugin-validate.yml` | Rebuilds the plugin and validates `plugin.json`/`marketplace.json`, checks for unrewritten `.claude/` paths, counts agents/skills/KBs | Automatically on push/PR touching `.claude/`, `plugin-extras/`, or `build-plugin.sh` |
| `.github/workflows/bump-gate.yml` | Runs `scripts/bump.sh --check` | Automatically on PRs into `main`/`develop` |
| `.github/workflows/e2e.yml` | Installs the built plugin via a real Claude Code CLI in a sandboxed `HOME` and asserts it matches `plugin/` | Automatically on push/PR |

None of the `.github/workflows/*.yml` files are ever run manually — GitHub Actions triggers
them on `push`/`pull_request` after code reaches the remote. Everything else in this table is
either invoked directly by you, or invoked automatically by `build-plugin.sh`/the pre-push
hook on your own machine, before anything is sent to GitHub.

## Code of Conduct

We follow the [Contributor Covenant](https://www.contributor-covenant.org/). Be respectful, constructive, and inclusive.

## Questions?

- [Open an issue](https://github.com/albertochong/chongtech-data-agents-pipeline/issues)
- [Start a discussion](https://github.com/albertochong/chongtech-data-agents-pipeline/discussions)
