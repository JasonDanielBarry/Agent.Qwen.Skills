---
name: aqs-self-healing-memory
description: Maintain a structured, self-correcting memory system for AI agents. Use when the user wants persistent memory across sessions, memory consolidation, conflict resolution, knowledge management, or long-running project context.
---

# Self-Healing Memory

## Overview

This skill provides a structured, self-correcting memory system using file-based storage. It enables persistent knowledge across sessions with automatic verification and conflict resolution.

**Core principle: Memory is a hint, not truth. Always verify against the live codebase before using it.**

## File Structure

```
skills/aqs-self-healing-memory/
├── SKILL.md          ← This file (instructions)
├── MEMORY.md         ← Index (always loaded; ~150 char pointers)
├── topics/           ← Topic files (loaded on-demand)
│   ├── _README.md    ← Naming conventions and structure guidelines
│   └── *.md
└── transcripts/      ← Session logs (grep only; never loaded into context)
    └── YYYY-MM-DD.md
```

## PRIORITY RULES

1. **ALWAYS verify memory against live code before using it.** Read the cited file location and compare to stored memory.
2. **ALWAYS write to topic file first, then update Index.** Never dump raw content directly into MEMORY.md.
3. **NEVER store derivable facts.** If it can be re-derived from the codebase, don't store it.
4. **ALWAYS include provenance.** Every entry must have Created date, Source, Last Verified, and Status.
5. **ALWAYS resolve conflicts immediately.** When memory conflicts with live code, update memory and log it.
6. **PREFER existing tags from the Tag Conventions table.** Only invent new tags if the knowledge area truly doesn't fit any existing category, and document the new tag in MEMORY.md.

---

## How to Use This Skill

### When Memory Should Be Used

- Long-running projects where context is lost between sessions
- Capturing architectural decisions and their rationale
- Recording project-specific patterns and conventions
- Tracking facts that are expensive to re-derive
- Maintaining knowledge that spans multiple code areas

### When NOT to Use Memory

- Facts easily derivable from reading the code
- Temporary or session-specific scratchpad notes
- Information the user asked for conversationally
- Anything that would duplicate existing documentation

---

## Write Discipline

### Step 1: Write to Topic File

Add the entry to the appropriate topic file under the correct section (Facts, Decisions, or Patterns):

```markdown
- **[Short label]** [Content with citation to code location]
  - Created: YYYY-MM-DD | Source: session/[session-name]
  - Last Verified: YYYY-MM-DD | Status: active
```

If no suitable topic file exists, create one following the naming conventions in `topics/_README.md`.

### Step 2: Update Index

Add a lightweight pointer (~150 characters max) to `MEMORY.md` under the relevant section:

```markdown
- **[topic-tag]** Brief summary with key detail → `code/location.ts`. Verified: YYYY-MM-DD.
```

Use existing tags when possible: `[structure]` `[patterns]` `[decisions]` `[config]` `[api]` `[testing]` `[deploy]` `[security]`

### Step 3: Log to Transcript

Append an entry to `transcripts/YYYY-MM-DD.md`:

```markdown
### [HH:MM] MEMORY_CREATED
Created entry in topics/[topic].md: [brief description].
Location: [cited code location].
```

---

## Verification Rule (Self-Healing)

Before using ANY memory entry to inform a decision or action:

1. Read the cited code location from the memory entry
2. Compare the actual code to the stored memory
3. **If they match** → proceed with confidence
4. **If they conflict** → execute Conflict Resolution (below)

This is the core self-healing mechanism. Memory repairs itself through verification during normal agent execution — no background process needed.

---

## Conflict Resolution

When memory conflicts with live code:

1. **Confirm the conflict** — read the cited code location and verify the discrepancy
2. **Supersede the old entry** — move it to the `## Superseded` section of the topic file:
   ```markdown
   - ~~[Old entry text]~~ — Superseded: YYYY-MM-DD. Reason: conflicts with live code at `[file:line]`.
   ```
3. **Add the corrected entry** with current provenance:
   ```markdown
   - **[Short label]** [Corrected content]
     - Created: YYYY-MM-DD | Source: conflict-resolution
     - Last Verified: YYYY-MM-DD | Status: active
   ```
4. **Update Index** pointer in MEMORY.md if the summary changed
5. **Log in transcript** as `CONFLICT_RESOLVED`:
   ```markdown
   ### [HH:MM] CONFLICT_RESOLVED
   Memory said: [what memory claimed].
   Reality: [what code actually shows at location].
   Action: Updated topics/[topic].md to reflect reality.
   ```
6. **Proceed with corrected memory**

### Rollback

If a correction later turns out to be wrong, the superseded section preserves the previous version. To rollback:

1. Find the superseded entry with the desired previous version
2. Promote it back to the active section with new provenance
3. Supersede the incorrect entry

---

## Memory Lifecycle Operations (CRUD+)

| Operation | When | How |
|---|---|---|
| **Create** | New non-derivable fact discovered | Add to topic file → Add pointer to Index → Log in transcript |
| **Read** | Memory retrieved from Index | Load topic file on-demand → Verify against code → Use if valid |
| **Update** | Conflict detected or fact changed | Edit entry → Update Last Verified → Update Index if summary changed |
| **Deprecate** | Entry no longer relevant but may need reference | Set `Status: deprecated` (soft delete; still visible in topic file) |
| **Supersede** | Entry replaced by newer, more accurate version | Move to Superseded section with `~~strikethrough~~`, reason, date, link to replacement |
| **Delete** | Entry was wrong, harmful, or duplicated | Remove entry → Remove from Index → Log in transcript as MEMORY_DELETED |
| **Summarize** | Topic file grown large or many related entries | Consolidate 3-5 entries into single summary → Archive details in Superseded |
| **Filter** | User asks "what do we know about X?" | Search Index by tag/keyword → Load matching topic files |

