<!-- compiled from: skills/sas-self-healing-memory/SKILL.human.md | 2026-04-14T10:00:00Z -->

---
name: sas-self-healing-memory
description: Maintain a structured, self-correcting memory system for AI agents. Use when the user wants persistent memory across sessions, memory consolidation, conflict resolution, knowledge management, or long-running project context.
---

<purpose>
[P0] Maintain a structured, self-correcting memory system using file-based storage. Enables persistent knowledge across sessions with verification and conflict resolution.
[P0] Memory is a hint, not truth. Always verify against live codebase before using it.
</purpose>

<scope>Use for: long-running projects, architectural decisions, project patterns, expensive-to-re-derive facts. Do NOT use for: derivable facts, temporary notes, conversational info, duplicate documentation.</scope>

<inputs>MEMORY.md Index, topics/ files, transcripts/, live codebase for verification.</inputs>

<outputs>
[P0] Updated topic files, updated MEMORY.md Index, transcript entries.
</outputs>

<rules>
[P0] ALWAYS verify memory against live code before using it. Read cited location, compare to stored memory.
[P0] ALWAYS write to topic file first, then update Index. Never dump raw content into MEMORY.md.
[P0] NEVER store derivable facts. Read code directly instead.
[P0] ALWAYS include provenance: Created date, Source, Last Verified, Status.
[P0] ALWAYS resolve conflicts immediately. Update memory, log in transcript.
[P0] Do not let duplicates accumulate. Supersede (do not delete) outdated entries.
[P0] Transcripts never loaded into context — grep only.
[P1] Topic file >100 lines → summarize; >200 lines → split by sub-domain.
[P1] MEMORY.md >50 entries → review for deprecated/superseded cleanup.
</rules>

<phase_separation>
### Retrieval Flow
Scan MEMORY.md Index for matching tags → Match? Yes → load topic file(s) on-demand. No → Is this derivable from codebase? Yes → read code directly. No → create new topic file, add to Index.

### Verification (before using any memory entry)
1. Read cited code location. 2. Compare to stored memory. 3. Match → proceed. 4. Conflict → execute Conflict Resolution.

### Write Discipline
**Step 1: Topic file** — Add entry under correct section (Facts/Decisions/Patterns):
```
- **[label]** [Content with `file:line` citation]
  - Created: YYYY-MM-DD | Source: session/name
  - Last Verified: YYYY-MM-DD | Status: active
```
**Step 2: Index** — Add pointer (~150 chars) to MEMORY.md:
```
- **[topic-tag]** Brief summary → `code/location.ts`. Verified: YYYY-MM-DD.
```
Tag conventions: `[structure]` `[patterns]` `[decisions]` `[config]` `[api]` `[testing]` `[deploy]` `[security]`

**Step 3: Transcript** — Append to `transcripts/YYYY-MM-DD.md`:
```
### [HH:MM] MEMORY_CREATED
Created entry in topics/[topic].md: [description]. Location: [code location].
```

### Conflict Resolution
1. Confirm: read cited code, verify discrepancy.
2. Supersede old entry (move to Superseded section with strikethrough, reason, date):
   `~~[old entry]~~ — Superseded: YYYY-MM-DD. Reason: conflicts with live code at [file:line].`
3. Add corrected entry with current provenance (Source: conflict-resolution).
4. Update Index pointer if summary changed.
5. Log as `CONFLICT_RESOLVED`: "Memory said: X. Reality: Y. Action: Updated."

### CRUD+ Lifecycle
| Operation | When | How |
|---|---|---|
| Create | New fact | Topic file → Index → transcript |
| Read | Memory retrieved | Index → topic file → verify against code |
| Update | Conflict/change | Edit → Last Verified → Index |
| Deprecate | No longer relevant | Status: deprecated (soft delete) |
| Supersede | Replaced by newer | Move to Superseded with strikethrough, link to replacement |
| Delete | Wrong/harmful/duplicate | Remove → Index → transcript MEMORY_DELETED |
| Summarize | Topic grown large | Consolidate entries → archive details in Superseded |

### Consolidation Trigger
User requests, topic files large, contradictions noticed, or periodic via /loop.
Steps: Review topic files → deduplicate → resolve contradictions → evict low-utility → summarize → update Index → log CONSOLIDATION.

### MEMORY.md Recovery
If missing/corrupted/empty: Check git backups → rebuild from topic files → if no topic files, start fresh with template → verify all entries against live code in next sessions.

### Transcript Format
Append to `transcripts/YYYY-MM-DD.md`. Entry types: `INSIGHT` | `ACTION` | `DECISION` | `CONFLICT_RESOLVED` | `MEMORY_CREATED` | `MEMORY_DELETED` | `MEMORY_SUPERSEDED` | `CONSOLIDATION`

### Quick Reference
| Do | Don't |
|---|---|
| Write to topic file first, then Index | Dump raw content into Index |
| Verify memory against code before use | Trust memory as absolute truth |
| Include provenance on every entry | Store facts derivable from code |
| Supersede outdated entries | Let duplicates accumulate |
| Use tags for Index entries | Create overly long Index entries (>150 chars) |
| Log conflicts in transcripts | Ignore conflicts between memory and code |
</phase_separation>
