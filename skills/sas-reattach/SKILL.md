<!-- compiled from: skills/sas-reattach/SKILL.human.md | 2026-04-13T10:06:06Z -->

---
name: sas-reattach
description: Read the latest session handoff note and pick up where the previous session left off. Use when resuming work, continuing a session, restoring context, or asking what you were working on.
---

<Purpose>
[P2] Restores working context when resuming a Qwen Code session by reading the most recent handoff note created by sas-endsession.
[P2] Surfaces what was accomplished, where work stopped, and what comes next.
[P0] Must be invoked from a repository root (a directory containing .git).
[P0] Will not work from subdirectories.
</Purpose>

<Scope>
[P2] Target: Session handoff notes in .sessions/ directory. Reads session-*.md files, extracts What Was Done / Where the Session Left Off / Where to Pick Up Next sections, creates or merges todo lists.
[P2] Excluded: Session notes from other repositories, non-session files in .sessions/, files without valid YAML frontmatter, files missing required section headers.
</Scope>

<Inputs>
[P1] Current working directory (must contain .git).
[P1] .sessions/session-*.md files with YAML frontmatter containing session_date and repo_path fields.
[P1] Session file content under three section headers: What Was Done, Where the Session Left Off, Where to Pick Up Next.
</Inputs>

<Outputs>
[P1] Summary displayed to user: What was done, Where the session left off, Where to pick up next.
[P1] Active todo list created or merged from Where to Pick Up Next section.
[P2] Readiness confirmation message.
[P1] Warnings (conditional): repo path mismatch, session age > 7 days, invalid session date, no matching repo_path (fallback to most recent from another workspace).
</Outputs>

<Constraints>
[P0] Must be invoked from a repository root (a directory containing .git). Will not work from subdirectories.
[P0] The .sessions/ directory and its session-*.md files MUST be tracked in git.
[P0] Never add .sessions/ to .gitignore. These files are shared team knowledge, not local-only artifacts.
[P0] When committing changes, include .sessions/ files alongside other changes as part of the same commit.
[P0] Must not process session files from other repositories without explicit user confirmation.
</Constraints>

<Invariants>
[P0] Session files are scoped by repo_path in frontmatter. Files from other repos are never silently used without a warning.
[P0] Only content under the three section headers (What Was Done, Where the Session Left Off, Where to Pick Up Next) is extracted. Content outside these sections is ignored.
[P0] Todo list deduplication uses exact string match (case-insensitive, trimmed whitespace).
</Invariants>

<Failure Modes>
[P1] Current directory lacks .git: Display error and exit. "sas-reattach must be run from a repository root."
[P1] .sessions/ directory does not exist: Display error. "Run sas-endsession first."
[P1] .sessions/ exists but contains no session-*.md files: Display error. "Run sas-endsession first."
[P1] No valid session report found (all files empty or invalid): Display error. "Run sas-endsession first."
[P1] Session date is > 168 hours (7 days) old: Display non-blocking warning. "Context may be outdated."
[P1] Session date cannot be parsed: Proceed with note. "Age cannot be determined."
[P1] Repo path mismatch: Warn user. "Report belongs to a different workspace." Ask if user wants to proceed anyway.
[P1] No matching repo_path in .sessions/: Fall back to most recent file from another workspace. Display warning.
</Failure Modes>

<Validation Strategy>
[P0] Verify current directory contains .git before proceeding.
[P0] Verify .sessions/ directory exists and contains at least one session-*.md file.
[P0] Verify session file has valid YAML frontmatter with session_date and repo_path fields.
[P0] Verify session file contains all three required section headers: What Was Done, Where the Session Left Off, Where to Pick Up Next.
[P0] Verify repo_path from frontmatter matches current working directory (normalized to forward slashes).
[P1] Verify session_date parses as a valid date and is not > 168 hours in the past.
</Validation Strategy>

<Relationships>
[P1] Depends on: sas-endsession skill (creates the session handoff notes this skill reads).
[P1] Depends on: .sessions/ directory convention (shared with sas-endsession).
[P2] Produces: Todo list items merged into agent's active task list.
</Relationships>

<Guarantees>
[P0] Will never silently use a session file from a different repository without warning.
[P0] Will always display the most recent relevant session data available.
[P0] Will not create a todo list if the Where to Pick Up Next section is empty, missing, or contains only non-actionable placeholders.
</Guarantees>

