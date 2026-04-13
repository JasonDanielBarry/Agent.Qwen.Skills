<!-- compiled from: skills/sas-self-healing-memory/SKILL.human.md | 2026-04-13T10:06:06Z -->

---
name: sas-self-healing-memory
description: Maintain a structured, self-correcting memory system for AI agents. Use when the user wants persistent memory across sessions, memory consolidation, conflict resolution, knowledge management, or long-running project context.
---

<Purpose>
[P1] Maintain a structured, self-correcting memory system for AI agents using file-based storage. Enables persistent knowledge across sessions with automatic verification and conflict resolution.
[P0] Memory is a hint, not truth. Always verify against the live codebase before using it.
</Purpose>

<Scope>
[P1] Use memory for: long-running projects where context is lost between sessions; capturing architectural decisions and rationale; recording project-specific patterns and conventions; tracking facts expensive to re-derive; maintaining knowledge spanning multiple code areas.
[P0] Do not use memory for: facts easily derivable from reading the code; temporary or session-specific scratchpad notes; information the user asked for conversationally; anything that would duplicate existing documentation.
</Scope>

<Inputs>
[P1] Existing MEMORY.md Index, topic files in topics/, transcript files in transcripts/, live codebase for verification.
</Inputs>

<Outputs>
[P1] Updated topic files with new/modified entries, updated MEMORY.md Index pointers, transcript entries logging memory operations.
</Outputs>

<Constraints>
[P0] ALWAYS verify memory against live code before using it. Read the cited file location and compare to stored memory.
[P0] ALWAYS write to topic file first, then update Index. Never dump raw content directly into MEMORY.md.
[P0] NEVER store derivable facts. If it can be re-derived from the codebase, do not store it.
[P0] ALWAYS include provenance. Every entry must have Created date, Source, Last Verified, and Status.
[P0] ALWAYS resolve conflicts immediately. When memory conflicts with live code, update memory and log it.
[P1] PREFER existing tags from the Tag Conventions table. Only invent new tags if the knowledge area truly does not fit any existing category, and document the new tag in MEMORY.md.
[P0] Do not dump raw content into Index — write to topic file first, then Index.
[P0] Do not trust memory as absolute truth — verify memory against code before use.
[P0] Do not store facts derivable from code — include provenance on every entry.
[P0] Do not let duplicates accumulate — supersede (do not delete) outdated entries.
[P0] Do not create overly long Index entries (>150 chars) — use tags for Index entries.
[P0] Do not ignore conflicts between memory and code — log conflicts in transcripts.
[P0] Transcripts are never loaded into context — use grep only for historical lookup.
[P1] Topic file > ~100 lines → Summarize related entries; move details to Superseded; consider splitting into sub-topics.
[P1] Topic file > ~200 lines → Split into multiple topic files by sub-domain.
[P1] MEMORY.md > ~50 entries → Review for deprecated/superseded entries to clean up; consolidate overlapping topics.
[P2] Transcripts > 7 days old → No action needed — transcripts are grep-only; archive to transcripts/archive/ if directory gets slow.
</Constraints>

<Invariants>
[P0] Memory is a hint, not truth. Always verify against the live codebase before using it.
[P0] Transcripts are never loaded into context — use grep only for historical lookup.
</Invariants>

<Failure Modes>
[P1] Memory conflicts with live code → Execute Conflict Resolution procedure: confirm discrepancy, supersede old entry, add corrected entry, update Index, log in transcript.
[P1] MEMORY.md missing, corrupted, or empty → Execute Recovery procedure: check git backups, rebuild from topic files, or start fresh with standard template.
[P1] Topic files exceed size thresholds (>100 lines, >200 lines) → Summarize, split, or consolidate to maintain usability.
[P1] Duplicate or contradictory entries detected → Execute Consolidation: deduplicate, resolve contradictions via verification, evict low-utility entries.
</Failure Modes>

