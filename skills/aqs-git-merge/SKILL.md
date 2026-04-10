---
name: aqs-git-merge
description: Merge branches interactively with guided conflict resolution. Use when the user wants to merge branches, review merge options, or handle merge conflicts.
---

# Git Merge

## Skill Goal

This skill provides a guided, safe workflow for merging branches. It verifies the repository state, presents available merge targets, lets the user choose a branch and merge strategy, executes the merge, and — if conflicts arise — presents options without auto-resolving. The user remains in control at every decision point.

## Instructions

### Step 1: Repo Check

Determine if the current working directory is inside a git repository:

- Run `git rev-parse --show-toplevel`.
- If this fails, inform the user that git operations are not supported in the current directory and exit.

### Step 2: Pre-Merge State Check

1. **Check for in-progress merge:**
   - Run `git status`. If the output mentions "merging" or a merge in progress:
     - Inform the user a merge is already in progress.
     - Present options:
       - `git merge --continue` — complete the merge (requires conflicts resolved first)
       - `git merge --abort` — cancel and restore pre-merge state
       - Inspect conflict files — list conflicted files and show markers
     - Wait for the user's decision before proceeding.

2. **Check for dirty working tree:**
   - Run `git status --porcelain`.
   - If there are uncommitted changes:
     - Warn the user.
     - Offer to **stash** (`git stash push -m "pre-merge stash"`) or **commit** changes first.
     - Wait for the user's decision.

3. **Check for detached HEAD:**
   - Run `git branch --show-current`. If empty, the HEAD is detached.
   - Warn the user that merges in detached HEAD state are not recommended. Offer to checkout a branch first.

### Step 3: Branch Context

- Run `git branch --show-current` and report the current branch to the user.
- This is the **into-branch** (the branch that will receive changes).

### Step 4: Discover Merge Targets

1. **Local branches not yet merged:**
   - Run `git branch --no-merged HEAD` to find local branches with unmerged commits.
   - If no such branches exist, report "No unmerged local branches available."

2. **Remote tracking branches:**
   - Run `git branch -r --no-merged HEAD` to find remote branches.
   - Group results by local and remote in the display.

3. **Present as a numbered list**, e.g.:

   ```
   Local branches:
   1. feature/user-auth
   2. fix/login-bug
   3. refactor/api-cleanup

   Remote branches:
   4. origin/develop
   5. origin/main
   ```

### Step 5: User Selection

- Wait for the user to pick a branch from the list.
- Confirm the merge direction: `Merging <from-branch> into <current-branch>`.

**Direct invocation:** If the user invoked the skill with explicit branch names (e.g., `/aqs-git-merge feature/x -> develop`):
- Validate that both branches exist.
- If the `<into-branch>` is not the current branch, ask the user if they want to switch to it first (`git checkout <into-branch>`).
- Skip to Step 6 with the specified `<from-branch>`.

### Step 6: Merge Strategy Selection

Present the user with merge strategy options:

| Strategy | Flag | Behavior |
|---|---|---|
| **Fast-forward (default)** | *(none)* | If possible, move HEAD forward without a merge commit |
| **No fast-forward** | `--no-ff` | Always create a merge commit |
| **Fast-forward only** | `--ff-only` | Fail if fast-forward is not possible |
| **Squash** | `--squash` | Combine all changes into a single commit, no merge commit |

Additionally, offer a **dry-run preview**:
- `git merge --no-commit --no-ff <branch>` — shows what the merge would look like without committing.

Ask the user which strategy they prefer. If they don't specify, use the default (fast-forward if possible).

### Step 7: Execute Merge

- Run `git merge <strategy-flags> <from-branch>`.
- **Clean merge:** Report success, show the merge commit message, and proceed to Step 9 (Post-Merge).
- **Already up to date:** Report "Already up to date." and exit.
- **Conflicts:** Proceed to Step 8.

### Step 8: Conflict Handling

**Do NOT auto-resolve conflicts.**

1. List conflicting files:
   - Run `git diff --name-only --diff-filter=U`.

2. Present the user with options:

   | Option | Command | Effect |
   |---|---|---|
   | **Abort merge** | `git merge --abort` | Cancel and restore pre-merge state |
   | **Inspect conflicts** | `git diff --name-only --diff-filter=U` + show files | Display conflict markers in affected files |
   | **Resolve manually** | — | Guide the user through manual resolution, then `git add <file>` and `git merge --continue` |
   | **Accept incoming (theirs)** | `git checkout --theirs <file>` for all conflicted files | Accept the merged-in branch's version for all conflicts |
   | **Accept current (ours)** | `git checkout --ours <file>` for all conflicted files | Keep the current branch's version for all conflicts |

3. Wait for the user's decision. If they choose to resolve manually:
   - Show each conflicted file's content with conflict markers.
   - Guide them through editing and marking resolved with `git add <file>`.
   - Once all resolved, run `git merge --continue`.

### Step 9: Post-Merge

1. Report final state:
   - `git status`
   - `git log --oneline -n 3`

2. **Offer to push to remote:**
   - Ask the user if they want to push the result.
   - If yes, run `git push`. If there's no upstream, run `git push --set-upstream origin <branch>`.

3. **Offer undo guidance:**
   - If the user expresses regret or the merge was mistaken, inform them of:
     - `git reset --hard ORIG_HEAD` — undo the merge commit (with warning about lost work)

## Edge Cases

| Scenario | Handling |
|---|---|
| No remote configured | Skip remote branch listing in Step 4 |
| Already up to date | Report "Already up to date." and exit |
| Detached HEAD | Warn user; recommend checking out a branch first |
| Shallow clone | Warn that merge may require full history (`git fetch --unshallow`) |
| Untracked files in working tree | Include in dirty-tree warning; offer to add to `.gitignore` |
| Cross-repo subdirectory | Use `git rev-parse --show-toplevel` to operate from repo root |

## Examples

**Interactive flow:**
```
User: "merge my feature branch"
→ Skill: current branch is `develop`. Here are available branches to merge:
  1. feature/user-auth
  2. fix/login-bug
  3. origin/develop
→ User: "1"
→ Skill: Merging `feature/user-auth` into `develop`. Which strategy? (default: fast-forward)
→ User: "--no-ff"
→ Skill: Merge successful. Push to remote?
```

**Direct invocation:**
```
User: "/aqs-git-merge feature/x -> develop"
→ Skill: Validates branches, switches to `develop` if needed, merges `feature/x` with default strategy.
```

**Conflict scenario:**
```
User: "merge fix/urgent-hotfix"
→ Skill: Conflicts detected in: app/auth.py, tests/test_auth.py

Options:
  1. Abort merge (restore pre-merge state)
  2. Inspect conflict files
  3. Resolve manually
  4. Accept incoming (theirs) for all conflicts
  5. Accept current (ours) for all conflicts

How would you like to proceed?
```
