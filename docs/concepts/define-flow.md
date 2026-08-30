# Define Flow

This document traces Phase 1 of the SDD workflow from a `/define` invocation to the handoff to `/design`. It explains input classification, requirements extraction, clarity scoring, contract validation, optional cross-model review, status transitions, and the files involved at each step.

The operational rules remain canonical in the referenced source files. This page is the readable execution map.

## When Define Runs

Define is the first required SDD phase. It accepts the artifact produced by Brainstorm, but it can also start directly from requirements that are already clear enough to structure.

With the plugin installed, common invocations are:

```text
/chongtech-agent-data-pipeline:define .claude/sdd/features/BRAINSTORM_ORDERS_PIPELINE.md
/chongtech-agent-data-pipeline:define "Daily orders pipeline from Postgres to Snowflake"
/chongtech-agent-data-pipeline:define notes/meeting-notes.md
```

Repository documentation often uses the shorter `/define` name for the same phase.

## End-to-End Flow

```text
BRAINSTORM_*.md, notes, email, conversation, or direct requirements
        │
        ▼
User invokes /define <input> [--judge[=MODE]]
        │
        ▼
commands/workflow/define.md
        │  entrypoint, Judge flag, output path, next phase
        ▼
define-agent + sdd-define
        │  executor boundaries + Phase 1 methodology
        ├─ load project, template, input, and KB index
        ├─ classify the input
        ├─ extract requirements entities
        ├─ gather technical context
        └─ gather data-contract context when applicable
        │
        ▼
Clarity score: Problem + Users + Goals + Success + Scope
        │
        ├─ 0-8   → block and clarify
        ├─ 9-11  → ask targeted questions, then re-score
        └─ 12-15 → pass the clarity gate
        │
        ▼
Render DEFINE_TEMPLATE.md
        │
        ▼
.claude/sdd/features/DEFINE_{FEATURE}.md
        │
        ▼
spec-linter phase contract
        │
        ├─ exit 0 PASS/WARN → proceed; record WARN
        ├─ exit 1 FAIL      → block and correct the document
        └─ exit 2 ERROR     → report visible skip; proceed without claiming PASS
        │
        ├─ no --judge → finalize phase
        │
        └─ --judge → optional OpenRouter second opinion
              ├─ advisory FAIL → report concerns; phase may complete
              └─ strict FAIL   → block completion
        │
        ▼
DEFINE status: Ready for Design
BRAINSTORM status: Complete (Defined), when used as input
        │
        ▼
/design .claude/sdd/features/DEFINE_{FEATURE}.md
```

## Component Responsibilities

| Layer | Source file | Responsibility |
|-------|-------------|----------------|
| Command | `.claude/commands/workflow/define.md` | User entrypoint, input and Judge flags, output location, and handoff |
| Agent | `.claude/agents/workflow/define-agent.md` | Executor identity, model, tools, stop conditions, and escalation |
| Skill | `.claude/skills/sdd-define/SKILL.md` | Input classification, extraction, technical context, clarity scoring, gap filling, gate, and status procedure |
| Contract | `.claude/sdd/architecture/WORKFLOW_CONTRACTS.yaml` | Authoritative input types, required sections, score threshold, statuses, and linter binding |
| Template | `.claude/sdd/templates/DEFINE_TEMPLATE.md` | Required structure of the generated artifact |
| Knowledge Base | `.claude/kb/_index.yaml` and selected domains | Domain selection for the Design phase |
| Linter | `tools/spec-linter/` | Deterministic validation of required Markdown sections |
| Judge V0 | `scripts/judge.py` | Optional OpenRouter review requested through `--judge` |
| Artifact | `.claude/sdd/features/DEFINE_{FEATURE}.md` | Validated requirements consumed by `/design` |

This follows the component model: the command exposes the interface, the agent supplies execution boundaries, the skill owns the process, the contract defines obligations, and the template owns document shape.

## Runtime Sequence

### 1. Load the Command

The command accepts six input classes:

| Input class | Typical source | Define behavior |
|-------------|----------------|-----------------|
| Brainstorm document | `BRAINSTORM_*.md` | Reuse validated discovery, approach, and scope decisions |
| Meeting notes | Bullets, actions, decisions | Separate decisions from requirements and gaps |
| Email thread | Requests, constraints, replies | Consolidate the latest agreed intent |
| Conversation | Informal description | Extract the core problem and ask for missing structure |
| Direct requirement | Already structured request | Validate completeness and measurability |
| Mixed sources | Multiple files or formats | Consolidate and deduplicate before scoring |

The optional `--judge` flag is parsed by the command after the normal Define artifact has been written.

### 2. Establish the Execution Context

The workflow contract maps `/define` to `define-agent` and `sdd-define`. The agent declares a Sonnet T2 executor with read, write, search, shell, task-tracking, and user-question tools. It may finish only when:

- The clarity score is at least 12/15.
- The problem, users, goals, success criteria, and scope have been extracted.
- The DEFINE artifact has been saved under `.claude/sdd/features/`.

The agent keeps the phase focused on **what** and **why**. Architecture and implementation choices belong to Design.

#### Current wiring note

