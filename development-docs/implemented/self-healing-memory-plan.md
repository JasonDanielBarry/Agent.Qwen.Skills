# Plan: AQS Self-Healing Memory Skill

> **Branch:** `feature/skill-self-healing-memory`
> **Based on research:** `development-docs/proposed/self-healing-memory.md`
> **Date:** 10 April 2026
> **Skill name:** `sas-self-healing-memory` (follows `sas-` prefix convention)

---

## Objective

Create a Qwen Code skill (`sas-self-healing-memory`) that enables AI agents to maintain a structured, self-correcting memory system using file-based storage. The skill encodes write discipline, verification-first retrieval, and conflict resolution patterns into agent instructions.

---

## Design Decisions

### Architecture: Index + Topic Files + Transcripts

Adapted from Claude Code's 3-layer system, simplified for file-based Qwen Code skills:

| Layer | File | Behavior |
|---|---|---|
| **Index** | `MEMORY.md` | Always loaded; lightweight pointers (~150 chars per entry) |
| **Topic Files** | `topics/*.md` | Loaded on-demand; full knowledge content per domain |
| **Transcripts** | `transcripts/*.md` | Append-only session logs; never loaded into context, grep only |

### Why Not Vector Stores / Knowledge Graphs

Out of scope for a file-based skill. The skill relies on simple markdown files that any Qwen Code agent can read/write without external infrastructure.

### Self-Healing Mechanism: Verification-First + Conflict Resolution

Since Qwen Code doesn't support background agents (no `autoDream` equivalent), self-healing happens **during agent execution**:

1. When agent retrieves memory, it verifies against live codebase
2. If conflict detected, agent updates memory immediately
3. Consolidation triggered manually or via `/loop` skill

---

## Deliverables

```
skills/self-healing-memory/
├── SKILL.md                      # Skill definition + agent instructions
├── MEMORY.md                     # Index file (starter template)
├── topics/
│   └── _README.md                # Topic file conventions + example
└── transcripts/
    └── .gitkeep                  # Preserve directory structure
```

---

## Implementation Tasks

### 1. Create SKILL.md

**Frontmatter:**
```yaml
---
name: sas-self-healing-memory
description: Maintain a structured, self-correcting memory system for AI agents.
  Use when the user wants persistent memory across sessions, memory consolidation,
  conflict resolution, or knowledge management for long-running projects.
---
```

**Core instructions to encode:**

#### a. Write Discipline

1. Always write to topic file **first**, then update Index in `MEMORY.md`
2. Never dump raw content into Index — keep entries to ~150 characters
3. Omit derivable facts — if it can be re-derived from the codebase, don't store it
4. Use kebab-case for topic filenames

#### b. Verification Rule (Self-Healing)

1. Before using any memory entry, verify against live codebase
2. Read the cited file/location and compare to stored memory
3. If match → proceed with confidence
4. If conflict → update memory entry immediately, then proceed

#### c. Conflict Resolution Pattern

```
Retrieve memory → Check live source → 
  If conflict: edit topic file to correct → Update Index entry → Proceed
```

#### d. Consolidation Session

Since no background agent, consolidation is a manual session where the agent:

1. Reviews all topic files for outdated entries
2. Deduplicates overlapping entries
3. Resolves contradictions
4. Removes low-utility memories (usage-based eviction)
5. Updates Index to reflect current state

Can be triggered manually or scheduled via `/loop` skill.

#### e. Memory Structure

**MEMORY.md (Index):**

Uses a simple list format (not tables) with tags for efficient agent parsing. Each entry is ~150 characters max.

```markdown
# Memory Index

## Active Topics
- **project-structure** [structure] — Core directory layout and key files. Last updated: 2026-04-10.
- **coding-patterns** [patterns] — Project-specific conventions and patterns. Last updated: 2026-04-10.
- **decisions** [decisions] — Architectural decisions with rationale. Last updated: 2026-04-10.

## Key Facts
- [project-structure] Auth module uses middleware pattern → `src/auth.ts`. Verified: 2026-04-10.
- [coding-patterns] All API errors use AppError class → `src/errors/AppError.ts`. Verified: 2026-04-10.
```

**Tag conventions:** `[structure]` `[patterns]` `[decisions]` `[config]` `[api]` `[testing]` `[deploy]` `[security]`

**Topic Files:**

Each entry includes provenance tracking for lifecycle management.

```markdown
# Topic: [name]

## Facts
- **[Short label]** [Citation to code location, e.g., `src/auth.ts:42`]
  - Created: 2026-04-10 | Source: session/feature-auth
  - Last Verified: 2026-04-10 | Status: active

## Decisions
- **[Decision label]** [Rationale]
  - Date: 2026-04-10 | Source: session/feature-auth
  - Last Verified: 2026-04-10 | Status: active

## Patterns
- **[Pattern label]** [Description with example location]
  - Observed: 2026-04-10 | Status: active

## Superseded
- ~~[Entry text]~~ — Superseded: 2026-04-10. Reason: [why]. See: [replacement entry].
```

