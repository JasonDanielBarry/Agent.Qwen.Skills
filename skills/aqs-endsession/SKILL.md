---
name: aqs-endsession
description: Save a lightweight session handoff note so the next session can pick up where this one left off. Use when ending work, wrapping up, saving progress, logging work, or creating a handoff.
---

# aqs-endsession

This skill enables seamless continuity between Qwen Code sessions by capturing a concise, structured summary of what was accomplished, where work concluded, and what should be tackled next. It eliminates context loss when sessions end, so the next session (or another agent) can resume immediately without re-reading conversation history or re-discovering the state of the codebase.

**Note:** This skill writes the session report directly without asking for user confirmation beforehand. The agent drafts the summary from conversation context and saves it immediately. After writing, the agent shows the user the file path and a brief preview, and can apply adjustments if requested.

## Instructions

1. **Determine the workspace root:**
   - If the current directory contains `.git` (or has one in a parent), use that directory as the workspace root.
   - Otherwise, use the current directory as the workspace root.
   - Ensure `.sessions/` exists at the workspace root. Create it if needed.

2. **Draft and write the report** to `.sessions/session-YYYYMMDD-HHmmss.md`:
   - Review what was discussed and accomplished in the current session. Do not scan the filesystem or run git commands — conversation context is sufficient.
   - Draft content for all 3 required sections, using **bullet points** for each item:
     - `## What Was Done`
     - `## Where the Session Left Off`
     - `## Where to Pick Up Next` — write actionable, specific tasks (not vague goals like "continue work").
   - For trivial sessions with no substantive output, use brief placeholders:
     - "Nothing completed this session."
     - "No open items — session was exploratory or informational."
     - "Nothing to pick up — no further action needed."
   - Generate the filename using the current UTC timestamp.
   - If a file with the generated name already exists, append a sequence number: `session-YYYYMMDD-HHmmss-2.md`, `session-YYYYMMDD-HHmmss-3.md`, etc.
   - Include YAML frontmatter:
     ```yaml
     ---
     session_date: <current UTC timestamp in ISO 8601 format, e.g. 2026-04-09T14:30:00Z>
     repo_path: D:/path/to/repo
     ---
     ```
   - Use forward slashes in `repo_path` regardless of OS.
   - Include all 3 required sections with content. Each section must have at least one bullet point or a short placeholder note.
   - Write the file directly — do not ask the user for confirmation before writing.

3. **Confirm the save:**
   - Show the user the file path and a brief preview of what was saved.
   - Ask if adjustments are needed. If the user requests changes, update the file accordingly.