The command instructs the active Claude context to load `sdd-define` directly; it does not contain an explicit subagent invocation. The contract and agent files declare `define-agent` as the executor, and the host may select it, but the command itself does not force that delegation.

The explicit repository path today is:

```text
/define → sdd-define skill
```

The declared architectural path is:

```text
/define → define-agent → sdd-define skill
```

### 3. Load Context and Discover Knowledge

The skill loads:

1. `CLAUDE.md` for project-specific instructions and architecture.
2. The provided file when the input is a path.
3. `.claude/sdd/templates/DEFINE_TEMPLATE.md` for the output shape.
4. `.claude/kb/_index.yaml` to identify relevant knowledge domains.
5. Project files needed to establish location and infrastructure impact.

The selected KB domains are recorded in the DEFINE artifact because Design uses them to retrieve implementation patterns.

### 4. Extract Requirements Entities

Define normalizes the input into these entities:

- A specific problem statement.
- Target users and their pain points.
- Goals classified as MUST, SHOULD, or COULD.
- Measurable success criteria.
- Testable Given/When/Then acceptance tests.
- Constraints.
- Explicit out-of-scope items.
- Assumptions with the impact if each assumption is wrong.

This step converts exploratory assumptions from Brainstorm into a trackable risk register.

### 5. Gather Technical and Data Context

Define asks for three technical facts when the input does not already provide them:

1. The intended code or deployment location.
2. The KB domains that apply.
3. Whether infrastructure must be created or changed.

For pipelines, ETL, analytics, warehouses, schemas, or data-quality work, it also extracts:

- Source systems and owners.
- Expected volumes.
- Freshness SLAs.
- Schema contracts.
- Completeness metrics.
- Lineage requirements.

The conditional data content is written into the template's `Data Contract` section rather than a separate artifact.

### 6. Calculate the Clarity Score

Five elements receive 0-3 points each:

| Element | Maximum | Question answered |
|---------|---------|-------------------|
| Problem | 3 | Is the pain specific and actionable? |
| Users | 3 | Are users identified with concrete pain points? |
| Goals | 3 | Are the desired outcomes explicit? |
| Success | 3 | Can completion be measured and tested? |
| Scope | 3 | Are boundaries and exclusions explicit? |

The result controls the branch:

| Score | Status | Action |
|-------|--------|--------|
| 12-15 | High | Continue toward `/design` |
| 9-11 | Medium | Ask targeted questions, then re-score |
| 0-8 | Low | Block and clarify the request |

The agent targets the lowest-scoring elements first and must not invent requirements to reach 12 points.

### 7. Apply the Phase Quality Gate

The skill's pre-flight gate checks semantic readiness: a clear problem, identified users, prioritized goals, measurable success, testable acceptance cases, explicit exclusions, assumptions, KB domains, technical context, and a score of at least 12/15.

When the score remains below 12, the document may be saved as `Needs Clarification`, but the phase does not complete and `/design` is not the valid next step.

The canonical checklist lives in `sdd-define/SKILL.md`; this document does not replace it.

### 8. Generate the DEFINE Artifact

After the clarity gate passes, the skill renders:

```text
.claude/sdd/features/DEFINE_{FEATURE}.md
```

`{FEATURE}` uses `SCREAMING_SNAKE_CASE`, for example:

```text
.claude/sdd/features/DEFINE_ORDERS_PIPELINE.md
```

The template contains metadata, problem, users, MoSCoW goals, success criteria, acceptance tests, scope, constraints, technical context, an optional data contract, assumptions, clarity breakdown, open questions, and revision history.

The DEFINE status moves through:

```text
Draft → In Progress → Needs Clarification | Ready for Design
```

### 9. Run the Deterministic Contract Gate

Before the handoff, the skill runs the phase document through `spec-linter` using the Define `required_sections` from `WORKFLOW_CONTRACTS.yaml`:

```bash
tools/spec-linter/spec-lint .claude/sdd/features/DEFINE_{FEATURE}.md \
  --phase define \
  --contracts-file .claude/sdd/architecture/WORKFLOW_CONTRACTS.yaml
```

The installed plugin uses `${CLAUDE_PLUGIN_ROOT}/tools/spec-linter/spec-lint` and the plugin copy of the contract.

| Exit | Meaning | Define behavior |
|------|---------|-----------------|
| 0 | PASS or WARN | Proceed; record any WARN finding |
| 1 | FAIL | Block and correct the missing required sections |
| 2 | Operational error or unavailable linter | Report the skipped check visibly, proceed, and never claim a PASS |

This gate checks required Markdown headings. It does not prove that the requirements are correct, that the clarity score is honest, or that the acceptance tests are meaningful; those remain semantic responsibilities of the skill and optional Judge.

### 10. Run the Optional Judge Branch

`--judge` requests a second opinion through OpenRouter after the DEFINE file is written.

| Invocation | Mode | Intended behavior on FAIL |
|------------|------|---------------------------|
| `--judge` | Advisory | Show concerns and allow phase completion |
| `--judge=MODEL` | Advisory with selected model | Show concerns and allow phase completion |
| `--judge=strict` | Gated | Block phase completion |
| `--judge=strict:MODEL` | Gated with selected model | Block phase completion |

