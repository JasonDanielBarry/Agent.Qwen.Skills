---
name: sas-reattach
description: Read the latest session handoff note and pick up where the previous session left off. Use when resuming work, continuing a session, restoring context, or asking what you were working on.
---

# sas-reattach

This skill restores working context instantly when resuming a Qwen Code session by reading the most recent handoff note created by `sas-endsession`. It surfaces what was accomplished, where work stopped, and what comes next — so the agent can pick up immediately without requiring the user to re-explain the situation or re-trace prior steps.

**Note:** This skill must be invoked from a **repository root** (a directory containing `.git`). It will not work from subdirectories.

## Git Rules — `.sessions/` Must Be Tracked

- The `.sessions/` directory and its `session-*.md` files **MUST be tracked in git**.
- **Never** add `.sessions/` to `.gitignore`. These files are shared team knowledge, not local-only artifacts.
- When committing changes, include `.sessions/` files alongside other changes as part of the same commit.

## Instructions

1. **Validate the current directory:**
   - If the current directory does **not** contain `.git`, display an error and exit: "sas-reattach must be run from a repository root (a directory containing `.git`). You are currently in a subdirectory. Navigate to the repo root and try again."
   - If `.git` is present, proceed.

2. **Determine the workspace root:**
   - Use the current directory as the workspace root (it contains `.git`).

3. **Handle missing reports (early exit):**
   - If `.sessions/` doesn't exist: "No `.sessions/` directory found. Run sas-endsession first to save your session state."
   - If `.sessions/` exists but contains no `session-*.md` files: "`.sessions/` exists but no session reports found. Run sas-endsession first to save your session state."

4. **Scope by repo:**
   - Compare the current working directory against `repo_path` values in `.sessions/` file frontmatter.
   - Normalize both paths to forward slashes.
   - Filter to files whose `repo_path` matches the current directory **exactly**.
   - If no match is found, fall back to scanning all files in `.sessions/`. Pick the most recent file using the same timestamp/mtime logic from step 5, and display a warning: "No session reports found for this workspace. Showing the most recent report from another workspace."

5. **Find the most recent `session-*.md` file in `.sessions/`** (filtered per step 4):
   - Parse each filename for its timestamp (`session-YYYYMMDD-HHmmss.md`).
   - For files where the timestamp parses, compare by timestamp.
   - For files where it doesn't parse, fall back to file modification time.
   - Pick the overall most recent file by whichever method applies.

6. **Read and validate the file:**
   - If the file is empty or has invalid YAML frontmatter, skip it and try the next most recent file.
   - If no valid file remains: "No valid session report found. Run sas-endsession first."
   - Ignore any frontmatter fields beyond `session_date` and `repo_path`.

7. **Extract content under the 3 section headers:**
   - `## What Was Done`
   - `## Where the Session Left Off`
   - `## Where to Pick Up Next`
   - Ignore any content outside these sections.
   - If any section is missing, report which ones are absent.
   - If `## Where to Pick Up Next` is missing, skip todo list creation (see step 11).

8. **Validate the repo path:**
   - Compare `repo_path` from frontmatter with the current working directory (normalize both to forward slashes).
   - **Mismatch** (current directory is not `repo_path`): warn the user and ask if they want to proceed anyway. This indicates the report belongs to a different workspace entirely.

9. **Check session age:**
   - Normalize `session_date` to UTC before comparing.
   - If `session_date` is in the future, skip the age check and proceed normally.
   - If `session_date` cannot be parsed, skip the age check and proceed with a note: "Session date is invalid — age cannot be determined."
   - If `session_date` is strictly greater than 168 hours (7 days) in the past, display a non-blocking warning: "This session is {X} days old. Context may be outdated."

10. **Display the summary:**
    - What was done
    - Where the session left off
    - Where to pick up next

11. **Adopt the "Where to Pick Up Next" section as the active task list:**
    - If a todo list already exists, merge the "Where to Pick Up Next" items into it. Deduplicate by **exact string match** (case-insensitive, trimmed whitespace).
    - If no todo list exists, create one from the section's bullet points.
    - If the section is empty, contains only non-actionable content (e.g., the placeholders from `sas-endsession` such as "Nothing to pick up — no further action needed.", "Nothing specific," "TBD"), or is missing, skip todo list creation and ask the user what they'd like to work on.

12. **Confirm readiness:**
    - Briefly state that context is loaded and you're ready to continue.