<Validation Strategy>
[P0] Before using any memory entry: read cited code location, compare to stored memory, proceed if match, resolve if conflict.
[P1] During consolidation: verify all entries against live code, keep correct ones, supersede incorrect ones.
[P1] After MEMORY.md recovery: verify all rebuilt entries against live code within the next few sessions.
[P0] Provenance check: every entry must have Created date, Source, Last Verified, and Status fields.
</Validation Strategy>

<Relationships>
[P1] Complementary to sas-endsession and sas-reattach. sas-endsession/reattach handles session continuity; self-healing-memory handles knowledge persistence and verification.
</Relationships>

<Guarantees>
[P0] All memory entries include provenance (Created, Source, Last Verified, Status).
[P1] Superseded entries are preserved with strikethrough, enabling rollback to previous versions.
[P1] Transcript log provides complete audit trail of all memory operations.
</Guarantees>

---

## Invocation Conditions

<invocation_conditions>
[P1] Scan MEMORY.md at session start (after sas-reattach or when user describes a project); before starting a new task or feature; when the user asks about project context, architecture, or past decisions; when unsure about a pattern.
[P1] Retrieval flow: Scan MEMORY.md Index for matching tags → Match found? Yes → Load relevant topic file(s) on-demand. No → Is this derivable from the codebase? Yes → Do not store it; read code directly. No → Create new topic file, add to Index.
[P0] Before using any memory entry: 1. Read the cited code location from the memory entry. 2. Compare the actual code to the stored memory. 3. If they match → proceed with confidence. 4. If they conflict → execute Conflict Resolution.
[P2] Retrieval weighting: When multiple topic files match, prioritize by: 1. Most recently verified (recency). 2. Most relevant tag match to current task. 3. Number of matching entries in topic.
</invocation_conditions>

---

## Forbidden Usage

<forbidden_usage>
[P0] Must not dump raw content into Index — write to topic file first, then Index.
[P0] Must not trust memory as absolute truth — verify memory against code before use.
[P0] Must not store facts derivable from code.
[P0] Must not let duplicates accumulate.
[P0] Must not create overly long Index entries (>150 chars).
[P0] Must not ignore conflicts between memory and code.
[P0] Must not load transcripts into context — grep only.
</forbidden_usage>

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

---

## Write Discipline

<write_discipline>
### Step 1: Write to Topic File

[P1] Add entry to appropriate topic file under correct section (Facts, Decisions, or Patterns).

Format:
```markdown
- **[Short label]** [Content with citation to code location]
  - Created: YYYY-MM-DD | Source: session/[session-name]
  - Last Verified: YYYY-MM-DD | Status: active
```

If no suitable topic file exists, create one following the naming conventions in `topics/_README.md`.

### Step 2: Update Index

[P1] Add lightweight pointer (~150 characters max) to `MEMORY.md` under the relevant section.

Format:
```markdown
- **[topic-tag]** Brief summary with key detail → `code/location.ts`. Verified: YYYY-MM-DD.
```

Tag Conventions: Use existing tags: `[structure]` `[patterns]` `[decisions]` `[config]` `[api]` `[testing]` `[deploy]` `[security]`

### Step 3: Log to Transcript

[P1] Append entry to `transcripts/YYYY-MM-DD.md` with timestamp, entry type `MEMORY_CREATED`, brief description, and cited code location.

Format:
```markdown
### [HH:MM] MEMORY_CREATED
Created entry in topics/[topic].md: [brief description].
Location: [cited code location].
```
</write_discipline>

---

## Conflict Resolution

<conflict_resolution>
[P1] Confirm the conflict — read the cited code location and verify the discrepancy.
[P1] Supersede the old entry — move it to the `## Superseded` section of the topic file:
```markdown
- ~~[Old entry text]~~ — Superseded: YYYY-MM-DD. Reason: conflicts with live code at `[file:line]`.
```
[P1] Add the corrected entry with current provenance:
```markdown
- **[Short label]** [Corrected content]
  - Created: YYYY-MM-DD | Source: conflict-resolution
  - Last Verified: YYYY-MM-DD | Status: active
```
[P1] Update Index pointer in MEMORY.md if the summary changed.
[P1] Log in transcript as `CONFLICT_RESOLVED`:
```markdown
### [HH:MM] CONFLICT_RESOLVED
Memory said: [what memory claimed].
Reality: [what code actually shows at location].
Action: Updated topics/[topic].md to reflect reality.
```
[P1] Proceed with corrected memory.
</conflict_resolution>