<Invocation Conditions>
[P1] Trigger: User explicitly requests to resume work, continue a session, restore context, or asks what they were working on.
[P1] Trigger: User invokes the skill via /skills sas-reattach or relevant natural language prompt matching the description field.
[P0] Must be invoked from a repository root (a directory containing .git). Will not work from subdirectories.
</Invocation Conditions>

<Forbidden Usage>
[P0] Must not invoke from a subdirectory lacking .git.
[P0] Must not add .sessions/ to .gitignore.
[P0] Must not silently use session files from other repositories without warning the user.
[P0] Must not extract content outside the three required section headers (What Was Done, Where the Session Left Off, Where to Pick Up Next).
[P0] Must not create a todo list from empty, missing, or non-actionable Where to Pick Up Next sections.
</Forbidden Usage>

<Phase Separation>
[P2] Skill type: Procedural skill (tells an agent how to execute a task).
[P2] Invocation: Manual only (intentional user action required).
[P2] Dependencies: sas-endsession skill (creates session notes), .sessions/ directory convention.
[P2] Standalone: No external tools or libraries required beyond the agent itself.
</Phase Separation>

<Instructions>
[P1] 1. Validate the current directory.
   - IF current directory does not contain .git THEN display error and exit: "sas-reattach must be run from a repository root (a directory containing .git). You are currently in a subdirectory. Navigate to the repo root and try again."
   - IF .git is present THEN proceed.

[P1] 2. Determine the workspace root. Use the current directory as the workspace root (it contains .git).

[P1] 3. Handle missing reports (early exit).
   - IF .sessions/ does not exist THEN display: "No .sessions/ directory found. Run sas-endsession first to save your session state."
   - IF .sessions/ exists but contains no session-*.md files THEN display: ".sessions/ exists but no session reports found. Run sas-endsession first to save your session state."

[P1] 4. Scope by repo.
   - Compare the current working directory against repo_path values in .sessions/ file frontmatter.
   - Normalize both paths to forward slashes.
   - Filter to files whose repo_path matches the current directory exactly.
   - IF no match is found THEN fall back to scanning all files in .sessions/. Pick the most recent file. Display warning: "No session reports found for this workspace. Showing the most recent report from another workspace."

[P1] 5. Find the most recent session-*.md file in .sessions/ (filtered per step 4).
   - Parse each filename for its timestamp (session-YYYYMMDD-HHmmss.md).
   - IF timestamp parses THEN compare by timestamp.
   - IF timestamp does not parse THEN fall back to file modification time.
   - Pick the overall most recent file.

[P1] 6. Read and validate the file.
   - IF file is empty or has invalid YAML frontmatter THEN skip it and try the next most recent file.
   - IF no valid file remains THEN display: "No valid session report found. Run sas-endsession first."
   - Ignore any frontmatter fields beyond session_date and repo_path.

[P1] 7. Extract content under the 3 section headers.
   - Required sections: What Was Done, Where the Session Left Off, Where to Pick Up Next.
   - Ignore any content outside these sections.
   - IF any section is missing THEN report which ones are absent.
   - IF Where to Pick Up Next is missing THEN skip todo list creation (see step 11).

[P1] 8. Validate the repo path.
   - Compare repo_path from frontmatter with the current working directory (normalize both to forward slashes).
   - IF mismatch (current directory is not repo_path) THEN warn the user and ask if they want to proceed anyway. This indicates the report belongs to a different workspace entirely.

[P1] 9. Check session age. Normalize session_date to UTC before comparing.
   - IF session_date is in the future THEN skip the age check and proceed normally.
   - IF session_date cannot be parsed THEN skip the age check and proceed with note: "Session date is invalid — age cannot be determined."
   - IF session_date > 168 hours (7 days) in the past THEN display non-blocking warning: "This session is {X} days old. Context may be outdated."

[P1] 10. Display the summary.
   - What was done
   - Where the session left off
   - Where to pick up next

[P1] 11. Adopt the Where to Pick Up Next section as the active task list.
   - IF a todo list already exists THEN merge the Where to Pick Up Next items into it. Deduplicate by exact string match (case-insensitive, trimmed whitespace).
   - IF no todo list exists THEN create one from the section's bullet points.
   - IF the section is empty, contains only non-actionable content (placeholders such as "Nothing to pick up — no further action needed.", "Nothing specific,", "TBD"), or is missing THEN skip todo list creation and ask the user what they'd like to work on.

[P1] 12. Confirm readiness. Briefly state that context is loaded and you're ready to continue.
</Instructions>
