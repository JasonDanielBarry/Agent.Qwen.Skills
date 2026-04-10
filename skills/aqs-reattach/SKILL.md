---
name: aqs-reattach
description: Read the latest session handoff note and pick up where the previous session left off. Use when resuming work, continuing a session, restoring context, or asking what you were working on.
---

## Skill Goal

This skill restores working context instantly when resuming a Qwen Code session by reading the most recent handoff note created by `aqs-endsession`. It surfaces what was accomplished, where work stopped, and what comes next — so the agent can pick up immediately without requiring the user to re-explain the situation or re-trace prior steps.

## Instructions

1. **Determine the workspace root:**
   - If the current directory contains `.git` (or has one in a parent), use that directory as the workspace root.
   - Otherwise, use the current directory as the workspace root.

2. **Handle missing reports (early exit):**
   - If `.sessions/` doesn't exist: "No `.sessions/` directory found. Run aqs-endsession first to save your session state."
   - If `.sessions/` exists but contains no `session-*.md` files: "`.sessions/` exists but no session reports found. Run aqs-endsession first to save your session state."

3. **Scope by repo:**
   - Compare the current working directory against `repo_path` values in `.sessions/` file frontmatter.
   - Normalize both paths to forward slashes.
   - Filter to files whose `repo_path` matches the current directory **or a parent of it** (i.e., the current directory is the same as, or a subdirectory of, `repo_path`).
   - If no match is found, fall back to scanning all files in `.sessions/`. Pick the most recent file using the same timestamp/mtime logic from step 4, and display a warning: "No session reports found for this workspace. Showing the most recent report from another workspace."

4. **Find the most recent `session-*.md` file in `.sessions/`** (filtered per step 3):
   - Parse each filename for its timestamp (`session-YYYYMMDD-HHmmss.md`).
   - For files where the timestamp parses, compare by timestamp.
   - For files where it doesn't parse, fall back to file modification time.
   - Pick the overall most recent file by whichever method applies.

5. **Read and validate the file:**
   - If the file is empty or has invalid YAML frontmatter, skip it and try the next most recent file.
   - If no valid file remains: "No valid session report found. Run aqs-endsession first."
   - Ignore any frontmatter fields beyond `session_date` and `repo_path`.

6. **Extract content under the 3 section headers:**
   - `## What Was Done`
   - `## Where the Session Left Off`
   - `## Where to Pick Up Next`
   - Ignore any content outside these sections.
   - If any section is missing, report which ones are absent.
   - If `## Where to Pick Up Next` is missing, skip todo list creation (see step 10).

7. **Validate the repo path:**
   - Compare `repo_path` from frontmatter with the current working directory (normalize both to forward slashes).
   - **Mismatch** (current directory is neither `repo_path` nor a subdirectory): warn the user and ask if they want to proceed anyway. This indicates the report belongs to a different workspace entirely.

8. **Check session age:**
   - Normalize `session_date` to UTC before comparing.
   - If `session_date` is in the future, skip the age check and proceed normally.
   - If `session_date` cannot be parsed, skip the age check and proceed with a note: "Session date is invalid — age cannot be determined."
   - If `session_date` is strictly greater than 168 hours (7 days) in the past, display a non-blocking warning: "This session is {X} days old. Context may be outdated."

9. **Display the summary:**
   - What was done
   - Where the session left off
   - Where to pick up next

10. **Adopt the "Where to Pick Up Next" section as the active task list:**
    - If a todo list already exists, merge the "Where to Pick Up Next" items into it. Deduplicate by **exact string match** (case-insensitive, trimmed whitespace).
    - If no todo list exists, create one from the section's bullet points.
    - If the section is empty, contains only non-actionable content (e.g., the placeholders from `aqs-endsession` such as "Nothing to pick up — no further action needed.", "Nothing specific," "TBD"), or is missing, skip todo list creation and ask the user what they'd like to work on.

11. **Confirm readiness:**
    - Briefly state that context is loaded and you're ready to continue.
