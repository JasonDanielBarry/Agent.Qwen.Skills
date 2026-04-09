# Implementation Plan: aqs-endsession & aqs-reattach Skills

## Overview

Two lightweight skills for session handoff between separate Qwen Code interactions:

- **aqs-endsession**: Writes a brief note of what was done, where the session stopped, and where to pick up
- **aqs-reattach**: Reads the latest note so the agent can continue from where the last session left off

**Design principle**: Lite handoff only. Not full context restoration.

---

## 1. Architecture

### 1.1 Storage

Session reports live in `.sessions/` at the **workspace root**.

**Workspace root** is determined as follows:
1. If the current working directory contains a `.git` directory (or has one in a parent), use that directory as the workspace root.
2. Otherwise, use the current working directory.

```
<workspace-root>/
└── .sessions/
    └── session-YYYYMMDD-HHmmss.md
```

**Filename collision**: If a file with the generated name already exists, append a sequence number: `session-YYYYMMDD-HHmmss-2.md`, `session-YYYYMMDD-HHmmss-3.md`, etc.

### 1.2 Report Format

Plain Markdown. Minimal YAML frontmatter — only what's needed for basic validation.

```markdown
---
session_date: 2026-04-09T14:30:00Z
repo_path: D:/path/to/repo
---

## What Was Done
- Brief summary of work completed

## Where the Session Left Off
- Where things stand now

## Where to Pick Up Next
- What to do next
```

**Path convention**: Forward slashes (`/`) in `repo_path` regardless of OS.

### 1.3 Optional Frontmatter Fields

These may be added later but are **not** in v1:
- `current_branch`, `user`, `tags` — useful for team workflows but not needed for basic handoff

**v1 behavior**: Ignore any frontmatter fields beyond `session_date` and `repo_path`.

---

## 2. Skill Specifications

### 2.1 aqs-endsession

**Purpose**: Save a session handoff note before ending work.

**Trigger**: `/skills aqs-endsession` or prompts like "end session", "save session", "wrap up".

**Steps**:

1. **Draft a summary from the conversation** — review what was discussed and accomplished in the current session. Do not scan the filesystem or run git commands. The conversation context is sufficient.

2. **Always ask the user to confirm or adjust the draft** — present the 3 sections to the user and ask: "Does this capture what was done, where things stand, and where to pick up next?" Accept adjustments before writing.

3. **Write the report** to `.sessions/session-YYYYMMDD-HHmmss.md`:
   - Create `.sessions/` if it doesn't exist
   - Use the 3 required sections: `## What Was Done`, `## Where the Session Left Off`, `## Where to Pick Up Next`
   - Each section must have at least one bullet point or a short note (e.g., "Nothing completed this session")

4. **Confirm** — show the user the file path and a brief preview of what was saved. Ask if they want to adjust anything.

---

### 2.2 aqs-reattach

**Purpose**: Load the latest session handoff note and pick up from where the last session stopped.

**Trigger**: `/skills aqs-reattach` or prompts like "reattach", "continue from last session", "restore session".

**Steps**:

1. **Scope by repo** — compare the current working directory against `repo_path` values in `.sessions/` file frontmatter (normalize both to forward slashes). Filter to only files whose `repo_path` matches the current directory or a parent of it. If no match is found, fall back to scanning all files and display a warning: "No session reports found for this workspace. Showing the most recent report from another workspace."

2. **Find the latest report** — scan `.sessions/` for `session-*.md` files (filtered per step 1). Parse each filename for its timestamp. For files where the timestamp parses, compare by timestamp. For files where it doesn't parse, fall back to file modification time. Pick the overall most recent file by whichever method applies.

3. **If no report found** — if `.sessions/` doesn't exist, tell the user: "No `.sessions/` directory found. Run aqs-endsession first to save your session state." If `.sessions/` exists but contains no `session-*.md` files, tell the user: "`.sessions/` exists but no session reports found. Run aqs-endsession first to save your session state."

4. **Read the report** and validate its content:
   - If the file is empty or has invalid YAML frontmatter, skip it and try the next most recent file. If no valid file remains, tell the user: "No valid session report found. Run aqs-endsession first."
   - Extract content under each of the 3 section headers (`## What Was Done`, `## Where the Session Left Off`, `## Where to Pick Up Next`). Ignore any content outside these sections.
   - If any of the 3 sections are missing, report which ones are absent. Continue with available sections. If `## Where to Pick Up Next` is missing, skip todo list creation (see step 7).

5. **Validate the repo path** — compare `repo_path` from frontmatter with the current working directory (normalize both to forward slashes):
   - **Match or subdirectory**: proceed with a note: "Note: Current directory is a subdirectory of the session's repo. Session context applies to the parent repo."
   - **Mismatch**: warn the user and ask if they want to proceed anyway