### Rollback

<rollback>
[P1] To rollback a correction: 1. Find the superseded entry with the desired previous version. 2. Promote it back to the active section with new provenance. 3. Supersede the incorrect entry.
</rollback>

---

## Memory Lifecycle Operations (CRUD+)

<crud_operations>
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
</crud_operations>

---

## Consolidation Session

<consolidation>
[P1] Trigger consolidation when: user asks to consolidate memory or clean up memory; topic files have grown large with many superseded entries; duplicates or contradictions noticed during normal work; scheduled via `/loop` skill for periodic maintenance.

### Consolidation Steps

1. Review all topic files — scan for outdated, duplicate, or contradictory entries.
2. Deduplicate — merge overlapping entries into single consolidated entries; move originals to Superseded.
3. Resolve contradictions — verify both against live code; keep correct one, supersede incorrect one.
4. Evict low-utility — mark rarely-used entries as deprecated; delete if clearly wrong.
5. Summarize — if a topic file has 3-5 related entries, consolidate into a single summary entry.
6. Update Index — ensure all pointers in MEMORY.md reflect current state.
7. Log in transcript as `CONSOLIDATION`:
```markdown
### [HH:MM] CONSOLIDATION
Reviewed: [N] topic files.
Deduplicated: [N] entries.
Superseded: [N] entries.
Deleted: [N] entries.
Summarized: [N] groups of entries.
```
</consolidation>

---

## MEMORY.md Recovery

<memory_recovery>
[P1] If MEMORY.md missing/corrupted/empty:
1. Check for backups via git log:
   ```bash
   git log --oneline -- skills/sas-self-healing-memory/MEMORY.md
   git show <commit>:skills/sas-self-healing-memory/MEMORY.md
   ```
2. If no backup, rebuild from topic files: scan all, create ~150-char pointers, mark Last Verified: today, Source: `memory-rebuild`.
3. If topic files also missing, start fresh with standard template, log as `MEMORY_REBUILD`.
4. After recovery, verify all rebuilt entries against live code within the next few sessions.
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
[P1] Append to `transcripts/YYYY-MM-DD.md` with structured entries:
```markdown
# Session Transcript: YYYY-MM-DD

## Session: [session-name]
**Start:** HH:MM UTC | **End:** HH:MM UTC

### [HH:MM] [ENTRY_TYPE]
[Description with locations and memory updates.]
```

Entry types: `INSIGHT` | `ACTION` | `DECISION` | `CONFLICT_RESOLVED` | `MEMORY_CREATED` | `MEMORY_DELETED` | `MEMORY_SUPERSEDED` | `CONSOLIDATION`

[P0] Transcripts are never loaded into context — use `grep` only for historical lookup.
</transcript_format>

---

## Integration with Other Skills

<integration>
[P1] Complementary to `sas-endsession` and `sas-reattach`:
- **sas-endsession/reattach** → handles session continuity (what was done, where left off, next steps)
- **self-healing-memory** → handles knowledge persistence and verification (facts, decisions, patterns)

[P1] Recommended workflow:
1. End session with `sas-endsession` → saves handoff note
2. Resume with `sas-reattach` → restores session context
3. During work, use `self-healing-memory` → extracts non-derivable facts into topic files with provenance
4. Transcripts log session-level actions for audit trail
</integration>

---

## Quick Reference

<quick_reference>
| Do | Don't |
|---|---|
| Write to topic file first, then Index | Dump raw content into Index |
| Verify memory against code before use | Trust memory as absolute truth |
| Include provenance on every entry | Store facts derivable from code |
| Supersede (do not delete) outdated entries | Let duplicates accumulate |
| Use tags for Index entries | Create overly long Index entries (>150 chars) |
| Log conflicts in transcripts | Ignore conflicts between memory and code |
</quick_reference>
