---
name: data-engineering-guide
description: |
  Data engineering expertise for pipelines, schemas, data quality, SQL, lakehouse, and streaming.
  Use PROACTIVELY when the user discusses data pipelines, ETL/ELT, schema design, dimensional modeling,
  data quality checks, SQL optimization, dbt models, Spark jobs, Airflow DAGs, streaming pipelines,
  lakehouse architecture, or data contracts.
---

# Data Engineering Guide

You have access to 23 specialized knowledge base domains and 15+ data engineering agents. Route the user to the right tool based on their task.

## Quick Routing

| User Task | Command | Agent |
|-----------|---------|-------|
| Design a data pipeline / DAG | `/chongtech-agent-data-pipeline:pipeline` | pipeline-architect |
| Design a schema / star schema / data model | `/chongtech-agent-data-pipeline:schema` | schema-designer |
| Add data quality checks | `/chongtech-agent-data-pipeline:data-quality` | data-quality-analyst |
| Review SQL performance | `/chongtech-agent-data-pipeline:sql-review` | sql-optimizer |
| Choose table format (Iceberg/Delta) | `/chongtech-agent-data-pipeline:lakehouse` | lakehouse-architect |
| Build RAG / embedding pipeline | `/chongtech-agent-data-pipeline:ai-pipeline` | ai-data-engineer |
| Create a data contract | `/chongtech-agent-data-pipeline:data-contract` | data-contracts-engineer |
| Migrate legacy ETL | `/chongtech-agent-data-pipeline:migrate` | dbt-specialist + spark-engineer |

## Knowledge Domains Available

| Category | Domains |
|----------|---------|
| Core DE | dbt, spark, airflow, streaming, sql-patterns |
| Data Design | data-modeling, data-quality, medallion |
| Infrastructure | lakehouse, cloud-platforms, aws, gcp, microsoft-fabric, lakeflow, terraform |
| AI & Modern | ai-data-engineering, genai, prompt-engineering, modern-stack |
| Foundations | pydantic, python, testing |

## How Agents Use Knowledge

1. Agent reads KB index at `${CLAUDE_PLUGIN_ROOT}/kb/{domain}/index.md`
2. Loads specific pattern/concept file matching the task
3. Falls back to MCP if KB insufficient (max 3 MCP calls)
4. Calculates confidence from evidence matrix

## When to Suggest Commands

- User mentions "dbt model" or "staging model" → `/chongtech-agent-data-pipeline:schema` or delegate to dbt-specialist
- User mentions "pipeline" or "DAG" or "orchestration" → `/chongtech-agent-data-pipeline:pipeline`
- User mentions "data quality" or "expectations" or "tests" → `/chongtech-agent-data-pipeline:data-quality`
- User mentions "slow query" or "optimize SQL" → `/chongtech-agent-data-pipeline:sql-review`
- User mentions "Iceberg" or "Delta Lake" or "table format" → `/chongtech-agent-data-pipeline:lakehouse`
- User mentions "RAG" or "embeddings" or "vector" → `/chongtech-agent-data-pipeline:ai-pipeline`
- User mentions "contract" or "SLA" or "schema governance" → `/chongtech-agent-data-pipeline:data-contract`
- User mentions "migrate" or "legacy" or "SSIS" or "Informatica" → `/chongtech-agent-data-pipeline:migrate`
