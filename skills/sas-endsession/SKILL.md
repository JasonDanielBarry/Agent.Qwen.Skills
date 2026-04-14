---
name: sas-endsession
description: Save a lightweight session handoff note so the next session can pick up where this one left off. Use when ending work, wrapping up, saving progress, logging work, or creating a handoff.
---

<purpose>
[P0] Save a lightweight session handoff note so the next session can pick up where this one left off.
[rationale: Eliminates context loss between sessions, enables immediate resume without re-reading history]
</purpose>

<scope>Target: Session handoff notes in .sessions/. Excluded: filesystem scanning, git commands.</scope>

<inputs>Conversation context from current session. Workspace root via .git directory.</inputs>

<outputs>
[P0] .sessions/session-YYYYMMDD-HHmmss.md with YAML frontmatter (session_date ISO 8601 UTC, repo_path forward slashes) and 3 required sections.
</outputs>

<rules>
[P0] Must invoke from repository root (directory containing .git).
[P0] Write report directly — do not ask user confirmation beforehand.
[P0] Do not scan filesystem or run git commands.
[P0] Use forward slashes in repo_path.
[P0] .sessions/ and session-*.md MUST be tracked in git. Never add .sessions/ to .gitignore.
[P0] Each of 3 required sections must have ≥1 bullet point or placeholder.
[P0] Where to Pick Up Next: actionable, specific tasks — not vague goals.
</rules>

<phase_separation>
1. Detect workspace root via .git (current directory or nearest parent).
2. Create .sessions/ if it does not exist.
3. Review conversation context for topics, decisions, completed tasks, open items.
4. Draft report with 3 sections (bullet points):
   - **What Was Done**
   - **Where the Session Left Off**
   - **Where to Pick Up Next**
5. Generate filename: session-YYYYMMDD-HHmmss.md. If collision, append sequence number (-2, -3).
6. Write file with YAML frontmatter (session_date ISO 8601 UTC, repo_path forward slashes).
7. Show user file path and brief preview.
8. Ask if adjustments needed.

**Failure handling:** No substantive content → placeholders ("Nothing completed." / "No open items." / "Nothing to pick up.").

**Git rules:** .sessions/ MUST be tracked. Never add to .gitignore.
</phase_separation>

<invariants>
[P0] UTC timestamp in filename. YAML frontmatter with session_date + repo_path. Exactly 3 required sections.
</invariants>

