# Tier 2 — Functional Equivalence Benchmarks

**Phase:** 4, Step 6
**Date:** 14 April 2026
**Threshold:** 95%+ task equivalence (max 1 failure in 25-task suite)

---

## Overview

Tier 2 validates that a **compiled SKILL.md** is functionally equivalent to its **source SKILL.human.md**. Both documents are given to separate agent instances, the same benchmark task is executed against each, and outputs are graded for semantic equivalence.

**Semantic equivalence** means: same actions taken, same constraints obeyed, same invariants preserved, same output structure. NOT identical text.

---

## Test Procedure

### Execution Flow

```
┌─────────────────────────────────────────────────┐
│  Stage 6 complete → SKILL.md generated          │
│  Tier 1 structural check → PASS                 │
├─────────────────────────────────────────────────┤
│  TIER 2 — Functional Equivalence                │
│                                                 │
│  1. Grader agent loads both documents           │
│     (SKILL.human.md + SKILL.md)                 │
│  2. For each benchmark task:                    │
│     a. Spawn Source Agent → load SKILL.human.md │
│        → execute task → capture actions/output   │
│     b. Spawn Compiled Agent → load SKILL.md     │
│        → execute identical task → capture output │
│     c. Grade: compare both against rubric       │
│        → PASS / FAIL per criterion               │
│     d. Task passes if ALL criteria pass         │
│  3. Aggregate: compute pass rate                 │
│  4. Threshold check: >= 95% → Tier 2 PASS       │
│     < 95% → Tier 2 FAIL, show divergence report │
└─────────────────────────────────────────────────┘
```

### Grading Rubric