---

## Retrieval Decision Tree

**When to scan MEMORY.md:**
- At session start (after `aqs-reattach` or when user describes a project)
- Before starting a new task or feature
- When the user asks about project context, architecture, or past decisions
- When you're unsure about a pattern and want to check prior knowledge

When the user asks a question or starts a task:

```
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
    3. Match → proceed | Conflict → resolve
```

**Retrieval weighting:** When multiple topic files match, prioritize by:
1. Most recently verified (recency)
2. Most relevant tag match to current task
3. Number of matching entries in topic

---

## Consolidation Session

Since there is no background agent, consolidation is a manual session. Trigger it when:

- The user asks to "consolidate memory" or "clean up memory"
- Topic files have grown large with many superseded entries
- You notice duplicates or contradictions during normal work
- Scheduled via the `/loop` skill for periodic maintenance

### Consolidation Steps

1. **Review all topic files** — scan for outdated, duplicate, or contradictory entries
2. **Deduplicate** — merge overlapping entries into single consolidated entries; move originals to Superseded
3. **Resolve contradictions** — verify both against live code; keep correct one, supersede incorrect one
4. **Evict low-utility** — mark rarely-used entries as deprecated; delete if clearly wrong
5. **Summarize** — if a topic file has 3-5 related entries, consolidate into a single summary entry
6. **Update Index** — ensure all pointers in MEMORY.md reflect current state
7. **Log in transcript** as a consolidation summary:
   ```markdown
   ### [HH:MM] CONSOLIDATION
   Reviewed: [N] topic files.
   Deduplicated: [N] entries.
   Superseded: [N] entries.
   Deleted: [N] entries.
   Summarized: [N] groups of entries.
   ```

### Size Thresholds

| Threshold | Trigger | Action |
|---|---|---|
| **Topic file > ~100 lines** | File has grown large | Summarize related entries; move details to Superseded; consider splitting into sub-topics |
| **Topic file > ~200 lines** | File is unwieldy | Split into multiple topic files by sub-domain (e.g., `auth-patterns.md`, `auth-decisions.md`) |
| **MEMORY.md > ~50 entries** | Index is getting dense | Review for deprecated/superseded entries to clean up; consolidate overlapping topics |
| **Transcripts > 7 days old** | Historical logs accumulating | No action needed — transcripts are grep-only; archive to `transcripts/archive/` if directory gets slow |

---

## MEMORY.md Recovery

If MEMORY.md is missing, corrupted, or empty:

1. **Check for backups** — look in git history for the last known-good version:
   ```bash
   git log --oneline -- skills/aqs-self-healing-memory/MEMORY.md
   git show <commit>:skills/aqs-self-healing-memory/MEMORY.md
   ```
2. **If no backup exists** — rebuild from topic files:
   - Scan all topic files in `topics/`
   - For each active entry, create a ~150-char Index pointer
   - Add to MEMORY.md under the appropriate section
   - Mark all as "Last Verified: today" with Source: `memory-rebuild`
3. **If topic files are also missing** — start fresh:
   - Create a new MEMORY.md with the standard template (see `topics/_README.md`)
   - Log the rebuild in transcripts as `MEMORY_REBUILD`
4. **After recovery** — verify all rebuilt entries against live code within the next few sessions

---

## Topic File Structure

```markdown
# Topic: [name]

## Facts
- **[Short label]** [Content with `file:line` citation]
  - Created: YYYY-MM-DD | Source: session/[name]
  - Last Verified: YYYY-MM-DD | Status: active

## Decisions
- **[Decision label]** [Rationale]
  - Date: YYYY-MM-DD | Source: session/[name]
  - Last Verified: YYYY-MM-DD | Status: active

## Patterns
- **[Pattern label]** [Description with example location]
  - Observed: YYYY-MM-DD | Status: active

## Superseded
- ~~[Old entry]~~ — Superseded: YYYY-MM-DD. Reason: [why]. See: [replacement].
```

For detailed conventions, see `topics/_README.md`.

---

## Transcript Format

Append to `transcripts/YYYY-MM-DD.md` with structured entries:

```markdown
# Session Transcript: YYYY-MM-DD

## Session: [session-name]
**Start:** HH:MM UTC | **End:** HH:MM UTC

### [HH:MM] [ENTRY_TYPE]
[Description with locations and memory updates.]
```

**Entry types:** `INSIGHT` | `ACTION` | `DECISION` | `CONFLICT_RESOLVED` | `MEMORY_CREATED` | `MEMORY_DELETED` | `MEMORY_SUPERSEDED` | `CONSOLIDATION`

Transcripts are **never loaded into context** — use `grep` only for historical lookup.

---

## Integration with Other Skills

This skill is **complementary** to `aqs-endsession` and `aqs-reattach`:

- **aqs-endsession/reattach** → handles session continuity (what was done, where left off, next steps)
- **self-healing-memory** → handles knowledge persistence and verification (facts, decisions, patterns)

**Recommended workflow:**
1. End session with `aqs-endsession` → saves handoff note
2. Resume with `aqs-reattach` → restores session context
3. During work, use `self-healing-memory` → extracts non-derivable facts into topic files with provenance
4. Transcripts log session-level actions for audit trail

---

## Quick Reference

| Do | Don't |
|---|---|
| Write to topic file first, then Index | Dump raw content into Index |
| Verify memory against code before use | Trust memory as absolute truth |
| Include provenance on every entry | Store facts derivable from code |
| Supersede (don't delete) outdated entries | Let duplicates accumulate |
| Use tags for Index entries | Create overly long Index entries (>150 chars) |
| Log conflicts in transcripts | Ignore conflicts between memory and code |