Without an explicit model, Define uses `openai/gpt-4o`. The Judge focuses on vague acceptance criteria, ambiguous scope, assumptions presented as fact, contradictions, missing non-functional requirements, user gaps, and unmeasurable success criteria.

Judge exit codes are:

| Exit | Meaning | Command behavior |
|------|---------|------------------|
| 0 | PASS | Continue |
| 1 | FAIL | Advisory mode reports it; strict mode blocks |
| 2 | Configuration error | Report setup error and continue without Judge |
| 3 | Daily budget exhausted | Report ledger status and continue without Judge |
| 4 | Network or API error | Report the error and continue advisory |

#### Current Judge implementation notes

The phase command currently invokes the legacy `scripts/judge.py` V0 path, not the newer `tools/spec-judge` engine described by the contract's behavioral-enforcement prototype.

Two gaps affect the installed plugin:

1. `build-plugin.sh` does not copy the repository's `scripts/judge.py` into `plugin/scripts/`; the built command references a file that is absent there.
2. The strict-failure guidance mentions `--force`, but the current command flag table and `judge.py` parser do not implement a `--force` option.

The skill updates statuses before the command-level Judge branch, while strict Judge failure says the phase must remain incomplete. The current instructions do not define an explicit transactional order or rollback procedure for that status. Treat strict completion status as unresolved wiring until the command and skill agree on finalization order.

### 11. Update Statuses and Hand Off

On successful completion:

1. Set the DEFINE document to `Ready for Design`.
2. If the input was `BRAINSTORM_{FEATURE}.md`, change its status to `✅ Complete (Defined)`.
3. Recommend:

```text
/design .claude/sdd/features/DEFINE_{FEATURE}.md
```

Design consumes the DEFINE artifact's problem, success criteria, acceptance tests, technical context, data contract, and selected KB domains to produce architecture and a file manifest.

## Source Tree and Installed Plugin

`.claude/` is the development source of truth. `build-plugin.sh` copies it into the distributable `plugin/` tree and rewrites internal references:

| Development source | Installed plugin |
|--------------------|------------------|
| `.claude/commands/workflow/define.md` | `${CLAUDE_PLUGIN_ROOT}/commands/workflow/define.md` |
| `.claude/agents/workflow/define-agent.md` | `${CLAUDE_PLUGIN_ROOT}/agents/workflow/define-agent.md` |
| `.claude/skills/sdd-define/SKILL.md` | `${CLAUDE_PLUGIN_ROOT}/skills/sdd-define/SKILL.md` |
| `.claude/sdd/templates/DEFINE_TEMPLATE.md` | `${CLAUDE_PLUGIN_ROOT}/sdd/templates/DEFINE_TEMPLATE.md` |
| `.claude/sdd/architecture/WORKFLOW_CONTRACTS.yaml` | `${CLAUDE_PLUGIN_ROOT}/sdd/architecture/WORKFLOW_CONTRACTS.yaml` |
| `tools/spec-linter/` | `${CLAUDE_PLUGIN_ROOT}/tools/spec-linter/` |
| `scripts/judge.py` | Expected at `${CLAUDE_PLUGIN_ROOT}/scripts/judge.py`, but currently not copied |

Workspace output paths are preserved. An installed plugin writes `DEFINE_{FEATURE}.md` to the user's `.claude/sdd/features/` directory, not inside `${CLAUDE_PLUGIN_ROOT}`.

## Change Map

| Desired change | Edit |
|----------------|------|
| Invocation syntax, Judge flags, or handoff | `.claude/commands/workflow/define.md` |
| Model, tools, stop conditions, or escalation | `.claude/agents/workflow/define-agent.md` |
| Extraction, scoring, questions, gates, or status procedure | `.claude/skills/sdd-define/SKILL.md` |
| DEFINE document sections | `.claude/sdd/templates/DEFINE_TEMPLATE.md` |
| Required sections, score threshold, or status contract | `.claude/sdd/architecture/WORKFLOW_CONTRACTS.yaml` |
| Deterministic phase validation | `tools/spec-linter/` |
| Legacy optional OpenRouter review | `scripts/judge.py` |
| Technical requirements knowledge | Relevant `.claude/kb/<domain>/` files |

After changing anything under `.claude/`, `tools/`, `plugin-extras/`, or `build-plugin.sh`, run `make build` and inspect the generated `plugin/` diff.

## Canonical References

- [Define command](../../.claude/commands/workflow/define.md)
- [Define agent](../../.claude/agents/workflow/define-agent.md)
- [Define skill](../../.claude/skills/sdd-define/SKILL.md)
- [Define template](../../.claude/sdd/templates/DEFINE_TEMPLATE.md)
- [Workflow contracts](../../.claude/sdd/architecture/WORKFLOW_CONTRACTS.yaml)
- [Spec-linter usage](../../tools/spec-linter/USAGE.md)
- [Judge V0](../../scripts/judge.py)
- [Brainstorm flow](brainstorm-flow.md)
- [Design command](../../.claude/commands/workflow/design.md)

