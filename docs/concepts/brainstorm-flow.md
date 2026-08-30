# Brainstorm Flow

This document traces Phase 0 of the SDD workflow from the `/brainstorm` invocation to the handoff to `/define`. It explains how the command, workflow agent, skill, Knowledge Base, template, and workflow contract fit together.

The operational rules remain canonical in the referenced source files. This page is the readable execution map.

## When Brainstorm Runs

Brainstorm is optional. Use it when the input is a raw idea, an unclear problem, or a comparison between possible approaches. Start with `/define` when the requirements and intended approach are already clear.

With the plugin installed, invoke the namespaced command:

```text
/chongtech-agent-data-pipeline:brainstorm "Daily orders pipeline from Postgres to Snowflake"
```

Repository documentation often uses the shorter `/brainstorm` name for the same phase.

## End-to-End Flow

```text
Claude Code SessionStart
        │
        ├─ create .claude/sdd/{features,reports,archive}/
        └─ detect the project stack
        │
        ▼
User invokes /brainstorm <idea-or-file>
        │
        ▼
commands/workflow/brainstorm.md
        │  entrypoint, arguments, output path, next phase
        ▼
brainstorm-agent + sdd-brainstorm
        │  executor boundaries + Phase 0 methodology
        ├─ read project context
        ├─ discover relevant KB domains
        ├─ ask discovery and sample questions
        ├─ compare 2-3 approaches
        ├─ apply YAGNI
        └─ validate incrementally with the user
        │
        ▼
Phase 0 quality gate
        │
        ├─ incomplete → return to the missing conversation step
        └─ complete   → render BRAINSTORM_TEMPLATE.md
        │
        ▼
.claude/sdd/features/BRAINSTORM_{FEATURE}.md
Status: Ready for Define
        │
        ▼
/define .claude/sdd/features/BRAINSTORM_{FEATURE}.md
```

## Component Responsibilities

| Layer | Source file | Responsibility |
|-------|-------------|----------------|
| Command | `.claude/commands/workflow/brainstorm.md` | User entrypoint, accepted input, output location, and handoff |
| Agent | `.claude/agents/workflow/brainstorm-agent.md` | Executor identity, model, tools, stop conditions, and escalation |
| Skill | `.claude/skills/sdd-brainstorm/SKILL.md` | Discovery process, question style, approach comparison, YAGNI, validation, and quality gate |
| Contract | `.claude/sdd/architecture/WORKFLOW_CONTRACTS.yaml` | Authoritative phase mapping, input and output contract, status values, and gate thresholds |
| Template | `.claude/sdd/templates/BRAINSTORM_TEMPLATE.md` | Required structure of the generated artifact |
| Knowledge Base | `.claude/kb/_index.yaml` and selected domains | Evidence for recommendations and confidence assignment |
| Artifact | `.claude/sdd/features/BRAINSTORM_{FEATURE}.md` | Durable record consumed by `/define` |

This follows the component model: commands are entrypoints, agents execute within declared boundaries, skills own methodology, and KBs own reusable technical knowledge.

## Runtime Sequence

### 1. Initialize the Workspace

The plugin's `SessionStart` hook runs `scripts/init-workspace.sh`. For a recognized project, it creates:

```text
.claude/sdd/features/
.claude/sdd/reports/
.claude/sdd/archive/
```

It can also write `.claude/sdd/.detected-stack.md` with detected technologies and recommended agents, KB domains, and commands. This prepares the workspace; it does not start Brainstorm itself.

### 2. Load the Command

Claude Code discovers the Markdown command from the installed plugin. The command accepts either:

- A raw idea or problem statement.
- A feature request.
- A comparison request.
- A path to rough notes.

The command directs the active Claude context to load the `sdd-brainstorm` skill, produce a `BRAINSTORM_{FEATURE}.md` artifact, and suggest `/define` when complete.

### 3. Establish the Execution Context

The workflow contract maps `/brainstorm` to `brainstorm-agent` and `sdd-brainstorm`. The agent declares a Sonnet T2 executor with read, write, search, shell, task-tracking, and user-question tools. Its stop conditions require:

- A user-confirmed approach.
- At least three answered discovery questions.
- Draft requirements ready for Define.

The skill owns how those conditions are reached.

#### Current wiring note

The command currently instructs the active context to load the skill directly; it does not contain an explicit subagent invocation. The contract and agent files describe `brainstorm-agent` as the executor, and the host may select it, but the command itself does not force that delegation. Therefore, the explicit repository path today is:

```text
/brainstorm → sdd-brainstorm skill
```

The declared architectural path is:

```text
/brainstorm → brainstorm-agent → sdd-brainstorm skill
```

This distinction matters when diagnosing runtime behavior or changing agent-specific model and tool settings.

### 4. Gather Evidence

Before recommending an approach, the skill gathers context from:

1. `CLAUDE.md` for project-specific instructions and architecture.
2. `.claude/kb/_index.yaml` to identify relevant knowledge domains.
3. The project structure and existing implementation patterns.
4. Recent commits for current development context.
5. Relevant KB domain files for technical evidence.
6. `BRAINSTORM_TEMPLATE.md` for the expected artifact shape.

