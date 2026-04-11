# Topic: self-healing-memory

## Facts

- **[Three-layer architecture]** Memory uses Index → Topic Files → Transcripts hierarchy → `SKILL.md:17-25`
  - Created: 2026-04-10 | Source: skill-implementation
  - Last Verified: 2026-04-10 | Status: active

- **[Index size limit]** Each MEMORY.md entry is capped at ~150 characters → `SKILL.md:31`
  - Created: 2026-04-10 | Source: skill-implementation
  - Last Verified: 2026-04-10 | Status: active

- **[Topic file size threshold]** When a topic file exceeds ~100 lines, trigger consolidation → `SKILL.md:107`
  - Created: 2026-04-10 | Source: skill-implementation
  - Last Verified: 2026-04-10 | Status: active

## Decisions

- **[Verification-first retrieval]** Memory is treated as a hint, not truth — always verify against live code before use → `SKILL.md:33-40`
  - Date: 2026-04-10 | Source: skill-implementation
  - Last Verified: 2026-04-10 | Status: active

- **[Write discipline]** Always write to topic file first, then update Index — never dump raw content into MEMORY.md → `SKILL.md:31-32`
  - Date: 2026-04-10 | Source: skill-implementation
  - Last Verified: 2026-04-10 | Status: active

- **[No derivable facts]** If information can be re-derived from the codebase, don't store it → `SKILL.md:33`
  - Date: 2026-04-10 | Source: skill-implementation
  - Last Verified: 2026-04-10 | Status: active

## Patterns

- **[Conflict resolution workflow]** When memory conflicts with live code: confirm → supersede → correct → update Index → log → proceed → `SKILL.md:69-87`
  - Observed: 2026-04-10 | Status: active

- **[Transcript entry types]** Use structured types: INSIGHT | ACTION | DECISION | CONFLICT_RESOLVED | MEMORY_CREATED | MEMORY_DELETED | MEMORY_SUPERSEDED | CONSOLIDATION → `SKILL.md:170`
  - Observed: 2026-04-10 | Status: active

- **[Tag convention enforcement]** Prefer existing tags from MEMORY.md table; only create new tags if truly necessary → `MEMORY.md:28-37`
  - Observed: 2026-04-10 | Status: active

## Superseded

<!-- No superseded entries yet. -->
