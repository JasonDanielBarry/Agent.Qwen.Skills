---
name: aqs-endsession
description: Save a lightweight session handoff note so the next session can pick up where this one left off. Use when ending work, wrapping up, saving progress, logging work, or creating a handoff.
---

## Skill Goal

This skill enables seamless continuity between Qwen Code sessions by capturing a concise, structured summary of what was accomplished, where work concluded, and what should be tackled next. It eliminates context loss when sessions end, so the next session (or another agent) can resume immediately without re-reading conversation history or re-discovering the state of the codebase.

## Instructions

1. **Determine the workspace root:**
   - If the current directory contains `.git` (or has one in a parent), use that directory as the workspace root.
   - Otherwise, use the current directory as the workspace root.
   - Ensure `.sessions/` exists at the workspace root. Create it if needed.

2. **Draft a summary from the conversation:**
   - Review what was discussed and accomplished in the current session.
   - Do not scan the filesystem or run git commands. The conversation context is sufficient.
   - Draft content for all 3 required sections:
     - `## What Was Done`
     - `## Where the Session Left Off`
     - `## Where to Pick Up Next`

3. **Always ask the user to confirm or adjust the draft:**
   - Present all 3 sections to the user.
   - Ask: "Does this capture what was done, where things stand, and where to pick up next?"
   - Accept adjustments before writing.
   - If the agent's draft is empty for any section, ask the user to fill it in.

4. **Write the report** to `.sessions/session-YYYYMMDD-HHmmss.md`:
   - Generate the filename using the current UTC timestamp.
   - If a file with the generated name already exists, append a sequence number: `session-YYYYMMDD-HHmmss-2.md`, `session-YYYYMMDD-HHmmss-3.md`, etc.
   - Include YAML frontmatter:
     ```yaml
     ---
     session_date: 2026-04-09T14:30:00Z
     repo_path: D:/path/to/repo
     ---
     ```
   - Use forward slashes in `repo_path` regardless of OS.
   - Include all 3 required sections with content. Each section must have at least one bullet point or a short note (e.g., "Nothing completed this session").

5. **Confirm the save:**
   - Show the user the file path.
   - Show a brief preview of what was saved.
   - Ask if adjustments are needed.
