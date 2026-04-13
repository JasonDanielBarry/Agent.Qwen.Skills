---
name: sas-git-merge
description: Merge branches interactively with guided conflict resolution. Use when the user wants to merge branches, review merge options, or handle merge conflicts.
---

# Git Merge

## Skill Goal

This skill provides a guided, safe workflow for merging branches. It verifies the repository state, presents available target branches, lets the user choose where to merge the current branch, executes the merge, and — if conflicts arise — presents options without auto-resolving. The user remains in control at every decision point. After a successful merge, the skill offers post-merge actions (push, branch cleanup, undo).

The core direction is: **merge the current branch (source) INTO the target branch**.

## Instructions

### Step 1: Repo Check

Determine if the current working directory is inside a git repository:

- Run `git rev-parse --show-toplevel`.
- If this fails, inform the user that git operations are not supported in the current directory and exit.

### Step 1.5: Fetch Latest State

- Run `git fetch --prune` to ensure remote tracking branches are up to date and stale refs are removed.
- If there is no remote, skip silently.

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
- This is the **source branch** (the branch whose changes will be merged into the target).

### Step 4: Discover Target Branches

- Run `git branch --list --format='%(refname:short)'` to get clean branch names without the `*` prefix.
- Filter out the current branch from the list.
- Optionally include remote branches with `git branch -r --list --format='%(refname:short)'`.
- Present as a numbered list, excluding the current branch.

  ```
  Target branches (merge current branch into one of these):

  Local branches:
  1. develop
  2. main
  3. release/v2.0

  Remote branches:
  4. origin/develop
  5. origin/main
  ```

### Step 5: User Selection

- Wait for the user to pick a target branch from the list.
- Confirm the merge direction: `Merging <current-branch> into <target-branch>`.

**Direct invocation:** If the user invoked the skill with explicit branch names (e.g., `/sas-git-merge feature/x -> develop`):
- Validate that both branches exist.
- The `<from-branch>` is `feature/x`, the `<into-branch>` is `develop`.
- If the current branch is the `<into-branch>`, skip to Step 6 with the source branch already known.
- If the current branch is `<from-branch>`, proceed to Step 6.
- If the current branch is neither, warn the user and ask if they want to switch to the `<into-branch>` first.

### Step 6: Switch to Target Branch

Before the merge can happen, switch to the target branch:

- If the target branch is a remote tracking branch (e.g., `origin/develop`), first run `git fetch` to ensure it's up to date.
- Confirm the switch with the user: `Switching to <target-branch> to merge <source-branch> into it. Proceed?`
- Upon confirmation, run `git checkout <target-branch>`.
- If checkout fails (e.g., dirty tree), report the error and offer to stash/commit first.
- After checkout, verify: `git branch --show-current` should now show `<target-branch>`.

### Step 7: Merge Strategy Selection

Present the user with merge strategy options:

| Strategy | Flag | Behavior |
|---|---|---|
| **Fast-forward (default)** | *(none)* | If possible, move HEAD forward without a merge commit |
| **No fast-forward** | `--no-ff` | Always create a merge commit |
| **Fast-forward only** | `--ff-only` | Fail if fast-forward is not possible |
| **Squash** | `--squash` | Combine all changes into staged changes; the user must commit manually |

Additionally, offer a **dry-run preview**:
- `git merge --no-commit --no-ff <source-branch>` — shows what the merge would look like without committing.

Ask the user which strategy they prefer. If they don't specify, use the default (fast-forward if possible).

### Step 8: Execute Merge

- Run `git merge <strategy-flags> <source-branch>`.
- **Clean merge (non-squash):** Report success, show the merge commit message, and proceed to Step 10 (Post-Merge).
- **Squash merge:** Changes are staged but not committed. Help the user craft a commit message (default: `Merge branch '<source-branch>' into <target-branch>`), then run `git commit -m "<message>"`. Proceed to Step 10.
- **Already up to date:** Report "Already up to date." and exit.
- **Conflicts:** Proceed to Step 9.

