---
name: sas-self-healing-memory
description: Maintain a structured, self-correcting memory system for AI agents. Use when the user wants persistent memory across sessions, memory consolidation, conflict resolution, knowledge management, or long-running project context.
---
<!-- compiled from: skills/sas-self-healing-memory/SKILL.human.md | 2026-04-14T12:00:00Z -->

<purpose>
Provide a structured, self-correcting memory system using file-based storage that enables persistent knowledge across sessions with automatic verification and conflict resolution. Core principle: Memory is a hint, not truth. Always verify against the live codebase before using it.
</purpose>

<scope>
Long-running project context, architectural decisions, project-specific patterns, non-derivable facts, and cross-code-area knowledge.
</scope>

<inputs>
User requests for persistent memory, session handoff notes, new architectural decisions, observed patterns, or non-derivable facts discovered during work.
</inputs>

<outputs>
Topic files under topics/, Index entries in MEMORY.md (~150-char pointers), and transcript entries in transcripts/YYYY-MM-DD.md.
</outputs>

<rules>
[P0] MUST always verify memory against live code before using it. Read the cited file location and compare to stored memory.
[P0] MUST always write to topic file first, then update Index. Never dump raw content directly into MEMORY.md.
[P0] MUST never store derivable facts. If it can be re-derived from the codebase, do not store it.
[P0] MUST always include provenance. Every entry must have Created date, Source, Last Verified, and Status.
[P0] MUST always resolve conflicts immediately. When memory conflicts with live code, update memory and log it.
[P1] MUST prefer existing tags from the Tag Conventions table. Only invent new tags if the knowledge area truly does not fit any existing category, and document the new tag in MEMORY.md.
[P1] MUST supersede outdated entries rather than delete them. Move to Superseded section with strikethrough, reason, date, and link to replacement.
[P1] MUST never trust memory as absolute truth. Treat all entries as hints requiring verification.
[P1] MUST never let duplicates accumulate. Deduplicate during consolidation sessions.
[P2] MUST never ignore conflicts between memory and code. Log and resolve every conflict.
[P2] MUST never create overly long Index entries. Keep pointers to ~150 characters max.
</rules>

<phase_separation>
WRITE PHASE:
1. Add entry to appropriate topic file under correct section (Facts, Decisions, or Patterns):
   - [Short label] [Content with citation to code location]
     - Created: YYYY-MM-DD | Source: session/[session-name]
     - Last Verified: YYYY-MM-DD | Status: active
2. If no suitable topic file exists, create one following naming conventions in topics/_README.md.
3. Add lightweight pointer (~150 characters max) to MEMORY.md under relevant section:
   - [topic-tag] Brief summary with key detail -> code/location.ts. Verified: YYYY-MM-DD.
4. Use existing tags: [structure] [patterns] [decisions] [config] [api] [testing] [deploy] [security]
5. Append entry to transcripts/YYYY-MM-DD.md:
   - [HH:MM] MEMORY_CREATED: Created entry in topics/[topic].md: [brief description]. Location: [cited code location].

VERIFICATION PHASE:
1. Read the cited code location from the memory entry.
2. Compare the actual code to the stored memory.
3. IF they match THEN proceed with confidence.
4. IF they conflict THEN execute Conflict Resolution procedure.

CONFLICT RESOLUTION:
1. Confirm the conflict by reading the cited code location and verifying the discrepancy.
2. Supersede the old entry: move to Superseded section of topic file:
   - ~~[Old entry text]~~ -- Superseded: YYYY-MM-DD. Reason: conflicts with live code at [file:line].
3. Add the corrected entry with current provenance:
   - [Short label] [Corrected content]
     - Created: YYYY-MM-DD | Source: conflict-resolution
     - Last Verified: YYYY-MM-DD | Status: active
4. Update Index pointer in MEMORY.md if the summary changed.
5. Log in transcript as CONFLICT_RESOLVED:
   - [HH:MM] CONFLICT_RESOLVED: Memory said: [what memory claimed]. Reality: [what code actually shows at location]. Action: Updated topics/[topic].md to reflect reality.
6. Proceed with corrected memory.

ROLLBACK:
1. Find the superseded entry with the desired previous version.
2. Promote it back to the active section with new provenance.
3. Supersede the incorrect entry.

RETRIEVAL:
1. Scan MEMORY.md Index for matching tags and keywords.
2. IF match found THEN load relevant topic file(s) on-demand.
3. IF no match THEN IF derivable from codebase THEN do not store; read code directly. ELSE create new topic file, add to Index.
4. Before using any memory entry: read cited code location, compare to stored memory. IF match THEN proceed. IF conflict THEN resolve.
5. When multiple topic files match, prioritize by: (1) most recently verified, (2) most relevant tag match, (3) number of matching entries.

CONSOLIDATION (triggered by user request, file growth, or scheduled loop):
1. Review all topic files for outdated, duplicate, or contradictory entries.
2. Deduplicate: merge overlapping entries; move originals to Superseded.
3. Resolve contradictions: verify both against live code; keep correct one, supersede incorrect one.
4. Evict low-utility: mark rarely-used entries as deprecated; delete if clearly wrong.
5. Summarize: consolidate 3-5 related entries into single summary entry.
6. Update Index to reflect current state.
7. Log in transcript as CONSOLIDATION with counts.

SIZE THRESHOLDS:
- IF topic file > ~100 lines THEN summarize related entries; move details to Superseded; consider splitting.
- IF topic file > ~200 lines THEN split into multiple topic files by sub-domain.
- IF MEMORY.md > ~50 entries THEN review for deprecated/superseded entries; consolidate overlapping topics.
- IF transcripts > 7 days old THEN archive to transcripts/archive/ if directory gets slow.

MEMORY.md RECOVERY:
1. IF MEMORY.md missing/corrupted/empty THEN check git history: git log --oneline -- skills/sas-self-healing-memory/MEMORY.md, then git show <commit>:skills/sas-self-healing-memory/MEMORY.md.
2. IF no backup exists THEN rebuild from topic files: scan all topic files, create ~150-char Index pointer for each active entry, mark as Last Verified: today with Source: memory-rebuild.
3. IF topic files also missing THEN create new MEMORY.md with standard template; log rebuild in transcripts as MEMORY_REBUILD.
4. After recovery, verify all rebuilt entries against live code within next few sessions.
</phase_separation>

<invariants>
- Memory files exist at: SKILL.md, MEMORY.md, topics/*.md, transcripts/YYYY-MM-DD.md.
- Every memory entry has Created, Source, Last Verified, and Status fields.
- Index entries never exceed ~150 characters.
- Transcripts are never loaded into context; used for grep only.
- Superseded entries preserve previous versions for rollback capability.
- Topic files follow structure: Facts, Decisions, Patterns, Superseded sections.
- Entry types for transcripts: INSIGHT | ACTION | DECISION | CONFLICT_RESOLVED | MEMORY_CREATED | MEMORY_DELETED | MEMORY_SUPERSEDED | CONSOLIDATION.
- This skill is complementary to sas-endsession and sas-reattach: session continuity handled by those skills; knowledge persistence and verification handled by this skill.
- Recommended workflow: (1) sas-endsession saves handoff note, (2) sas-reattach restores session context, (3) self-healing-memory extracts non-derivable facts into topic files with provenance, (4) transcripts log session-level actions.
</invariants>

