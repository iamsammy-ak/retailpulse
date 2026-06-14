# RetailPulse BI - Agile Delivery Plan

Lightweight Scrum-style breakdown for a one-week solo portfolio build (or a 2-sprint team plan).

## Product backlog (priority ordered)
| # | Item | Type | Story points |
|---|------|------|--------------|
| 1 | Define business questions and KPIs | Discovery | 2 |
| 2 | Design star schema (Fact + 4 dims) | Modelling | 3 |
| 3 | Generate sample dataset and load to SQL Server | Data | 3 |
| 4 | Write DDL with PK / FK / indexes | Data | 2 |
| 5 | Write 5+ analytical SQL queries | Analysis | 3 |
| 6 | Build Power BI data model (relationships, date table) | Modelling | 3 |
| 7 | Author DAX measures (KPIs, YTD, YoY, ranking) | DAX | 3 |
| 8 | Design executive dashboard layout | UX | 3 |
| 9 | Implement dashboard visuals and slicers | Build | 5 |
| 10 | Drill-through / tooltip page | Build | 2 |
| 11 | Testing checklist and UAT log | QA | 3 |
| 12 | Documentation (README, technical, business) | Docs | 3 |
| 13 | CV bullets, LinkedIn post, interview prep | Portfolio | 2 |

## Sprint plan (2 sprints of 1 week)

### Sprint 1 - Foundations
- Items 1-7 (modelling, data, SQL, DAX).
- Demo: SQL queries return expected results; Power BI model has relationships and all measures compile.

### Sprint 2 - Delivery
- Items 8-13 (dashboard, testing, docs, portfolio).
- Demo: End-to-end dashboard with UAT sign-off and documentation published.

## Kanban board (suggested columns)
| Backlog | Ready | In Progress | In Review | Done |
|---------|-------|-------------|-----------|------|

Move items left to right as they progress. WIP limit = 2.

## Definition of Done (DoD)
An item is Done when:
1. Code/SQL/DAX runs without errors.
2. Tests in `docs/testing_plan.md` are executed and pass.
3. Documentation is updated (README or relevant .md).
4. A peer (or self-review checklist) has signed off.
5. The change is committed with a clear message.

## Daily standup format (adapted for solo)
- Yesterday: what I completed.
- Today: what I will work on.
- Blockers: anything stopping me.
- Risk: anything that could derail the sprint.

## Risks and mitigations
| Risk | Mitigation |
|------|------------|
| Data inconsistencies | Run data-quality checks before building visuals. |
| DAX time intelligence errors | Ensure the `Date` table is marked as a date table. |
| Dashboard clutter | Stick to the layout spec; less is more. |
| Performance on small dataset | Not an issue at this size; note incremental refresh for scale. |
