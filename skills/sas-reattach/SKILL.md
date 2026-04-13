---
name: sas-reattach
description: Read the latest session handoff note and pick up where the previous session left off.
---

<!-- compiled from: skills/sas-reattach/SKILL.human.md | 2026-04-13T10:35:00Z -->

## Purpose

<purpose>
[P0] Restore working context when resuming a Qwen Code session by reading the most recent handoff note from `sas-endsession`.
</purpose>

## Scope

<scope>
- Target: Qwen Code sessions resuming after a handoff note was saved
- Input: `.sessions/session-*.md` files at workspace root
- Output: Context summary + active todo list from "Where to Pick Up Next" section
- Excluded: Subdirectory invocation (must run from repository root), session handoff creation (handled by `sas-endsession`)
</scope>

## Inputs

<inputs>
- `.sessions/` directory at workspace root containing `session-*.md` files
- Current working directory (must contain `.git`)
- YAML frontmatter from session files (`session_date`, `repo_path`)
</inputs>

## Outputs

<outputs>
- Displayed summary: What was done, where session left off, where to pick up next
- Active todo list created/merged from "Where to Pick Up Next" bullet points
- Warning messages (if applicable): repo mismatch, stale session, missing sections
</outputs>

## Constraints

<constraints>
[P0] Must NOT run from subdirectory — requires repository root (directory containing `.git`).
[P0] Must NOT scan filesystem outside `.sessions/` directory.
[P0] Must NOT trust `repo_path` mismatches without warning user.
[P0] Must NOT create todos from non-actionable placeholder content.
[P1] Must filter session files by exact `repo_path` match before selecting most recent.
[P1] Must ignore YAML frontmatter fields beyond `session_date` and `repo_path`.
[P2] Must normalize all paths to forward slashes for comparison.
</constraints>

## Invariants

<invariants>
[P0] `.sessions/` directory and `session-*.md` files MUST be git-tracked.
[P0] `.sessions/` MUST NOT be added to `.gitignore`.
[P0] Session handoff notes are shared team knowledge — not local-only artifacts.
[P0] Most recent file determined by filename timestamp first, mtime fallback second.
</invariants>

## Failure Modes

<failure_modes>
| Scenario | Handling |
|----------|----------|
| No `.git` in current directory | Display error: "sas-reattach must be run from a repository root." Exit. |
| No `.sessions/` directory | Display: "No `.sessions/` directory found. Run sas-endsession first." Exit. |
| `.sessions/` exists but empty | Display: "No session reports found. Run sas-endsession first." Exit. |
| No valid `session-*.md` files | Display: "No valid session report found. Run sas-endsession first." Exit. |
| `repo_path` mismatch | Warn user, ask if they want to proceed anyway. |
| Session age > 168 hours (7 days) | Non-blocking warning: "This session is {X} days old. Context may be outdated." |
| Invalid session_date | Skip age check, note: "Session date is invalid — age cannot be determined." |
| Missing sections in handoff note | Report which sections are absent. |
| "Where to Pick Up Next" missing or empty | Skip todo creation, ask user what to work on. |
</failure_modes>

## Validation Strategy

<validation_strategy>
- Verify `.git` present in current directory
- Verify `.sessions/` exists with at least one valid `session-*.md` file
- Verify YAML frontmatter parseable with `session_date` and `repo_path`
- Verify 3 required sections present in handoff note content
</validation_strategy>

## Relationships

<relationships>
- Depends on: `sas-endsession` (creates handoff notes this skill reads)
- Consumed by: Agent's active todo list management
- Complementary to: `sas-self-healing-memory` (session continuity vs. knowledge persistence)
</relationships>

## Guarantees

<guarantees>
[P0] Context restored from handoff note without requiring user to re-explain.
[P0] Todo list created or merged from "Where to Pick Up Next" section.
[P1] Stale sessions warned about with age calculation.
[P1] Repo mismatches warned about with user confirmation option.
</guarantees>

---

## Invocation Conditions

<invocation_conditions>
- User indicates resuming work, continuing a session, restoring context, or asking what was being worked on
- Skill auto-triggered by model when prompt matches description
- Must be invoked from repository root (directory containing `.git`)
</invocation_conditions>

## Forbidden Usage

<forbidden_usage>
- Must NOT run from subdirectories
- Must NOT read session files outside `.sessions/`
- Must NOT trust content outside the 3 required section headers
- Must NOT create todos from placeholder/non-actionable content
- Must NOT modify session handoff files
</forbidden_usage>