6. **Check session age** — normalize `session_date` to UTC before comparing:
   - If `session_date` is in the future, skip the age check and proceed normally.
   - If `session_date` cannot be parsed, skip the age check and proceed with a note: "Session date is invalid — age cannot be determined."
   - If `session_date` is strictly greater than 168 hours (7 days) in the past, display a non-blocking warning: "This session is {X} days old. Context may be outdated."

7. **Restore context** — display a concise summary:
   - What was done
   - Where the session left off
   - Where to pick up next

   **Adopt the "Where to Pick Up Next" section as the active task list for this session.** If a todo list already exists, merge the "Where to Pick Up Next" items into it (deduplicating by content). If no todo list exists, create one from the section's bullet points. If the section is empty, contains only non-actionable content (e.g., "Nothing specific," "TBD"), or is missing, skip todo list creation and ask the user what they'd like to work on.

8. **Confirm readiness** — briefly state that context is loaded and you're ready to continue.

---

## 3. SKILL.md Files

### 3.1 aqs-endsession

**Folder**: `aqs-endsession/SKILL.md`

```yaml
---
name: aqs-endsession
description: Save a lightweight session handoff note so the next session can pick up where this one left off. Use when ending work, wrapping up, saving progress, logging work, or creating a handoff.
---
```

**Instructions**:

1. Determine the workspace root: if the current directory contains `.git` (or has one in a parent), use that; otherwise, use the current directory. Ensure `.sessions/` exists there. Create it if needed.
2. Draft a summary from the conversation — what was done, where things stopped, what to do next. Do not scan the filesystem or run git commands.
3. Always ask the user to confirm or adjust the draft before writing. Present all 3 sections: "Does this capture what was done, where things stand, and where to pick up next?" Accept adjustments.
4. Write `.sessions/session-YYYYMMDD-HHmmss.md` with:
   - YAML frontmatter: `session_date` (ISO 8601, UTC), `repo_path` (forward slashes)
   - `## What Was Done`
   - `## Where the Session Left Off`
   - `## Where to Pick Up Next`
   - If a file with the generated name already exists, append a sequence number: `session-YYYYMMDD-HHmmss-2.md`, etc.
5. Each section must have content. If the agent's draft is empty, ask the user to fill it in.
6. Add `.sessions/` to `.gitignore` if it isn't already.
7. Confirm the save and show the file path. Ask if adjustments are needed.

---

### 3.2 aqs-reattach

**Folder**: `aqs-reattach/SKILL.md`

```yaml
---
name: aqs-reattach
description: Read the latest session handoff note and pick up where the previous session left off. Use when resuming work, continuing a session, restoring context, or asking what you were working on.
---
```

**Instructions**:

1. Determine the workspace root: if the current directory contains `.git` (or has one in a parent), use that; otherwise, use the current directory.
2. Scope by repo: compare the current working directory against `repo_path` values in `.sessions/` file frontmatter (normalize to forward slashes). Filter to files whose `repo_path` matches the current directory or a parent. If no match, fall back to all files with warning: "No session reports for this workspace. Showing most recent from another workspace."
3. Find the most recent `session-*.md` in `.sessions/` (filtered per step 2). Parse each filename for its timestamp. For files where the timestamp parses, compare by timestamp. For files where it doesn't parse, fall back to file modification time. Pick the overall most recent file.
4. If `.sessions/` doesn't exist: "No `.sessions/` directory found. Run aqs-endsession first." If it exists but is empty: "`.sessions/` exists but no session reports found. Run aqs-endsession first."
5. Read the selected file. If it's empty or has invalid YAML, skip it and try the next most recent file. If no valid file remains: "No valid session report found. Run aqs-endsession first."
6. Extract content under each of the 3 section headers. Ignore content outside these sections. If any section is missing, report it. If `## Where to Pick Up Next` is missing, skip todo creation (see step 9).
7. Ignore any frontmatter fields beyond `session_date` and `repo_path`.
8. Compare `repo_path` from frontmatter with current working directory (normalize to forward slashes):
   - Match or subdirectory: proceed with note: "Current directory is a subdirectory of the session's repo. Session context applies to the parent repo."
   - Mismatch: warn user, ask to confirm before proceeding.
9. Normalize `session_date` to UTC. If it's in the future, skip age check. If unparseable, skip with note: "Session date is invalid — age cannot be determined." If strictly greater than 168 hours old, warn: "This session is {X} days old. Context may be outdated."
10. Display the summary: what was done, where it left off, where to pick up. If a todo list already exists, merge the "Where to Pick Up Next" items into it (deduplicating by content). If no todo list exists, create one from the bullet points. If the section is empty, missing, or non-actionable, ask the user what they'd like to work on.
11. Confirm you have context and are ready to continue.

