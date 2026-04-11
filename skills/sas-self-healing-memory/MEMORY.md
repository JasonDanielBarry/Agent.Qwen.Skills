# Memory Index

> Managed by the `sas-self-healing-memory` skill.
> Each entry is ~150 characters max. Tags enable efficient search.
> For full conventions, see SKILL.md.

## Active Topics

<!-- Add topic pointers below. Format: - **topic-name** [tag] — Brief summary. Last updated: YYYY-MM-DD. -->

- **self-healing-memory** [patterns] — Core architecture, write discipline, verification rules for this skill. Last updated: 2026-04-10.

<!-- Example:
- **project-structure** [structure] — Core directory layout and key files. Last updated: 2026-04-10.
- **coding-patterns** [patterns] — Project-specific conventions and patterns. Last updated: 2026-04-10.
- **decisions** [decisions] — Architectural decisions with rationale. Last updated: 2026-04-10.
-->

## Key Facts

<!-- Add factual entries with citations. Format: - [tag] Brief fact → `file:line`. Verified: YYYY-MM-DD. -->

- [patterns] Index entries capped at ~150 chars → `SKILL.md:31`. Verified: 2026-04-10.
- [patterns] Topic files trigger consolidation at ~100 lines → `SKILL.md:107`. Verified: 2026-04-10.
- [decisions] Memory is hint, not truth — verify against code before use → `SKILL.md:33-40`. Verified: 2026-04-10.

<!-- Example:
- [project-structure] Auth module uses middleware pattern → `src/auth.ts`. Verified: 2026-04-10.
- [coding-patterns] All API errors use AppError class → `src/errors/AppError.ts`. Verified: 2026-04-10.
-->

---

## Tag Conventions

| Tag | Use For |
|---|---|
| `[structure]` | Directory layout, file organization, module boundaries |
| `[patterns]` | Coding conventions, recurring patterns, anti-patterns |
| `[decisions]` | Architectural decisions with rationale |
| `[config]` | Build, tooling, environment configuration |
| `[api]` | API contracts, endpoints, data formats |
| `[testing]` | Test strategy, fixtures, known test quirks |
| `[deploy]` | Deployment process, infrastructure, environments |
| `[security]` | Auth, permissions, secrets, vulnerabilities |