Each benchmark task defines **graded criteria** — a list of specific checks. For each check:
- **PASS** = both agents behaved equivalently (both obeyed the constraint, both took the action, etc.)
- **FAIL** = agents diverged (one obeyed, one didn't; one took an action the other skipped; etc.)

A task **passes** if ALL its graded criteria pass. A task **fails** if ANY criterion fails.

### Failure Report

When Tier 2 fails, the grader produces:
1. Which tasks failed
2. Which specific criteria failed per task
3. Source agent behavior vs compiled agent behavior (side-by-side)
4. Root cause hypothesis (which compilation stage likely caused the divergence)

---

## Benchmark Task Suite

Each skill has **5 benchmark tasks** covering 5 capability dimensions:

| Dimension | What it tests |
|-----------|---------------|
| **Happy Path** | Normal invocation — correct execution under standard conditions |
| **Edge Case** | Unusual input state — proper handling of boundary conditions |
| **Constraint Obedience** | P0 constraint — refusal of forbidden actions, invariant preservation |
| **Failure Mode** | Error scenario — correct response when things go wrong |
| **Multi-Step** | Full procedural sequence — complete step-by-step execution in order |

---

### Skill: sas-endsession

#### T1 — Happy Path: Normal session end
**Scenario:** User says "let's wrap up" after a productive session where features were implemented and bugs were fixed.
**Expected behavior:** Agent writes session report to `.sessions/session-YYYYMMDD-HHmmss.md` with 3 sections, YAML frontmatter, UTC timestamp, forward-slash repo_path.
**Graded criteria:**
- Report written to correct path (`.sessions/`)
- Filename matches `session-YYYYMMDD-HHmmss.md` pattern
- YAML frontmatter contains `session_date` (ISO 8601 UTC) and `repo_path` (forward slashes)
- Contains "What Was Done" section with bullet points about completed work
- Contains "Where the Session Left Off" section with current state
- Contains "Where to Pick Up Next" section with actionable next steps
- Does NOT ask user for permission before writing

#### T2 — Edge Case: Nothing completed
**Scenario:** User ends session immediately after starting — no substantive work was done.
**Expected behavior:** Agent writes report with placeholder text in all 3 sections.
**Graded criteria:**
- Report written successfully
- "What Was Done" contains placeholder (e.g., "Nothing completed this session.")
- "Where the Session Left Off" contains placeholder
- "Where to Pick Up Next" contains placeholder
- YAML frontmatter and filename still correct

#### T3 — Constraint Obedience: No confirmation prompt
**Scenario:** User invokes sas-endsession. Verify the skill does NOT ask for confirmation.
**Expected behavior:** Agent writes the report directly without asking "should I save this?" or "ready to end session?"
**Graded criteria:**
- No confirmation question asked before writing
- Report written directly
- User shown file path and preview after writing

#### T4 — Failure Mode: .sessions/ doesn't exist
**Scenario:** Workspace has no `.sessions/` directory yet.
**Expected behavior:** Agent creates `.sessions/` directory and writes the report.
**Graded criteria:**
- `.sessions/` directory created
- Report written inside new directory
- No error about missing directory

#### T5 — Multi-Step: Full end-to-end workflow
**Scenario:** Full session end — agent must: detect workspace root → review conversation context → draft report → write file → show preview.
**Expected behavior:** All steps execute in sequence, report is complete and correct.
**Graded criteria:**
- Workspace root detected via `.git`
- `.sessions/` exists (created if needed)
- Report drafted with conversation context
- File written with correct filename and frontmatter
- User shown file path and brief preview

---

### Skill: sas-git-commit-and-push

#### T1 — Happy Path: Standard commit and push
**Scenario:** User has modified 3 source files in a clean repo with a configured remote. Says "commit and push".
**Expected behavior:** Agent stages all, commits with conventional format, pushes to remote, working tree clean.
**Graded criteria:**
- `git add -A` executed
- Commit message follows `type(scope): description` format
- Commit body explains WHY not WHAT
- `git push` executed
- Working tree clean after execution
- Does NOT ask for permission before committing

#### T2 — Edge Case: No changes
**Scenario:** User says "commit and push" but working tree is already clean.
**Expected behavior:** Agent reports "working tree is already clean, nothing to do" and exits.
**Graded criteria:**
- Agent checks `git status` first
- Reports clean state to user
- No commit attempted
- No error thrown

#### T3 — Constraint Obedience: Never ask permission
**Scenario:** User says "commit and push". Agent must NOT ask "should I commit?" or "ready to push?"
**Expected behavior:** Agent stages, commits, and pushes without any permission prompts.
**Graded criteria:**
- No permission question asked at any point
- No draft commit message shown for approval
- Stage → commit → push executed directly

#### T4 — Failure Mode: Push rejected (no upstream)
**Scenario:** New branch with no upstream remote. `git push` fails.
**Expected behavior:** Agent detects no upstream, runs `git push --set-upstream origin <branch>`, reports success with remote URL.
**Graded criteria:**
- Initial `git push` attempted
- On failure, detects "no upstream" error
- Runs `git push --set-upstream origin <branch>`
- Reports result including remote URL
- Does NOT give up or ask user what to do

#### T5 — Multi-Step: Mixed doc + code changes
**Scenario:** User modified `src/auth.py` and `README.md`. Says "commit and push".
**Expected behavior:** Agent commits code and docs as separate atomic commits.
**Graded criteria:**
- Agent identifies both code and doc changes
- Creates separate commit for code changes (e.g., `fix(auth): ...`)
- Creates separate commit for doc changes (e.g., `docs: ...`)
- Both commits follow Conventional Commits format
- Both pushed to remote
- Working tree clean after

---

### Skill: sas-git-merge

#### T1 — Happy Path: Clean fast-forward merge
**Scenario:** User says "merge my feature branch". Current branch is `feature/x`, target `develop` is behind `feature/x` by 3 commits (fast-forward possible).
**Expected behavior:** Agent verifies repo, presents targets, user picks `develop`, switches, merges, reports success.
**Graded criteria:**
- Repo validated via `git rev-parse --show-toplevel`
- Branches discovered and presented as numbered list
- User asked to select target
- Switched to target branch (`develop`)
- Merge executed (fast-forward)
- Success reported with `git status` and `git log --oneline -n 3`
- Does NOT auto-resolve (no conflicts in this case, but rule is obeyed)

#### T2 — Edge Case: Detached HEAD
**Scenario:** User invokes merge while in detached HEAD state.
**Expected behavior:** Agent warns about detached HEAD, recommends checkout branch first.
**Graded criteria:**
- Agent detects detached HEAD via `git branch --show-current` returning empty
- Warns user about detached HEAD
- Recommends checking out a branch first
- Does NOT proceed with merge in detached HEAD without warning

#### T3 — Constraint Obedience: No auto-resolve conflicts
**Scenario:** Merge produces conflicts in `app/auth.py`. User has not specified resolution strategy.
**Expected behavior:** Agent lists conflicted files, presents 5 resolution options, waits for user decision. Does NOT auto-resolve.
**Graded criteria:**
- Lists conflicted files via `git diff --name-only --diff-filter=U`
- Presents resolution options (abort, inspect, resolve manually, accept theirs, accept ours)
- Waits for user decision
- Does NOT auto-resolve conflicts
- Does NOT pick a resolution on its own

#### T4 — Failure Mode: Dirty working tree
**Scenario:** User has uncommitted changes and says "merge my branch".
**Expected behavior:** Agent warns about dirty tree, offers stash or commit, waits for decision before proceeding.
**Graded criteria:**
- Detects dirty tree via `git status --porcelain`
- Warns user about uncommitted changes
- Offers stash (`git stash push -m "pre-merge stash"`) or commit
- Waits for user decision before proceeding with merge
- Does NOT silently discard changes

#### T5 — Multi-Step: Full merge with post-merge actions
**Scenario:** User merges `feature/x` into `develop`. Clean merge. Agent should execute full workflow.
**Expected behavior:** All 10 steps execute: repo check → fetch → pre-merge checks → branch context → discover targets → user selection → switch → merge → post-merge → offer push/cleanup.
**Graded criteria:**
- Step 1: Repo check passes
- Step 1.5: Fetch executed (or skipped if no remote)
- Step 2: Pre-merge state clean (or handled if not)
- Step 3: Source branch reported
- Step 4: Target branches discovered and presented
- Step 5: User selection confirmed
- Step 6: Switched to target branch, verified
- Step 7: Merge strategy presented (or default used)
- Step 8: Merge executed, success reported
- Step 10: Post-merge state shown, push offered, cleanup options presented

---

### Skill: sas-reattach

#### T1 — Happy Path: Normal reattach
**Scenario:** User invokes sas-reattach in a repo with a recent `.sessions/session-*.md` file matching the current repo_path.
**Expected behavior:** Agent reads session file, displays summary (What Was Done, Where Left Off, Where to Pick Up Next), creates todo list.
**Graded criteria:**
- Session file found matching current repo_path
- Summary displayed with all 3 sections
- Todo list created from "Where to Pick Up Next" bullet points
- Readiness confirmation shown

#### T2 — Edge Case: Session from different workspace
**Scenario:** `.sessions/` contains session files but none match the current repo_path.
**Expected behavior:** Agent falls back to most recent file from another workspace, displays warning.
**Graded criteria:**
- No matching repo_path found
- Warning displayed: "No session reports found for this workspace. Showing the most recent report from another workspace."
- Most recent file from any workspace loaded and displayed
- Does NOT silently use wrong-workspace session without warning

#### T3 — Constraint Obedience: Not from subdirectory
**Scenario:** User invokes sas-reattach from `src/components/` (no `.git` in current directory).
**Expected behavior:** Agent displays error and exits: "sas-reattach must be run from a repository root."
**Graded criteria:**
- Agent checks for `.git` in current directory
- Error displayed and execution stops
- Does NOT attempt to scan parent directories (skill says repo root only)

#### T4 — Failure Mode: No .sessions/ directory
**Scenario:** User invokes sas-reattach but `.sessions/` does not exist.
**Expected behavior:** Agent displays error: "No .sessions/ directory found. Run sas-endsession first."
**Graded criteria:**
- Agent checks for `.sessions/` directory
- Error displayed
- Does NOT attempt to create directory or continue

#### T5 — Multi-Step: Full reattach with existing todo list
**Scenario:** User already has an active todo list. Invokes sas-reattach with a session that has 2 "Where to Pick Up Next" items. One item already exists in the todo list (duplicate).
**Expected behavior:** Agent merges new items into existing todo list, deduplicates by exact string match (case-insensitive, trimmed).
**Graded criteria:**
- Existing todo list detected
- New items from session merged
- Duplicate item NOT added twice
- Non-duplicate item added
- Deduplication uses case-insensitive, trimmed whitespace comparison

---

### Skill: sas-self-healing-memory

#### T1 — Happy Path: Write new memory entry
**Scenario:** Agent discovers a non-derivable architectural decision during work. Should store it in memory.
**Expected behavior:** Agent writes to topic file first, then updates MEMORY.md Index, then logs to transcript.
**Graded criteria:**
- Entry added to appropriate topic file under correct section (Facts/Decisions/Patterns)
- Entry includes provenance: Created date, Source, Last Verified, Status
- Pointer added to MEMORY.md Index (~150 chars max)
- Entry logged to transcript with ENTRY_TYPE and timestamp
- Write discipline followed: topic file first, then Index, then transcript

#### T2 — Edge Case: Derivable fact
**Scenario:** Agent considers storing "the project uses TypeScript" which is obvious from `tsconfig.json`.
**Expected behavior:** Agent does NOT store this — it's derivable from the codebase.
**Graded criteria:**
- Agent identifies fact as derivable
- Does NOT write to topic file
- Does NOT add to Index
- Does NOT log to transcript
- Instead: reads code directly to confirm

#### T3 — Constraint Obedience: Verify before using memory
**Scenario:** Agent loads a memory entry claiming `auth.py` uses JWT tokens at line 45. Before using this fact, agent must verify.
**Expected behavior:** Agent reads `auth.py` at the cited location, compares to stored memory, proceeds only if match.
**Graded criteria:**
- Agent reads cited code location before using memory
- Compares actual code to stored memory
- If match: proceeds with confidence
- Does NOT blindly trust memory without verification

#### T4 — Failure Mode: Memory conflicts with live code
**Scenario:** Memory says `config.py` has `MAX_RETRIES = 3` but live code shows `MAX_RETRIES = 5`.
**Expected behavior:** Agent executes conflict resolution: confirm discrepancy, supersede old entry, add corrected entry, update Index, log in transcript.
**Graded criteria:**
- Conflict confirmed by reading live code
- Old entry moved to Superseded section with strikethrough, reason, date
- Corrected entry added with current provenance
- Index pointer updated in MEMORY.md
- Transcript logged as `CONFLICT_RESOLVED` with "Memory said" vs "Reality" format

#### T5 — Multi-Step: Full CRUD+ lifecycle
**Scenario:** Agent performs a complete memory operation cycle: create new entry → read and verify → update after finding change → deprecate outdated entry → log all in transcript.
**Expected behavior:** All operations execute correctly with proper file ordering and provenance.
**Graded criteria:**
- Create: topic file → Index → transcript (correct order)
- Read: load from Index → load topic file → verify against code
- Update: edit entry → update Last Verified → update Index
- Deprecate: set Status to deprecated, entry still visible
- All operations logged to transcript with correct ENTRY_TYPEs
- No duplicates accumulated

---

## Execution Notes

### Agent Isolation

- Source Agent and Compiled Agent are **separate invocations** — no shared context between them.
- Both agents receive identical task descriptions and scenario setups.
- Grader Agent is a **third invocation** — receives both agents' outputs and the rubric.

### Stochastic Handling

- If a task fails on the first run, it may be re-run once to check for stochastic false negatives.
- If the task passes on the second run, it is marked as **FLAKY** (pass but flagged for review).
- If it fails both runs, it is a hard FAIL.

### Benchmark File Structure

```
skills/sas-semantic-compiler/
├── architecture/
│   ├── 09-validation.md          ← Updated with Tier 2 spec (this document referenced)
│   └── ...
├── benchmarks/
│   ├── tier-2-benchmarks.md      ← This file
│   └── results/                  ← Generated after each Tier 2 run
│       └── tier2-result-YYYYMMDD-HHmmss.json
└── ...
```

### Result JSON Schema

```json
{
  "timestamp": "2026-04-14T00:00:00Z",
  "skill": "sas-endsession",
  "threshold": 0.95,
  "tasks": [
    {
      "id": "T1",
      "dimension": "happy_path",
      "status": "PASS" | "FAIL" | "FLAKY",
      "criteria": [
        { "id": "C1", "description": "...", "status": "PASS" | "FAIL" }
      ]
    }
  ],
  "summary": {
    "total_tasks": 5,
    "passed": 5,
    "failed": 0,
    "flaky": 0,
    "pass_rate": 1.0,
    "tier2_result": "PASS" | "FAIL"
  }
}
```

---

*Document complete. 25 benchmark tasks defined across 5 skills. Ready for Tier 2 pipeline integration.*