---

## 4. Edge Cases

| Scenario | Handling |
|---|---|
| No `.sessions/` directory | `endsession` creates it; `reattach` reports "No `.sessions/` directory found" and exits |
| `.sessions/` exists but empty | `reattach` reports "`.sessions/` exists but no session reports found" and exits |
| No reports exist | `reattach` tells user to run `endsession` first |
| Multiple reports | `reattach` scopes by workspace first, then picks most recent by filename timestamp; per-file mtime fallback |
| Cross-workspace fallback | `reattach` finds no matching `repo_path`, falls back to most recent file from another workspace with warning |
| Filename collision (same-second writes) | `endsession` appends sequence number: `-2`, `-3`, etc. |
| File empty or invalid YAML | `reattach` skips it, tries next most recent |
| Missing sections in report | `reattach` reports which are missing; skips todo creation if "Pick Up Next" absent |
| Repo path mismatch | `reattach` warns and asks for confirmation |
| Subdirectory of saved repo | `reattach` proceeds with informational note |
| Session older than 7 days | `reattach` displays non-blocking warning (strictly > 168 hours) |
| Future-dated session | `reattach` skips age check, proceeds normally |
| Invalid/unparseable `session_date` | `reattach` skips age check with note, proceeds |
| Extra frontmatter fields | `reattach` ignores them (v1 only uses `session_date` and `repo_path`) |
| Empty or non-actionable "Pick Up Next" | `reattach` skips todo creation, asks user for direction |
| Existing todo list present | `reattach` merges "Pick Up Next" items into existing todos (deduplicating by content) |
| Agent crashes during write | User just runs `endsession` again; no temp file cleanup needed |

---

## 5. Testing

### Core Tests

1. **Endsession creates a report** — do work, run endsession, verify the agent drafts a summary, asks for confirmation, then writes file with 3 sections and correct frontmatter.
2. **Reattach loads the report** — run reattach, verify agent displays summary and adopts "Where to Pick Up Next" as active tasks.
3. **Most recent report wins** — run endsession twice, run reattach, verify the newer report is loaded.
4. **No report found** — run reattach on a fresh repo, verify appropriate message.
5. **Repo path mismatch** — create a report with a different `repo_path`, run reattach, verify warning and confirmation prompt.

### Additional Stress Tests

6. **Filename collision** — run endsession twice within the same second, verify both files exist with unique names (sequence numbers).
7. **Corrupted file recovery** — place an empty/malformed session file alongside valid ones, verify reattach skips it and loads the valid file.
8. **Missing sections** — create a report missing one section, verify reattach reports the gap and continues with available content.
9. **Missing "Pick Up Next"** — create a report without `## Where to Pick Up Next`, verify reattach skips todo creation and asks user for direction.
10. **Future-dated session** — create a report with a future `session_date`, verify reattach proceeds without age warning.
11. **Invalid session date** — create a report with `session_date: not-a-date`, verify reattach skips age check with note.
12. **Extra frontmatter fields** — create a report with `user`, `branch`, `tags`, verify reattach ignores them.
13. **Non-actionable "Pick Up Next"** — create a report with `- TBD` as the only item, verify reattach asks user for direction.
14. **Subdirectory reattach** — run reattach from a subdirectory of the saved `repo_path`, verify informational note is displayed.
15. **7-day boundary** — create a report exactly 7 days old (no warning) and one at 7 days + 1 minute (warning), verify threshold behavior.
16. **Cross-workspace fallback** — create a report with a different `repo_path` in the same `.sessions/`, verify reattach loads it with a cross-workspace warning.
17. **Todo merge** — start a session with an existing todo list, run reattach, verify items are merged (not replaced) and duplicates are removed.
18. **User confirmation flow** — run endsession with minimal conversation context, verify agent always drafts a summary and asks for confirmation before writing.

Full stress test plan: [aqs-session-management-stress-test.md](./aqs-session-management-stress-test.md)

---

## 6. Future Enhancements

- Atomic write (temp file + rename) for crash safety
- Auto-cleanup of reports older than N days
- Additional frontmatter: `branch`, `user`, `tags`
- Filesystem/git scanning for richer context capture
- Named sessions
- Cross-repo session storage (`~/.qwen/sessions/`)
- Quick reattach mode (skip warnings)
- Multi-user session isolation
- Session age warning with days/months/years display formatting (currently: days only)

---

## 7. Related Documentation

- [Agent Skills Research.md](../Agent%20Skills%20Research.md) — Agent-agnostic Skill design principles
- [Qwen Code Implementation Notes.md](../Qwen%20Code%20Implementation%20Notes.md) — Qwen-specific Skill format and discovery
