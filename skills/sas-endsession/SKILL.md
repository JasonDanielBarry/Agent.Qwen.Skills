---
name: sas-endsession
description: Save a lightweight session handoff note so the next session can pick up where this one left off.
---

<!-- compiled from: skills/sas-endsession/SKILL.human.md | 2026-04-13T10:35:00Z -->

## Purpose

<purpose>
[P0] Save a structured session handoff note to `.sessions/session-YYYYMMDD-HHmmss.md` for context continuity between Qwen Code sessions.
</purpose>

## Scope

<scope>
- Target: Qwen Code sessions requiring context handoff
- Input: Conversation context (no filesystem scanning required)
- Output: `.sessions/session-*.md` file with YAML frontmatter and 3 required sections
- Excluded: Session-resuming (handled by `sas-reattach`), filesystem scanning, git operations for content discovery
</scope>

## Inputs

<inputs>
- Conversation context from current session (what was discussed, accomplished, where work stopped)
- Current UTC timestamp (for filename generation)
- Current working directory (for `repo_path` in frontmatter)
</inputs>

## Outputs

<outputs>
- `.sessions/session-YYYYMMDD-HHmmss.md` file containing:
  - YAML frontmatter (`session_date`, `repo_path`)
  - 3 required sections: `## What Was Done`, `## Where the Session Left Off`, `## Where to Pick Up Next`
</outputs>

## Constraints

<constraints>
[P0] Must NOT ask user for confirmation before writing the file.
[P0] Must NOT scan filesystem or run git commands — conversation context is sufficient.
[P0] Must write directly to `.sessions/` at workspace root.
[P0] Must use forward slashes in `repo_path` regardless of OS.
[P0] Must NOT add `.sessions/` to `.gitignore`.
[P1] Must include all 3 required sections — each with at least one bullet point or placeholder.
[P1] Must generate filename from current UTC timestamp.
[P2] Must append sequence number if filename collision exists.
</constraints>

## Invariants

<invariants>
[P0] `.sessions/` directory and its `session-*.md` files MUST be tracked in git.
[P0] Session reports are shared team knowledge — not local-only artifacts.
[P0] When committing, include `.sessions/` files alongside other changes in same commit.
[P0] Workspace root = directory containing `.git` (or nearest parent with `.git`).
</invariants>

## Failure Modes

<failure_modes>
| Scenario | Handling |
|----------|----------|
| `.sessions/` does not exist | Create it at workspace root |
| Filename collision | Append sequence number: `-2`, `-3`, etc. |
| Trivial session (no substantive output) | Use placeholders: "Nothing completed this session.", "No open items.", "Nothing to pick up." |
| No `.git` in current directory or parents | Use current directory as workspace root |
| User requests adjustments after write | Update file accordingly |
</failure_modes>

## Validation Strategy

<validation_strategy>
- Verify file written to `.sessions/session-*.md` at workspace root
- Verify YAML frontmatter present with `session_date` and `repo_path`
- Verify all 3 required sections present with content
- Verify `.sessions/` not in `.gitignore`
</validation_strategy>

## Relationships

<relationships>
- Consumed by: `sas-reattach` (reads handoff notes to restore context)
- Depends on: None
- Complementary to: `sas-self-healing-memory` (session continuity vs. knowledge persistence)
</relationships>

## Guarantees

<guarantees>
[P0] Next session can restore context from handoff note without re-reading conversation history.
[P0] Handoff notes are git-tracked and shared across team members.
[P1] File written without user confirmation prompts.
</guarantees>

---

## Invocation Conditions

<invocation_conditions>
- User indicates ending work, wrapping up, saving progress, or creating a handoff
- Skill auto-triggered by model when prompt matches description
- Agent writes report from conversation context — no explicit user command required
</invocation_conditions>

## Forbidden Usage

<forbidden_usage>
- Must NOT ask "should I save a handoff note?" before writing
- Must NOT scan filesystem to determine content
- Must NOT run git commands to determine what was done
- Must NOT wait for user approval before writing file
- Must NOT leave `.sessions/` untracked in git
</forbidden_usage>

## Phase Separation

<phase_separation>
- This skill is fully implemented and operational.
- No deferred features.
</phase_separation>

---

## Execution Steps

### Step 1: Determine Workspace Root

<step1_workspace_root>
IF `.git` exists in current directory OR nearest parent:
  THEN use that directory as workspace root.
ELSE:
  THEN use current directory as workspace root.
ENSURE `.sessions/` exists at workspace root — create if needed.
</step1_workspace_root>

### Step 2: Draft and Write Report

<step2_draft_report>
[P0] Review conversation context — determine what was accomplished.
[P0] Draft content for 3 required sections using bullet points:
  1. `## What Was Done` — accomplishments, changes, decisions
  2. `## Where the Session Left Off` — current state, open items, pending decisions
  3. `## Where to Pick Up Next` — actionable, specific next tasks

IF session was trivial (no substantive output):
  THEN use placeholders:
    - "Nothing completed this session."
    - "No open items — session was exploratory or informational."
    - "Nothing to pick up — no further action needed."

[P1] Generate filename: `session-YYYYMMDD-HHmmss.md` (UTC timestamp).
[P1] IF filename collision: append sequence number (`-2`, `-3`, etc.).
[P1] Include YAML frontmatter:
  ```yaml
  ---
  session_date: <UTC ISO 8601 timestamp>
  repo_path: <workspace root with forward slashes>
  ---
  ```
[P0] Write file directly — do NOT ask user for confirmation.
</step2_draft_report>

### Step 3: Confirm Save

<step3_confirm_save>
[P2] Show user: file path + brief preview of saved content.
[P2] Ask if adjustments needed — update file if user requests changes.
</step3_confirm_save>
