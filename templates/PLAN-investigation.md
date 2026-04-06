---
project: {{ Project Name }}
type: plan
tags:
  - project/{{ slug }}
  - type/plan
  - stage/plan
aliases:
  - {{ Project Name }} Plan
created: {{ YYYY-MM-DD }}
updated: {{ YYYY-MM-DD }}
---

# Plan: {{ Project Name }}

> **Hub:** [[{{ slug }}/{{ slug }}-index|{{ Project Name }}]]

## Goal

<!-- What this investigation aims to determine or diagnose in 2-3 sentences. -->

## Scope

<!-- What is in scope -->
-

<!-- What is NOT in scope -->
-

## Hypothesis

<!-- The working hypothesis to prove or disprove. State it clearly and make it falsifiable. -->
> <!-- e.g., "The latency spike is caused by N+1 queries in the user service." -->

## Data Sources

<!-- Where evidence will be gathered from. Include access details or links. -->
- <!-- e.g., Application logs -->
- <!-- e.g., Database slow query log -->
- <!-- e.g., Git blame / commit history -->
- <!-- e.g., Observability platform traces and spans -->

## Investigation Steps

<!-- Ordered steps for the investigation. Each step should gather specific evidence. -->
1. <!-- e.g., Pull latency percentiles for the past 7 days -->
2. <!-- e.g., Identify top-5 slowest endpoints -->
3. <!-- e.g., Trace a sample slow request end-to-end -->

## Metrics / Queries

<!-- Specific metrics to check or queries to run. Include the tool and query text. -->
| Tool | Metric / Query | Purpose |
|------|---------------|---------|
| <!-- tool --> | <!-- query --> | <!-- purpose --> |

## Steps

<!-- High-level project steps (may overlap with Investigation Steps above). -->
1.
2.
3.

## Open Questions

<!-- Unresolved questions that may affect the plan. Check them off as they are answered. -->
- [ ]
