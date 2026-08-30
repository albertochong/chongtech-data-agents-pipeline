<div align="center">

<picture>
  <source media="(prefers-color-scheme: dark)" srcset="assets/banner.svg">
  <source media="(prefers-color-scheme: light)" srcset="assets/banner.svg">
  <img alt="ChongTech Agent Data Pipeline — Spec-Driven Data Engineering" src="assets/banner.svg" width="100%">
</picture>

<br/><br/>

[![Claude Code Plugin](https://img.shields.io/badge/Claude%20Code-Plugin-blueviolet?style=flat-square)](plugin/)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue?style=flat-square)](LICENSE)
[![Version](https://img.shields.io/badge/v3.5.0-green?style=flat-square)](CHANGELOG.md)

**A single AI agent reviewing your data pipeline will miss things.**<br/>
**58 specialized agents with 24 knowledge domains will not.**

<br/>

[Install](#install) · [Quick Start](#quick-start) · [Commands](#which-command-do-i-need) · [Agents](#58-agents-across-8-categories) · [Docs](docs/)

</div>

<br/>

## Why ChongTech Agent Data Pipeline?

Every time you ask an AI to build a data pipeline, it starts from scratch — no memory of partition strategies, no awareness of SCD patterns, no understanding of your data contracts. You get hallucinated SQL, wrong incremental strategies, and pipelines that pass in dev but break in production.

ChongTech Agent Data Pipeline solves this with **Spec-Driven Data Engineering**: a 5-phase workflow where every phase has access to 24 knowledge base domains, every agent knows its boundaries, and every decision is confidence-scored against real documentation — not guessed.

<br/>

## Install

```bash
# Install the plugin (one-time)
claude plugin marketplace add albertochong/chongtech-data-agents-pipeline
claude plugin install chongtech-agent-data-pipeline
```

Done. Every Claude Code session now has 58 agents, 31 commands, and 24 KB domains. Updates are one command:

```bash
claude plugin update chongtech-agent-data-pipeline
```

> **Override any agent locally** — drop a file in `.claude/agents/<category>/<agent-name>.md` and it takes precedence over the plugin version. See [Agent Overrides](docs/concepts/agent-overrides.md).

<details>
<summary><b>Alternative install methods</b></summary>

```bash
# Local testing (no install needed)
git clone https://github.com/albertochong/chongtech-data-agents-pipeline.git
claude --plugin-dir ./chongtech-data-agents-pipeline/plugin

# Legacy copy (pre-plugin, still works)
git clone https://github.com/albertochong/chongtech-data-agents-pipeline.git
cp -r chongtech-data-agents-pipeline/.claude your-project/.claude
```

</details>

<br/>

## Quick Start

### Build a data pipeline in 5 phases

```bash
/chongtech-agent-data-pipeline:brainstorm "Daily orders pipeline from Postgres to Snowflake star schema"
/chongtech-agent-data-pipeline:define ORDERS_PIPELINE
/chongtech-agent-data-pipeline:design ORDERS_PIPELINE
/chongtech-agent-data-pipeline:build ORDERS_PIPELINE
/chongtech-agent-data-pipeline:ship ORDERS_PIPELINE
```

### Or jump straight to what you need

```bash
/chongtech-agent-data-pipeline:schema "Star schema for e-commerce analytics"
/chongtech-agent-data-pipeline:pipeline "Daily orders ETL with Airflow"
/chongtech-agent-data-pipeline:data-quality models/staging/stg_orders.sql
/chongtech-agent-data-pipeline:sql-review models/marts/
/chongtech-agent-data-pipeline:data-contract "Contract between orders team and analytics"
```

<br/>

## Which Command Do I Need?

### Data Engineering

| I want to... | Command | Agent |
|:--|:--|:--|
| Design a data pipeline / DAG | `/chongtech-agent-data-pipeline:pipeline` | `pipeline-architect` |
| Design a star schema / data model | `/chongtech-agent-data-pipeline:schema` | `schema-designer` |
| Add data quality checks | `/chongtech-agent-data-pipeline:data-quality` | `data-quality-analyst` |
| Optimize slow SQL | `/chongtech-agent-data-pipeline:sql-review` | `sql-optimizer` |
| Choose Iceberg vs Delta Lake | `/chongtech-agent-data-pipeline:lakehouse` | `lakehouse-architect` |
| Build a RAG / embedding pipeline | `/chongtech-agent-data-pipeline:ai-pipeline` | `ai-data-engineer` |
| Create a data contract | `/chongtech-agent-data-pipeline:data-contract` | `data-contracts-engineer` |
| Migrate legacy SSIS / Informatica | `/chongtech-agent-data-pipeline:migrate` | `dbt-specialist` + `spark-engineer` |

### SDD Workflow

| I want to... | Command | What Happens |
|:--|:--|:--|
| Explore an idea | `/chongtech-agent-data-pipeline:brainstorm` | Compare approaches, discovery questions, YAGNI filter |
| Capture requirements | `/chongtech-agent-data-pipeline:define` | Structured requirements with clarity score (min 12/15) |
| Design architecture | `/chongtech-agent-data-pipeline:design` | File manifest + pipeline architecture + ADRs |
| Implement the feature | `/chongtech-agent-data-pipeline:build` | Auto-delegates to specialist agents per file type |
| Archive completed work | `/chongtech-agent-data-pipeline:ship` | Lessons learned + KB updates |
| Update after changes | `/chongtech-agent-data-pipeline:iterate` | Cascade-aware updates across all phase documents |

### Visual & Utilities

| I want to... | Command |
|:--|:--|
| Generate architecture diagrams | `/chongtech-agent-data-pipeline:generate-web-diagram` |
| Create presentation slides | `/chongtech-agent-data-pipeline:generate-slides` |
| Visual implementation plan | `/chongtech-agent-data-pipeline:generate-visual-plan` |
| Review code changes visually | `/chongtech-agent-data-pipeline:diff-review` |
| Review code | `/chongtech-agent-data-pipeline:review` |
| Analyze meeting transcripts | `/chongtech-agent-data-pipeline:meeting` |
| Create a new KB domain | `/chongtech-agent-data-pipeline:create-kb` |
| Share HTML page via Vercel | `/chongtech-agent-data-pipeline:share` |

<br/>

## How It Works

```
  BRAINSTORM ──► DEFINE ──► DESIGN ──► BUILD ──► SHIP
  Explore ideas   Scope &    File       Agent      Archive &
  & approaches    contracts  manifest   delegation lessons

                                │
          ┌─────────────────────┼──────────────────────┐
          ▼                     ▼                      ▼
    ┌───────────┐        ┌───────────┐          ┌───────────┐
    │ dbt-spec  │        │ spark-eng │          │ pipeline  │
    │ Models    │        │ Jobs      │          │ DAGs      │
    └─────┬─────┘        └─────┬─────┘          └─────┬─────┘
          └────────────────────┼──────────────────────┘
                               ▼
                         BUILD REPORT
                         Tests + Quality Gates

                          ↻ /iterate
                    Cascade-aware updates
```

**Agent matching:** Your DESIGN doc specifies dbt staging models, a PySpark job, and an Airflow DAG — ChongTech Agent Data Pipeline automatically delegates to `dbt-specialist`, `spark-engineer`, and `pipeline-architect`.

**Requirements changed?** `/chongtech-agent-data-pipeline:iterate` updates any phase document with automatic cascade detection across all downstream docs.

<br/>

## 58 Agents Across 8 Categories

| Category | Count | Focus |
|:--|:--|:--|
| **Architect** | 8 | Schema design, pipeline architecture, medallion layers, GenAI systems |
| **Cloud** | 10 | AWS Lambda, GCP Cloud Run, Supabase, CI/CD, Terraform |
| **Data Engineering** | 15 | dbt, Spark, Airflow, streaming, Lakeflow, SQL optimization |
| **Platform** | 6 | Microsoft Fabric end-to-end (architecture, pipelines, security, AI, logging, CI/CD) |
| **Python** | 6 | Code review, documentation, cleaning, prompt engineering |
| **Workflow** | 6 | Brainstorm, define, design, build, ship, iterate |
| **Dev** | 4 | Codebase exploration, shell scripting, meeting analysis, prompt crafting |
| **Test** | 3 | Test generation, data quality analysis, data contract authoring |

Every agent follows the same cognitive framework:

1. **KB-first** — check local knowledge base before external sources
2. **Confidence-scored** — calculate confidence from evidence, never self-assess
3. **Escalation-aware** — transfer to the right specialist when out of domain
4. **Quality-gated** — pre-flight checklist before every substantive response

<br/>

## 24 Knowledge Base Domains

| Category | Domains |
|:--|:--|
| **Core DE** | `dbt` · `spark` · `sql-patterns` · `airflow` · `streaming` |
| **Data Design** | `data-modeling` · `data-quality` · `medallion` |
| **Infrastructure** | `lakehouse` · `lakeflow` · `cloud-platforms` · `terraform` |
| **Cloud** | `aws` · `gcp` · `microsoft-fabric` · `supabase` |
| **AI & Modern** | `ai-data-engineering` · `modern-stack` · `genai` · `prompt-engineering` |
| **Foundations** | `pydantic` · `python` · `testing` · `shared` |

Each domain contains an `index.md`, `quick-reference.md`, `concepts/` (3-6 files), and `patterns/` (3-6 files with production code). Agents load domains on-demand, not upfront.

<br/>

## 5-Phase Workflow with Quality Gates

| Phase | Command | Output | Gate |
|:--|:--|:--|:--|
| **0. Brainstorm** | `/chongtech-agent-data-pipeline:brainstorm` | `BRAINSTORM_{FEATURE}.md` | 3+ questions, 2+ approaches |
| **1. Define** | `/chongtech-agent-data-pipeline:define` | `DEFINE_{FEATURE}.md` | Clarity Score >= 12/15 |
| **2. Design** | `/chongtech-agent-data-pipeline:design` | `DESIGN_{FEATURE}.md` | Complete manifest + schema plan |
| **3. Build** | `/chongtech-agent-data-pipeline:build` | Code + `BUILD_REPORT.md` | All tests pass |
| **4. Ship** | `/chongtech-agent-data-pipeline:ship` | `SHIPPED_{DATE}.md` | Acceptance verified |

<br/>

## Project Structure

```
chongtech-data-agents-pipeline/
├── .claude/                 # Source of truth (development)
│   ├── agents/              # 58 agents across 8 categories
│   ├── commands/            # 31 slash commands
│   ├── skills/              # 19 source skills (SDD phases, GitHub workflow, authoring, KB, visuals…)
│   ├── kb/                  # 24 knowledge base domains
│   └── sdd/                 # Templates, contracts, features, archive
│
├── plugin/                  # Distributable Claude Code plugin
│   ├── .claude-plugin/      # Manifest + marketplace config
│   ├── agents/              # Path-rewritten agents
│   ├── skills/              # 16 skills (15 from .claude/ + 1 plugin-only)
│   ├── hooks/               # SessionStart workspace init
│   └── ...                  # commands, kb, sdd, scripts
│
├── plugin-extras/           # Plugin-only content (merged by build)
├── build-plugin.sh          # Packages .claude/ → plugin/
└── docs/                    # Getting started, concepts, tutorials, reference
```

<br/>

## Documentation

| Guide | What You'll Learn |
|:--|:--|
| [Getting Started](docs/getting-started/) | Install and build your first data pipeline |
| [Core Concepts](docs/concepts/) | SDD pillars through a data engineering lens |
| [Tutorials](docs/tutorials/) | dbt, star schema, data quality, Spark, streaming, RAG |
| [Reference](docs/reference/) | Full catalog: 58 agents, 31 commands, 24 KB domains |

<br/>

## Contributing

We welcome contributions. See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

**Agents** · **KB Domains** · **Commands** · **Plugin Development** · **Documentation**

<br/>

## License

MIT — see [LICENSE](LICENSE).

---

<div align="center">

[Documentation](docs/) · [Contributing](CONTRIBUTING.md) · [Changelog](CHANGELOG.md)

Built with [Claude Code](https://docs.anthropic.com/en/docs/claude-code)

</div>