### Step 9: Conflict Handling

**Do NOT auto-resolve conflicts.**

1. List conflicting files:
   - Run `git diff --name-only --diff-filter=U`.

2. Present the user with options:

   | Option | Command | Effect |
   |---|---|---|
   | **Abort merge** | `git merge --abort` | Cancel and restore pre-merge state (back to before the merge attempt) |
   | **Inspect conflicts** | `git diff --name-only --diff-filter=U` + show files | Display conflict markers in affected files |
   | **Resolve manually** | — | Guide the user through manual resolution, then `git add <file>` and `git merge --continue` |
   | **Accept source branch version** | `git checkout --theirs <file>` for all conflicted files | Accept the source branch's (incoming) version for all conflicts |
   | **Accept target branch version** | `git checkout --ours <file>` for all conflicted files | Keep the target branch's (current) version for all conflicts |

3. Wait for the user's decision. If they choose to resolve manually:
   - Show each conflicted file's content with conflict markers.
   - Guide them through editing and marking resolved with `git add <file>`.
   - Once all resolved, run `git merge --continue`.

### Step 10: Post-Merge

1. Report final state:
   - `git status`
   - `git log --oneline -n 3`

2. **Offer to push to remote:**
   - Ask the user if they want to push the result.
   - If yes, run `git push`. If there's no upstream, run `git push --set-upstream origin <branch>`.

3. **Offer to switch back to the original branch:**
   - Ask if the user wants to return to the branch they started on (`git checkout <original-branch>`).

4. **Offer to delete the source branch (optional):**
   - If the user no longer needs the source branch, offer:
     - `git branch -d <source-branch>` — safe delete (only if fully merged)
     - `git push origin --delete <source-branch>` — delete remote branch too
   - Only proceed with explicit confirmation.

5. **Offer undo guidance:**
   - If the user expresses regret or the merge was mistaken, inform them of:
     - `git reset --hard ORIG_HEAD` — undo the merge commit (with warning about lost work)

## Edge Cases

| Scenario | Handling |
|---|---|
| No remote configured | Skip remote branch listing in Step 4; skip fetch in Step 1.5 |
| Already up to date | Report "Already up to date." and exit |
| Detached HEAD | Warn user; recommend checking out a branch first |
| Shallow clone | Warn that merge may require full history (`git fetch --unshallow`) |
| Untracked files in working tree | Include in dirty-tree warning; offer to add to `.gitignore` |
| Cross-repo subdirectory | Use `git rev-parse --show-toplevel` to operate from repo root |
| Target branch is ahead of remote | Warn user that pushing after merge may require a force push (if history was rewritten) |
| No branches available to merge into | If only one branch exists, inform user there's nowhere to merge to |

## Examples

**Interactive flow:**
```
User: "merge my feature branch"
→ Skill: current branch is `feature/user-auth`. Here are target branches to merge into:
  1. develop
  2. main
  3. origin/develop
→ User: "1"
→ Skill: Merging `feature/user-auth` into `develop`. Switching to develop... done.
  Which strategy? (default: fast-forward)
→ User: "--no-ff"
→ Skill: Merge successful. Push to remote?
```

**Direct invocation:**
```
User: "/sas-git-merge feature/x -> develop"
→ Skill: Validates branches, switches to `develop`, merges `feature/x` with default strategy.
```

**Conflict scenario:**
```
User: "merge fix/urgent-hotfix into develop"
→ Skill: Conflicts detected in: app/auth.py, tests/test_auth.py

Options:
  1. Abort merge (restore pre-merge state)
  2. Inspect conflict files
  3. Resolve manually
  4. Accept source branch version (fix/urgent-hotfix) for all conflicts
  5. Accept target branch version (develop) for all conflicts

How would you like to proceed?
```
