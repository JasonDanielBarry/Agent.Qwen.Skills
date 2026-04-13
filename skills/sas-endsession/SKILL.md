<!-- compiled from: skills/sas-endsession/SKILL.human.md | 2026-04-13T14:06:06Z -->

---
name: sas-endsession
description: Save a lightweight session handoff note so the next session can pick up where this one left off. Use when ending work, wrapping up, saving progress, logging work, or creating a handoff.
---

## Purpose

<purpose>
[P0] Save a lightweight session handoff note so the next session can pick up where this one left off.
[rationale: Eliminates context loss between sessions, enables immediate resume without re-reading history]
</purpose>

## Scope

<scope>
- Target: Session handoff notes written to .sessions/ directory at workspace root. Covers workspace root detection, report drafting with 3 required sections, file naming with UTC timestamps, YAML frontmatter, git tracking rules, and post-save user interaction.
- Excluded: Filesystem scanning, git command execution, web searches, reading external state for session context.
</scope>

## Inputs

<inputs>
- Conversation context from the current Qwen Code session (discussion topics, decisions made, tasks completed, open items).
- Workspace root determined by .git directory location (current directory or nearest parent with .git).
</inputs>

## Outputs

<outputs>
[P0] Session report file at .sessions/session-YYYYMMDD-HHmmss.md containing: YAML frontmatter (session_date in ISO 8601 UTC, repo_path with forward slashes), 3 required sections (What Was Done, Where the Session Left Off, Where to Pick Up Next) each with bullet points or placeholders.
</outputs>

## Constraints

<constraints>
[P0] Write the session report directly without asking for user confirmation beforehand.
[P0] Do not scan the filesystem or run git commands. Conversation context is sufficient.
[P0] Use forward slashes in repo_path regardless of OS.
[P0] Each of the 3 required sections must have at least one bullet point or a short placeholder note.
[P0] Where to Pick Up Next must contain actionable, specific tasks — not vague goals.
[P0] .sessions/ directory and session-*.md files MUST be tracked in git. Never add .sessions/ to .gitignore.
</constraints>

## Invariants

<invariants>
[P0] Session files always use UTC timestamp in filename (session-YYYYMMDD-HHmmss.md).
[P0] Session files always include YAML frontmatter with session_date and repo_path.
[P0] Session files always contain exactly 3 required sections (What Was Done, Where the Session Left Off, Where to Pick Up Next).
</invariants>

## Failure Modes

<failure_modes>
- IF session has no substantive output THEN use brief placeholders: "Nothing completed this session." / "No open items." / "Nothing to pick up."
- IF filename already exists THEN append incrementing sequence number: session-YYYYMMDD-HHmmss-2.md, session-YYYYMMDD-HHmmss-3.md.
</failure_modes>

## Validation Strategy

<validation_strategy>
- Verify output file exists at .sessions/ with correct naming pattern (session-YYYYMMDD-HHmmss.md).
- Verify YAML frontmatter contains session_date (ISO 8601 UTC) and repo_path (forward slashes).
- Verify all 3 required sections present with at least one bullet or placeholder each.
- Verify Where to Pick Up Next contains actionable specific tasks.
</validation_strategy>

## Relationships

<relationships>
- Depends on: .sessions/ directory at workspace root.
- Produces: session-*.md files.
- Cross-referenced by: sas-reattach skill (reads latest session handoff note to restore context).
- Complements: sas-git-commit-and-push (includes .sessions/ files in commits).
</relationships>

## Guarantees

<guarantees>
[P0] Session handoff note is always written successfully when invoked.
[P0] Next session is always able to resume context from handoff note.
</guarantees>

## Invocation Conditions

<invocation_conditions>
- Invoke when user signals ending work, wrapping up, saving progress, logging work, or creating a handoff.
- After writing, show the user the file path and a brief preview. Offer to apply adjustments if requested.
</invocation_conditions>

## Forbidden Usage

<forbidden_usage>
[P0] Do not scan the filesystem.
[P0] Do not run git commands.
[P0] Do not ask user for confirmation before writing.
[P0] Do not guess or imply defaults for unspecified behavior.
</forbidden_usage>

## Phase Separation

<phase_separation>
Procedural execution sequence:
1. Determine workspace root via .git detection (current directory or nearest parent with .git).
2. Create .sessions/ at workspace root if it does not exist.
3. Review conversation context for discussion topics, decisions, tasks completed, and open items.
4. Draft report with 3 required sections using bullet points for each item.
5. Generate filename from current UTC timestamp: session-YYYYMMDD-HHmmss.md. If file exists, append sequence number.
6. Write file directly with YAML frontmatter (session_date in ISO 8601 UTC, repo_path with forward slashes).
7. Show user file path and brief preview.
8. Ask if adjustments are needed. If user requests changes, update the file.

Git rules:
- .sessions/ directory and session-*.md files MUST be tracked in git.
- Never add .sessions/ to .gitignore.
- Include .sessions/ files in commits alongside other changes.
</phase_separation>