## Phase Separation

<phase_separation>
- This skill is fully implemented and operational.
- No deferred features.
</phase_separation>

---

## Execution Steps

### Step 1: Validate Current Directory

<step1_validate_repo>
IF `.git` NOT present in current directory:
  THEN display error: "sas-reattach must be run from a repository root (a directory containing `.git`). You are currently in a subdirectory. Navigate to the repo root and try again."
  THEN exit.
ELSE: proceed.
</step1_validate_repo>

### Step 2: Determine Workspace Root

<step2_workspace_root>
[P0] Use current directory as workspace root (it contains `.git`).
</step2_workspace_root>

### Step 3: Handle Missing Reports

<step3_missing_reports>
IF `.sessions/` does NOT exist:
  THEN display: "No `.sessions/` directory found. Run sas-endsession first to save your session state."
  THEN exit.
IF `.sessions/` exists but contains no `session-*.md` files:
  THEN display: "`.sessions/` exists but no session reports found. Run sas-endsession first to save your session state."
  THEN exit.
</step3_missing_reports>

### Step 4: Scope by Repo

<step4_scope_by_repo>
[P1] Compare current working directory against `repo_path` values in `.sessions/` file frontmatter.
[P1] Normalize both paths to forward slashes.
[P1] Filter to files whose `repo_path` matches current directory exactly.

IF no match found:
  THEN fall back to scanning all files in `.sessions/`.
  THEN pick most recent file (timestamp/mmtime logic).
  THEN display warning: "No session reports found for this workspace. Showing the most recent report from another workspace."
</step4_scope_by_repo>

### Step 5: Find Most Recent File

<step5_find_recent>
[P1] Parse each filename for timestamp (`session-YYYYMMDD-HHmmss.md`).
IF timestamp parses: compare by timestamp.
IF timestamp does NOT parse: fall back to file modification time.
[P0] Pick overall most recent file by whichever method applies.
</step5_find_recent>

### Step 6: Read and Validate File

<step6_read_validate>
IF file empty OR invalid YAML frontmatter:
  THEN skip it, try next most recent file.
IF no valid file remains:
  THEN display: "No valid session report found. Run sas-endsession first."
  THEN exit.
[P0] Ignore frontmatter fields beyond `session_date` and `repo_path`.
</step6_read_validate>

### Step 7: Extract Content

<step7_extract_content>
[P0] Extract content under 3 section headers only:
  1. `## What Was Done`
  2. `## Where the Session Left Off`
  3. `## Where to Pick Up Next`
[P0] Ignore content outside these sections.
IF any section missing: report which ones are absent.
IF `## Where to Pick Up Next` missing: skip todo list creation (Step 11).
</step7_extract_content>

### Step 8: Validate Repo Path

<step8_validate_repo>
[P0] Compare `repo_path` from frontmatter with current working directory (normalize both to forward slashes).
IF mismatch (current directory is not `repo_path`):
  THEN warn user, ask if they want to proceed anyway.
</step8_validate_repo>

### Step 9: Check Session Age

<step9_check_age>
[P1] Normalize `session_date` to UTC before comparing.
IF `session_date` is in future: skip age check, proceed normally.
IF `session_date` cannot be parsed: skip age check, note: "Session date is invalid — age cannot be determined."
IF `session_date` > 168 hours (7 days) in past:
  THEN display non-blocking warning: "This session is {X} days old. Context may be outdated."
</step9_check_age>

### Step 10: Display Summary

<step10_display_summary>
[P0] Display:
  1. What was done
  2. Where the session left off
  3. Where to pick up next
</step10_display_summary>

### Step 11: Adopt Todo List

<step11_adopt_todos>
IF todo list already exists:
  THEN merge "Where to Pick Up Next" items into it.
  THEN deduplicate by exact string match (case-insensitive, trimmed whitespace).
IF no todo list exists:
  THEN create one from section's bullet points.
IF section is empty, contains only non-actionable content (placeholders like "Nothing to pick up — no further action needed.", "Nothing specific", "TBD"), or is missing:
  THEN skip todo list creation.
  THEN ask user what they'd like to work on.
</step11_adopt_todos>

### Step 12: Confirm Readiness

<step12_confirm_ready>
[P2] State that context is loaded and ready to continue.
</step12_confirm_ready>
