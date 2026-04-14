---
name: sas-reattach
description: Read the latest session handoff note and pick up where the previous session left off. Use when resuming work, continuing a session, restoring context, or asking what you were working on.
---

<purpose>
[P0] Restores working context when resuming a Gemini CLI session by reading the most recent handoff note from sas-endsession. Must be invoked from repository root (directory containing .git).
</purpose>

<scope>Target: .sessions/session-*.md files. Excluded: session notes from other repos, non-session files, files without valid YAML frontmatter.</scope>

<inputs>Current directory (must contain .git). .sessions/session-*.md files with YAML frontmatter (session_date, repo_path).</inputs>

<outputs>
[P0] Summary displayed (What Was Done, Where Left Off, Where to Pick Up Next). Todo list created/merged. Warnings if applicable (repo mismatch, session age, fallback).
</outputs>

<rules>
[P0] Must invoke from repository root (.git present). Will not work from subdirectories.
[P0] .sessions/ and session-*.md MUST be tracked in git. Never add .sessions/ to .gitignore.
[P0] Must not silently use session files from other repos without warning.
[P0] Only extract content under 3 section headers. Ignore everything else.
[P0] Todo deduplication: exact string match, case-insensitive, trimmed whitespace.
[P0] Must not create todo list from empty/missing/non-actionable "Where to Pick Up Next".
</rules>

<phase_separation>
1. Validate current directory: IF no .git → error "must be run from repository root" → exit.
2. Workspace root = current directory.
3. IF .sessions/ missing → error "Run sas-endsession first." IF no session-*.md files → same error.
4. Scope by repo: compare CWD vs repo_path in frontmatter (normalize forward slashes). IF no match → fallback to most recent file from any workspace, display warning.
5. Find most recent session-*.md: parse filename timestamp (session-YYYYMMDD-HHmmss.md). Compare by timestamp; fallback to mtime.
6. Read and validate: IF empty/invalid frontmatter → try next most recent. IF none valid → error "Run sas-endsession first."
7. Extract 3 sections: What Was Done, Where the Session Left Off, Where to Pick Up Next. Ignore content outside. Report absent sections.
8. Validate repo path: IF mismatch → warn user, ask to proceed.
9. Check session age: Normalize session_date to UTC. IF future → skip. IF unparseable → note "age cannot be determined." IF >168 hours (7 days) → warning "Context may be outdated."
10. Display summary: What was done, Where left off, Where to pick up next.
11. Adopt "Where to Pick Up Next" as active todo list:
    IF existing todo → merge items, deduplicate (case-insensitive, trimmed).
    IF no existing todo → create from bullet points.
    IF section empty/non-actionable (placeholders like "Nothing to pick up", "TBD") → skip, ask user what to work on.
12. Confirm readiness: "Context loaded, ready to continue."
</phase_separation>