Recommendations receive an evidence-based confidence level. A KB pattern that also matches the codebase is stronger than an approach with no local precedent.

### 5. Conduct the Conversation

The skill runs seven ordered steps:

1. Gather project and KB context.
2. Ask at least three discovery questions, one per message.
3. Ask for sample inputs, outputs, ground truth, or related code.
4. Present two or three approaches with trade-offs and a recommended option.
5. Apply YAGNI and record removed or deferred features.
6. Present the emerging proposal in sections and complete at least two user validation checkpoints.
7. Check the gate and generate the artifact.

The user chooses the approach. A recommendation does not count as confirmation.

### 6. Apply the Quality Gate

Before writing the artifact, Phase 0 requires:

- At least three discovery questions answered.
- An explicit sample-data question.
- At least two approaches with trade-offs.
- Explicit user confirmation of the selected approach.
- YAGNI applied and removals recorded.
- At least two incremental validations.
- Relevant KB domains identified.
- Draft requirements ready for `/define`.

The canonical checklist lives in `sdd-brainstorm/SKILL.md`; the numeric obligations also live in `WORKFLOW_CONTRACTS.yaml`.

The gate is currently instruction-enforced by the skill. The Brainstorm binding to the deterministic spec-linter is declared as a target, not wired as a blocking runtime check.

### 7. Generate the Artifact

After the gate passes, the skill renders the template into:

```text
.claude/sdd/features/BRAINSTORM_{FEATURE}.md
```

`{FEATURE}` uses `SCREAMING_SNAKE_CASE`, for example:

```text
.claude/sdd/features/BRAINSTORM_ORDERS_PIPELINE.md
```

The artifact records the original idea, technical context, discovery answers, sample inventory, compared approaches, selected approach, decisions, YAGNI removals, validation feedback, and draft requirements.

Its status moves through:

```text
Exploring → Approaches Identified → Ready for Define
```

### 8. Hand Off to Define

Brainstorm finishes by recommending:

```text
/define .claude/sdd/features/BRAINSTORM_ORDERS_PIPELINE.md
```

Define consumes the brainstorm artifact, creates `DEFINE_ORDERS_PIPELINE.md`, and changes the brainstorm status to `✅ Complete (Defined)`. Brainstorm selects and records an approach; Define turns that record into validated requirements.

## Source Tree and Installed Plugin

`.claude/` is the development source of truth. `build-plugin.sh` copies it into the distributable `plugin/` tree and rewrites internal references:

| Development source | Installed plugin |
|--------------------|------------------|
| `.claude/commands/workflow/brainstorm.md` | `${CLAUDE_PLUGIN_ROOT}/commands/workflow/brainstorm.md` |
| `.claude/agents/workflow/brainstorm-agent.md` | `${CLAUDE_PLUGIN_ROOT}/agents/workflow/brainstorm-agent.md` |
| `.claude/skills/sdd-brainstorm/SKILL.md` | `${CLAUDE_PLUGIN_ROOT}/skills/sdd-brainstorm/SKILL.md` |
| `.claude/sdd/templates/BRAINSTORM_TEMPLATE.md` | `${CLAUDE_PLUGIN_ROOT}/sdd/templates/BRAINSTORM_TEMPLATE.md` |
| `.claude/sdd/architecture/WORKFLOW_CONTRACTS.yaml` | `${CLAUDE_PLUGIN_ROOT}/sdd/architecture/WORKFLOW_CONTRACTS.yaml` |

Workspace output paths are deliberately preserved. An installed plugin still writes the artifact to the user's project at `.claude/sdd/features/`, not inside `${CLAUDE_PLUGIN_ROOT}`.

## Change Map

Use this map when changing Brainstorm behavior:

| Desired change | Edit |
|----------------|------|
| Invocation syntax or handoff | `.claude/commands/workflow/brainstorm.md` |
| Model, tools, stop conditions, or escalation | `.claude/agents/workflow/brainstorm-agent.md` |
| Questions, process, gate, YAGNI, or validation behavior | `.claude/skills/sdd-brainstorm/SKILL.md` |
| Artifact sections | `.claude/sdd/templates/BRAINSTORM_TEMPLATE.md` |
| Phase input, output, status, or gate contract | `.claude/sdd/architecture/WORKFLOW_CONTRACTS.yaml` |
| Technical recommendation content | Relevant `.claude/kb/<domain>/` files |

After changing anything under `.claude/`, run `make build` and inspect the generated `plugin/` diff.

## Canonical References

- [Brainstorm command](../../.claude/commands/workflow/brainstorm.md)
- [Brainstorm agent](../../.claude/agents/workflow/brainstorm-agent.md)
- [Brainstorm skill](../../.claude/skills/sdd-brainstorm/SKILL.md)
- [Brainstorm template](../../.claude/sdd/templates/BRAINSTORM_TEMPLATE.md)
- [Workflow contracts](../../.claude/sdd/architecture/WORKFLOW_CONTRACTS.yaml)
- [SDD architecture](../../.claude/sdd/architecture/ARCHITECTURE.md)

