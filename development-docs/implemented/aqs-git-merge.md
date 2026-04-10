# aqs-git-merge — Implementation Plan

## Overview

This document captures the implementation plan for the `aqs-git-merge` skill, which provides a guided, safe workflow for merging branches with user control at every decision point.

## Skill File Structure

```
skills/aqs-git-merge/
├── SKILL.md        ← Main instructions + 10-step execution flow
└── reference.md    ← Merge strategies, conflict resolution, git command reference, edge cases
```

## Core Direction

The skill merges the **current branch (source)** into a **target branch** the user selects. This means the skill checks out the target branch first, then runs `git merge <source-branch>` on it.

## Requirements (from AgentPrompt.txt)

1. **Repo check** — verify the root directory is a git repo; warn and exit if not.
2. **Branch check** — report the current branch the user is on.
3. **Available branches check** — discover branches available for merge (local + remote, not yet merged).
4. **Show branch list** — present a numbered, selectable list to the user.
5. **Execute merge** — once the user selects a branch, attempt the merge.
6. **Direct invocation** — support `/aqs-git-merge <from-branch> -> <into-branch>`.
7. **Conflict handling** — never auto-resolve; present the user with options including aborting the merge.

## Additional Considerations Added

- **Pre-merge safety check** — check for dirty working tree; offer to stash or commit first.
- **Merge strategy options** — support `--no-ff`, `--ff-only`, `--squash`; default to fast-forward.
- **Post-merge push** — offer to push to remote after a successful merge.
- **Remote branch support** — allow merging from/to remote tracking branches.
- **Already-in-merge state** — handle incomplete merges; offer `--abort` or `--continue`.
- **Dry-run preview** — `git merge --no-commit --no-ff` for preview before committing.
- **Detached HEAD warning** — warn user if HEAD is detached.
- **Undo guidance** — provide `git reset --hard ORIG_HEAD` as an escape hatch.
- **Cross-repo subdirectory awareness** — use `git rev-parse --show-toplevel`.
- **Quick resolution options** — "accept ours" / "accept theirs" for all conflicts at once.

## 9-Step Execution Flow

### Step 1: Repo Check
- Run `git rev-parse --show-toplevel`.
- If it fails, inform user git operations are not supported and exit.

### Step 2: Pre-Merge State Check
- **In-progress merge:** If `git status` mentions "merging", present options (`--continue`, `--abort`, inspect conflicts).
- **Dirty working tree:** If `git status --porcelain` shows changes, warn user and offer to stash or commit.
- **Detached HEAD:** If `git branch --show-current` is empty, warn and recommend checking out a branch.

### Step 3: Branch Context
- Report current branch via `git branch --show-current`.
- This branch is the **source branch** (its changes will be merged into the target).

### Step 4: Discover Target Branches
- Local: `git branch` (exclude current branch)
- Remote: `git branch -r` (optional)
- Present as a numbered list grouped by local and remote.

### Step 5: User Selection
- Wait for user to pick a target branch.
- Confirm merge direction: `Merging <current-branch> into <target-branch>`.
- **Direct invocation:** If invoked with `<from-branch> -> <into-branch>`, validate both branches exist, then proceed to Step 6.

### Step 6: Switch to Target Branch
- Run `git checkout <target-branch>`.
- If checkout fails (dirty tree), offer to stash/commit first.
- Verify with `git branch --show-current`.

### Step 7: Merge Strategy Selection
Present options:

| Strategy | Flag | Behavior |
|---|---|---|
| Fast-forward (default) | *(none)* | Move HEAD forward if possible |
| No fast-forward | `--no-ff` | Always create a merge commit |
| Fast-forward only | `--ff-only` | Fail if fast-forward is not possible |
| Squash | `--squash` | Combine all changes into a single commit |

Also offer dry-run: `git merge --no-commit --no-ff <branch>`.

### Step 8: Execute Merge
- Run `git merge <strategy-flags> <source-branch>`.
- **Clean merge:** Report success → Step 10.
- **Already up to date:** Report and exit.
- **Conflicts:** → Step 9.

### Step 9: Conflict Handling
**The agent must NOT auto-resolve conflicts.**

1. List conflicting files: `git diff --name-only --diff-filter=U`.
2. Present options:

| Option | Effect |
|---|---|
| Abort merge | Restore pre-merge state |
| Inspect conflicts | Show conflict markers in affected files |
| Resolve manually | Guide user through editing, `git add`, then `git merge --continue` |
| Accept incoming (theirs) | Accept merged-in branch's version for all conflicts |
| Accept current (ours) | Keep current branch's version for all conflicts |

3. Wait for user decision.

### Step 10: Post-Merge
- Report final state: `git status`, `git log --oneline -n 3`.
- Offer to push to remote.
- Offer to switch back to the original branch.
- Provide undo guidance (`git reset --hard ORIG_HEAD`).

## Edge Cases

| Scenario | Handling |
|---|---|
| No remote configured | Skip remote branch listing |
| Already up to date | Report and exit |
| Detached HEAD | Warn; recommend checkout |
| Shallow clone | Warn; suggest `git fetch --unshallow` |
| Untracked files | Include in dirty-tree warning |
| Cross-repo subdirectory | Use `git rev-parse --show-toplevel` |
| Submodules | Recommend `git submodule update --init --recursive` after merge |
| Case-insensitive filesystems | Note spurious conflict risk on Windows/macOS |
| Large binary files | Recommend `--ours`/`--theirs` or manual file replacement |

## reference.md Contents

The companion reference document covers:

1. **Merge Strategy Comparison** — table comparing fast-forward, `--no-ff`, `--ff-only`, `--squash` with ASCII diagrams.
2. **Conflict Resolution Walkthrough** — how git marks conflicts, step-by-step manual resolution, quick resolution for all conflicts.
3. **Git Command Reference** — grouped tables for Discovery, State Checks, Merge Operations, Undo, and Push commands.
4. **Safety Notes** — rationale for why the agent never auto-resolves conflicts, importance of clean working tree, ORIG_HEAD caveats.
5. **Edge Case Details** — shallow clones, submodules, case-insensitive filesystems, large binary files.
