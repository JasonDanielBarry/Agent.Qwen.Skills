---
name: sas-self-healing-memory
description: Maintain a structured, self-correcting memory system for AI agents.
---

<!-- compiled from: skills/sas-self-healing-memory/SKILL.human.md | 2026-04-13T10:35:00Z -->

## Purpose

<purpose>
[P0] Provide a structured, self-correcting memory system using file-based storage for persistent knowledge across sessions with automatic verification and conflict resolution.
</purpose>

## Scope

<scope>
- Target: Long-running projects where context is lost between sessions
- Input: Codebase state + memory files (MEMORY.md, topics/, transcripts/)
- Output: Verified memory entries, conflict resolutions, consolidated topic files
- Excluded: Temporary scratchpad notes, easily derivable facts, conversational information, duplicating existing documentation
</scope>

## Inputs

<inputs>
- `MEMORY.md` — Index file (~150 char pointers, always loaded)
- `topics/*.md` — Topic files (loaded on-demand)
- `transcripts/YYYY-MM-DD.md` — Session logs (grep only, never loaded into context)
- Live codebase (for verification against stored memory)
</inputs>

## Outputs

<outputs>
- Updated MEMORY.md with current pointers
- Updated topic files with verified/corrected entries
- New transcript entries logging memory actions (created, deleted, superseded, conflict resolved)
- Consolidation reports (when manual consolidation triggered)
</outputs>

## Constraints