**Status lifecycle:** `active` → `deprecated` (soft delete, still visible) → `superseded` (replaced, archived in section)

---

### 2. Create MEMORY.md (Starter Template)

Pre-populated with the Index structure above and brief usage notes.

---

### 3. Create topics/_README.md

Explains:
- Topic file naming conventions (kebab-case)
- How to structure content (Facts/Decisions/Patterns/Superseded sections)
- Citation format (`file:line` references to codebase)
- Provenance fields (Created, Source, Last Verified, Status)
- When to create new topic files vs. update existing ones
- Status lifecycle and how to supersede entries

---

### 4. Define Transcript Structure

Each session appends to `transcripts/YYYY-MM-DD.md` with structured, timestamped entries for effective grep-based retrieval:

```markdown
# Session Transcript: 2026-04-10

## Session: feature-auth
**Start:** 14:30 UTC | **End:** 15:45 UTC

### [14:32] INSIGHT
Discovered: Auth middleware uses dependency injection pattern.
Location: src/auth/middleware.ts:18
Memory updated: topics/decisions.md (added entry)

### [14:45] ACTION
Refactored error handler to use AppError class.
Files changed: src/errors/handler.ts
Memory updated: topics/coding-patterns.md (updated entry)

### [15:10] CONFLICT_RESOLVED
Memory said: Auth uses JWT tokens only.
Reality: Auth also supports OAuth2 (src/auth/providers.ts:5).
Action: Updated topics/decisions.md to include OAuth2.
```

**Entry types:** `INSIGHT` | `ACTION` | `DECISION` | `CONFLICT_RESOLVED` | `MEMORY_CREATED` | `MEMORY_DELETED` | `MEMORY_SUPERSEDED`

**Not loaded into context** — only grep'd when historical lookup needed (e.g., "what did we change in auth last week?").

---

### 5. Define Memory Retrieval Decision Tree

The SKILL.md must tell the agent **how to choose which topic file to load**:

```
User task or question received
    ↓
Scan MEMORY.md Index for matching tags and keywords
    ↓
Match found?
    ├─ Yes → Load relevant topic file(s) on-demand
    └─ No  → Is this derivable from the codebase?
               ├─ Yes → Don't store it; read code directly
               └─ No  → Create new topic file, add to Index
    ↓
Before using any memory entry:
    1. Read cited code location
    2. Compare to stored memory
    3. Match → proceed | Conflict → resolve (see §c)
```

**Retrieval weighting:** When multiple topic files match, prioritize by:
1. Most recently verified (recency)
2. Most relevant tag match to current task
3. Number of matching entries in topic

---

### 6. Define Memory Lifecycle Operations (CRUD)

Beyond write and verify, the SKILL.md must define all lifecycle operations:

| Operation | When | How |
|---|---|---|
| **Create** | New non-derivable fact discovered | Add to topic file → Add pointer to Index |
| **Read** | Memory retrieved from Index | Load topic file on-demand → Verify against code |
| **Update** | Conflict detected or fact changed | Edit entry in topic file → Update `Last Verified` → Update Index if summary changed |
| **Deprecate** | Entry no longer relevant but may be needed for reference | Set `Status: deprecated` (soft delete, still visible) |
| **Supersede** | Entry replaced by newer, more accurate version | Move to Superseded section with `~~strikethrough~~`, reason, date, and link to replacement |
| **Delete** | Entry was wrong, harmful, or duplicated | Remove entry entirely → Remove from Index → Log in transcript |
| **Summarize** | Topic file has grown large or many related entries | Consolidate 3-5 related entries into single summary entry → Archive details in Superseded |
| **Filter** | User asks "what do we know about X?" | Search Index by tag/keyword → Load matching topic files |

---

### 7. Define Conflict Resolution with Rollback

When the agent detects a conflict between memory and live code:

```
1. Read the cited code location
2. Confirm conflict (memory says X, code says Y)
3. Update the topic file entry:
   a. Add superseded entry for old version:
      ~~Old text~~ — Superseded: [date]. Reason: conflicts with live code at [location].
   b. Add new corrected entry with current provenance
4. Update Index pointer if summary changed
5. Log in transcript as CONFLICT_RESOLVED
6. Proceed with corrected memory
```

**Rollback:** If a correction introduced an error, the superseded section preserves the previous version. The agent can restore it:

```
1. Find superseded entry with desired previous version
2. Promote it back to active section with new provenance
3. Supersede the incorrect entry
```

---

### 8. Create transcripts/.gitkeep

Preserves the directory in git.

---

