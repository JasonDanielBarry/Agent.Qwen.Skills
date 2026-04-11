# Topic Files

This directory contains detailed knowledge organized by topic. Each file covers one domain or area of the project.

## Naming Conventions

- Use **kebab-case** filenames (e.g., `project-structure.md`, `coding-patterns.md`)
- Names should be descriptive and match the tag used in MEMORY.md
- One topic per file — don't mix unrelated knowledge areas

## Topic File Structure

```markdown
# Topic: [name]

## Facts
- **[Short label]** [Content with `file:line` citation to the codebase]
  - Created: YYYY-MM-DD | Source: session/[session-name]
  - Last Verified: YYYY-MM-DD | Status: active

## Decisions
- **[Decision label]** [Rationale for the decision]
  - Date: YYYY-MM-DD | Source: session/[session-name]
  - Last Verified: YYYY-MM-DD | Status: active

## Patterns
- **[Pattern label]** [Description with example code location]
  - Observed: YYYY-MM-DD | Status: active

## Superseded
- ~~[Old entry text]~~ — Superseded: YYYY-MM-DD. Reason: [why it was replaced]. See: [replacement entry label].
```

## Sections

### Facts

Verifiable facts about the codebase that are expensive to re-derive. Each must cite a specific code location.

**Good example:**
```markdown
- **[Auth middleware]** Request validation happens before route handlers → `src/auth/middleware.ts:18`
  - Created: 2026-04-10 | Source: session/feature-auth
  - Last Verified: 2026-04-10 | Status: active
```

**Bad example (derivable — don't store):**
```markdown
- Auth module has a middleware file (can be seen by listing the directory)
```

### Decisions

Architectural or design decisions with rationale. These persist longer than facts because the reasoning is often not recoverable from the code.

**Good example:**
```markdown
- **[Use AppError class]** All API errors use a custom AppError class for consistent error responses → discussed in PR #42
  - Date: 2026-04-10 | Source: session/feature-auth
  - Last Verified: 2026-04-10 | Status: active
```

### Patterns

Observed conventions, recurring solutions, or anti-patterns to avoid.

**Good example:**
```markdown
- **[Error response format]** All error responses return `{ error: { code, message, details } }` → see `src/errors/AppError.ts:8`
  - Observed: 2026-04-10 | Status: active
```

### Superseded

Old entries that have been replaced. Use `~~strikethrough~~` and include the reason and date. This section enables rollback if a correction turns out to be wrong.

**Example:**
```markdown
- ~~[Auth uses JWT only]~~ — Superseded: 2026-04-10. Reason: code also supports OAuth2 at `src/auth/providers.ts:5`. See: [Auth providers].
```

## Status Lifecycle

| Status | Meaning | Action |
|---|---|---|
| `active` | Current, verified, in use | — |
| `deprecated` | No longer relevant but may be useful reference | Soft delete — still visible, not used for decisions |
| `superseded` | Replaced by newer entry | Moved to Superseded section with strikethrough |

## When to Create a New Topic File

Create a new topic file when:
- MEMORY.md Index references a topic that doesn't exist yet
- Knowledge doesn't fit any existing topic
- A domain area has grown large enough to warrant its own file

Merge topic files when:
- Two topics cover the same domain
- A topic has very few entries and could be absorbed into another

## Provenance Fields (Required)

Every entry MUST include:
- **Created** or **Date** or **Observed** — when the entry was first recorded
- **Source** — session name, conflict resolution, consolidation, etc.
- **Last Verified** — when the entry was last checked against live code
- **Status** — active, deprecated, or superseded

## Citation Format

Citations reference specific locations in the codebase:

```
`path/to/file.ext:line`
```

Examples:
- `` `src/auth/middleware.ts:18` ``
- `` `src/errors/AppError.ts:8-15` `` (line range)
- `` `tests/auth.test.ts:42` ``