<constraints>
[P0] Must NOT trust memory as absolute truth — always verify against live codebase before use.
[P0] Must NOT dump raw content directly into MEMORY.md — always write to topic file first.
[P0] Must NOT store derivable facts (if it can be re-derived from codebase, don't store it).
[P0] Must NOT use memory for temporary/session-specific scratchpad notes.
[P0] Must NOT use memory for information user asked conversationally.
[P0] Must NOT let duplicates accumulate — resolve conflicts immediately.
[P1] Must include provenance on every entry: Created date, Source, Last Verified, Status.
[P1] Must prefer existing tags from Tag Conventions table — only invent new tags if knowledge area doesn't fit.
[P1] Must keep Index entries under ~150 characters.
</constraints>

## Invariants

<invariants>
[P0] Memory is a hint, not truth — verify against live codebase before using.
[P0] Write order is fixed: topic file first → update Index → log in transcript.
[P0] Transcripts are never loaded into context — grep only.
[P0] Superseded entries preserved with strikethrough, reason, date, link to replacement.
[P0] Conflict resolution always logs what memory claimed, what code showed, and what was done.
</invariants>

## Failure Modes

<failure_modes>
| Scenario | Handling |
|----------|----------|
| MEMORY.md missing, corrupted, or empty | Check git history for backup. If none, rebuild from topic files. If topic files also missing, start fresh with standard template. Log as MEMORY_REBUILD. |
| Topic files missing | Create new topic file following naming conventions in `topics/_README.md`. |
| Memory conflicts with live code | Execute conflict resolution: confirm, supersede old entry, add corrected entry, update Index, log in transcript. |
| Topic file > ~100 lines | Summarize related entries, move details to Superseded, consider splitting. |
| Topic file > ~200 lines | Split into multiple topic files by sub-domain. |
| MEMORY.md > ~50 entries | Review for deprecated/superseded entries, consolidate overlapping topics. |
| Contradictions found during work | Verify both against live code, keep correct one, supersede incorrect one. |
| Correction later turns out wrong | Promote superseded entry back to active with new provenance, supersede the incorrect entry. |
</failure_modes>

## Validation Strategy

<validation_strategy>
- Verify every memory entry has provenance (Created, Source, Last Verified, Status)
- Verify Index entries under ~150 characters
- Verify topic files follow standard structure (Facts, Decisions, Patterns, Superseded)
- Verify transcripts logged with structured entry types
- Verify superseded entries preserved with strikethrough + reason + date
</validation_strategy>

## Relationships

<relationships>
- Depends on: File-based storage (MEMORY.md, topics/, transcripts/)
- Consumed by: Agent decision-making across sessions
- Complementary to: `sas-endsession`/`sas-reattach` (session continuity vs. knowledge persistence)
- Integration: `sas-endsession` saves handoff → `sas-reattach` restores context → this skill extracts non-derivable facts into topic files during work
</relationships>

## Guarantees

<guarantees>
[P0] Memory always verified against live code before use.
[P0] Conflicts resolved and logged — memory self-heals through verification.
[P0] Superseded entries preserved for rollback capability.
[P1] Index entries lightweight (~150 char pointers) — topic files loaded on-demand.
[P2] Consolidation available as manual session when topic files grow large or contradictions found.
</guarantees>

---

## Invocation Conditions

<invocation_conditions>
- Long-running project where context is lost between sessions
- Architectural decisions or patterns need capturing
- Project-specific facts expensive to re-derive
- User asks to "consolidate memory" or "clean up memory"
- Topic files grown large with superseded entries
- Duplicates or contradictions noticed during work
</invocation_conditions>

## Forbidden Usage

<forbidden_usage>
- Must NOT store facts easily derivable from reading the code
- Must NOT use for temporary or session-specific scratchpad notes
- Must NOT use for information user asked conversationally
- Must NOT duplicate existing documentation
- Must NOT dump raw content into MEMORY.md (must write to topic file first)
- Must NOT load transcripts into context (grep only)
- Must NOT ignore conflicts between memory and live code
</forbidden_usage>

## Phase Separation

<phase_separation>
- This skill is fully implemented and operational.
- No deferred features.
</phase_separation>

---

## File Structure

<file_structure>
```
skills/sas-self-healing-memory/
├── SKILL.md          ← This file (instructions)
├── MEMORY.md         ← Index (always loaded; ~150 char pointers)
├── topics/           ← Topic files (loaded on-demand)
│   ├── _README.md    ← Naming conventions and structure guidelines
│   └── *.md
└── transcripts/      ← Session logs (grep only; never loaded into context)
    └── YYYY-MM-DD.md
```
</file_structure>

## Priority Rules

<priority_rules>
[P0] ALWAYS verify memory against live code before using it — read cited file location, compare to stored memory.
[P0] ALWAYS write to topic file first, then update Index — never dump raw content directly into MEMORY.md.
[P0] NEVER store derivable facts — if it can be re-derived from codebase, don't store it.
[P0] ALWAYS include provenance — every entry must have Created date, Source, Last Verified, and Status.
[P0] ALWAYS resolve conflicts immediately — when memory conflicts with live code, update memory and log it.
[P1] PREFER existing tags from Tag Conventions table — only invent new tags if knowledge area truly doesn't fit any existing category.
</priority_rules>

## Tag Conventions

<tag_conventions>
Use existing tags when possible: `[structure]` `[patterns]` `[decisions]` `[config]` `[api]` `[testing]` `[deploy]` `[security]`

Document new tags in MEMORY.md when created.
</tag_conventions>

---

## Write Discipline

### Step 1: Write to Topic File

<step1_write_topic>
[P0] Add entry to appropriate topic file under correct section (Facts, Decisions, or Patterns):

```markdown
- **[Short label]** [Content with citation to code location]
  - Created: YYYY-MM-DD | Source: session/[session-name]
  - Last Verified: YYYY-MM-DD | Status: active
```

IF no suitable topic file exists:
  THEN create one following naming conventions in `topics/_README.md`.
</step1_write_topic>

### Step 2: Update Index

<step2_update_index>
[P0] Add lightweight pointer (~150 characters max) to MEMORY.md under relevant section:

```markdown
- **[topic-tag]** Brief summary with key detail → `code/location.ts`. Verified: YYYY-MM-DD.
```

[P1] Use existing tags when possible.
</step2_update_index>

### Step 3: Log to Transcript

<step3_log_transcript>
[P0] Append entry to `transcripts/YYYY-MM-DD.md`:

```markdown
### [HH:MM] MEMORY_CREATED
Created entry in topics/[topic].md: [brief description].
Location: [cited code location].
```
</step3_log_transcript>

---

## Verification Rule (Self-Healing)

<verification_rule>
[P0] Before using ANY memory entry to inform a decision or action:

1. Read the cited code location from the memory entry.
2. Compare the actual code to the stored memory.
3. IF they match → proceed with confidence.
4. IF they conflict → execute Conflict Resolution (below).

Memory repairs itself through verification during normal agent execution — no background process needed.
</verification_rule>

---

## Conflict Resolution

<conflict_resolution>
[P0] When memory conflicts with live code:

1. **Confirm the conflict** — read cited code location, verify discrepancy.
2. **Supersede the old entry** — move to `## Superseded` section of topic file:
   ```markdown
   - ~~[Old entry text]~~ — Superseded: YYYY-MM-DD. Reason: conflicts with live code at `[file:line]`.
   ```
3. **Add the corrected entry** with current provenance:
   ```markdown
   - **[Short label]** [Corrected content]
     - Created: YYYY-MM-DD | Source: conflict-resolution
     - Last Verified: YYYY-MM-DD | Status: active
   ```
4. **Update Index** pointer in MEMORY.md if summary changed.
5. **Log in transcript** as `CONFLICT_RESOLVED`:
   ```markdown
   ### [HH:MM] CONFLICT_RESOLVED
   Memory said: [what memory claimed].
   Reality: [what code actually shows at location].
   Action: Updated topics/[topic].md to reflect reality.
   ```
6. **Proceed with corrected memory**.

### Rollback

IF a correction later turns out wrong:
  THEN find superseded entry with desired previous version.
  THEN promote it back to active section with new provenance.
  THEN supersede the incorrect entry.
</conflict_resolution>

---

## Memory Lifecycle Operations (CRUD+)

<lifecycle_operations>
| Operation | When | How |
|-----------|------|-----|
| **Create** | New non-derivable fact discovered | Add to topic file → Add pointer to Index → Log in transcript |
| **Read** | Memory retrieved from Index | Load topic file on-demand → Verify against code → Use if valid |
| **Update** | Conflict detected or fact changed | Edit entry → Update Last Verified → Update Index if summary changed |
| **Deprecate** | Entry no longer relevant but may need reference | Set `Status: deprecated` (soft delete; still visible in topic file) |
| **Supersede** | Entry replaced by newer, more accurate version | Move to Superseded section with `~~strikethrough~~`, reason, date, link to replacement |
| **Delete** | Entry was wrong, harmful, or duplicated | Remove entry → Remove from Index → Log in transcript as MEMORY_DELETED |
| **Summarize** | Topic file grown large or many related entries | Consolidate 3-5 entries into single summary → Archive details in Superseded |
| **Filter** | User asks "what do we know about X?" | Search Index by tag/keyword → Load matching topic files |
</lifecycle_operations>

---

## Retrieval Decision Tree

<retrieval_decision>
WHEN to scan MEMORY.md:
- At session start (after `sas-reattach` or when user describes a project)
- Before starting a new task or feature
- When user asks about project context, architecture, or past decisions
- When unsure about a pattern and wanting to check prior knowledge

WHEN user asks a question or starts a task:

1. Scan MEMORY.md Index for matching tags and keywords.
2. IF match found → load relevant topic file(s) on-demand.
3. IF no match → is this derivable from the codebase?
   - IF yes → don't store it; read code directly.
   - IF no → create new topic file, add to Index.
4. Before using any memory entry:
   - Read cited code location.
   - Compare to stored memory.
   - Match → proceed | Conflict → resolve.

Retrieval weighting (when multiple topic files match):
1. Most recently verified (recency).
2. Most relevant tag match to current task.
3. Number of matching entries in topic.
</retrieval_decision>

---

## Consolidation Session

<consolidation>
Trigger consolidation WHEN:
- User asks to "consolidate memory" or "clean up memory"
- Topic files grown large with many superseded entries
- Duplicates or contradictions noticed during normal work
- Scheduled via `/loop` skill for periodic maintenance

### Consolidation Steps

1. **Review all topic files** — scan for outdated, duplicate, or contradictory entries.
2. **Deduplicate** — merge overlapping entries into single consolidated entries; move originals to Superseded.
3. **Resolve contradictions** — verify both against live code; keep correct one, supersede incorrect one.
4. **Evict low-utility** — mark rarely-used entries as deprecated; delete if clearly wrong.
5. **Summarize** — if topic file has 3-5 related entries, consolidate into single summary entry.
6. **Update Index** — ensure all pointers in MEMORY.md reflect current state.
7. **Log in transcript** as consolidation summary:
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
|-----------|---------|--------|
| Topic file > ~100 lines | File grown large | Summarize related entries; move details to Superseded; consider splitting into sub-topics |
| Topic file > ~200 lines | File unwieldy | Split into multiple topic files by sub-domain |
| MEMORY.md > ~50 entries | Index getting dense | Review for deprecated/superseded entries; consolidate overlapping topics |
| Transcripts > 7 days old | Historical logs accumulating | No action needed — archive to `transcripts/archive/` if directory gets slow |
</consolidation>

---

## MEMORY.md Recovery

<memory_recovery>
IF MEMORY.md missing, corrupted, or empty:

1. **Check for backups** — look in git history:
   ```bash
   git log --oneline -- skills/sas-self-healing-memory/MEMORY.md
   git show <commit>:skills/sas-self-healing-memory/MEMORY.md
   ```
2. **IF no backup exists** — rebuild from topic files:
   - Scan all topic files in `topics/`.
   - For each active entry, create ~150-char Index pointer.
   - Add to MEMORY.md under appropriate section.
   - Mark all as "Last Verified: today" with Source: `memory-rebuild`.
3. **IF topic files also missing** — start fresh:
   - Create new MEMORY.md with standard template (see `topics/_README.md`).
   - Log rebuild in transcripts as `MEMORY_REBUILD`.
4. **After recovery** — verify all rebuilt entries against live code within next few sessions.
</memory_recovery>

---

## Topic File Structure

<topic_file_structure>
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
</topic_file_structure>

---

## Transcript Format

<transcript_format>
Append to `transcripts/YYYY-MM-DD.md` with structured entries:

```markdown
# Session Transcript: YYYY-MM-DD

## Session: [session-name]
**Start:** HH:MM UTC | **End:** HH:MM UTC

### [HH:MM] [ENTRY_TYPE]
[Description with locations and memory updates.]
```

Entry types: `INSIGHT` | `ACTION` | `DECISION` | `CONFLICT_RESOLVED` | `MEMORY_CREATED` | `MEMORY_DELETED` | `MEMORY_SUPERSEDED` | `CONSOLIDATION`

Transcripts are **never loaded into context** — use `grep` only for historical lookup.
</transcript_format>