### 9. Update QWEN.md

Add `self-healing-memory` to the Available Skills table in the project QWEN.md.

---

### 10. Update install-skills.ps1

Ensure the new skill directory is included if the installer enumerates skills.

---

### 11. Integration with Existing Skills

Clarify relationship with `sas-endsession`:

| Skill | Purpose | Overlap | Integration |
|---|---|---|---|
| **sas-endsession** | Save session handoff note for next session to resume | Captures what was done, where work left off, next steps | Writes a session note; does NOT maintain long-term knowledge |
| **self-healing-memory** | Maintain persistent, verifiable knowledge across sessions | Could capture session insights too | **Complementary:** `endsession` writes handoff → `self-healing-memory` extracts non-derivable facts from handoff into topic files |

**Recommended workflow:**
1. User wraps up session → triggers `sas-endsession`
2. Next session starts → `sas-reattach` reads handoff
3. During work, `self-healing-memory` extracts facts/decisions into topic files with provenance
4. Transcripts log session-level actions for audit trail

These skills are complementary — `endsession`/`reattach` handles **session continuity**, `self-healing-memory` handles **knowledge persistence and verification**.

---

## Deliverables (Updated)

```
skills/sas-self-healing-memory/
├── SKILL.md                      # Skill definition + agent instructions
├── MEMORY.md                     # Index file (starter template)
├── topics/
│   └── _README.md                # Topic file conventions + examples
└── transcripts/
    └── .gitkeep                  # Preserve directory structure
```

Plus project-level updates:
- `QWEN.md` — add skill to Available Skills table
- `install-skills.ps1` — confirm skill enumeration includes new directory

---

## Out of Scope (for Now)

| Item | Reason |
|---|---|
| Background consolidation agent | Qwen Code doesn't support independent background processes |
| Vector store integration | Requires external infrastructure |
| Knowledge graph | Requires external database |
| RL-optimized memory management | Requires training infrastructure |
| Forked subagent isolation | Not supported by Qwen Code |

---

## Success Criteria

### Behavioral
1. Skill activates when user asks about memory, knowledge management, or persistent context
2. Agent follows write discipline (topic file first → Index second)
3. Agent verifies memory against live code before use
4. Agent corrects memory on conflict detection with superseded entry for old version
5. MEMORY.md and topic files maintain clean, non-duplicated state
6. Skill works across sessions with consistent behavior

### Measurable (Test Scenarios)
7. **Conflict resolution test:** Write memory entry → modify cited code → trigger agent → memory is corrected with superseded entry for old version
8. **Deduplication test:** Add 3 overlapping entries → run consolidation → single consolidated entry + 3 in superseded
9. **Retrieval test:** Ask agent about a topic → correct topic file loaded based on Index tag match
10. **Eviction test:** Mark entry deprecated → run consolidation → entry moved to superseded or removed
11. **Rollback test:** Supersede entry → discover correction was wrong → restore from superseded section
12. **Transcript test:** Search transcripts for "CONFLICT_RESOLVED" → finds correct entries with dates

---

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|---|---|---|---|
| Agent forgets to verify memory before use | High | Medium | Encode as explicit numbered rule in SKILL.md with "PRIORITY" label; put it first |
| Index grows too large (over 150 char entries) | Low | Medium | Enforce ~150 char limit in instructions; use tags for searchability |
| Topic files become stale without consolidation | Medium | High | Last Verified date visible in Index; consolidation session pattern |
| Agent dumps raw content into Index | Medium | Medium | Explicit "NEVER do this" rule + example of correct pattern |
| Transcripts grow unbounded | Low | Low | Date-based rotation (one file per day); old files naturally infrequently accessed |
| Agent creates too many topic files | Low | Medium | Index limits topics; guidance in _README.md on when to merge topics |
| Superseded section bloats topic file | Medium | Medium | Consolidation session moves old superseded entries to archive or deletes |
| Conflict with sas-endsession skill | Low | Low | Clear integration notes in SKILL.md; complementary roles defined |
| Agent skips provenance fields | Medium | High | Template examples in _README.md always include provenance; SKILL.md requires it |

---

## Estimated Complexity

| Task | Complexity | Notes |
|---|---|---|
| SKILL.md | Medium-High — must encode write discipline, verification, CRUD, conflict resolution, retrieval decision tree, and consolidation patterns clearly and concisely |
| MEMORY.md template | Low — simple list format with tag examples |
| Topic file structure (_README.md) | Low-Medium — must include provenance, status lifecycle, and conventions |
| Transcript format definition | Low — structured template is straightforward |
| QWEN.md update | Low |
| install-skills.ps1 review | Low |
| Integration notes (endsession/reattach) | Low — already captured in plan |

---

## Next Step

Begin implementation: create `skills/sas-self-healing-memory/` directory and all deliverables.
