---
name: sas-git-merge
description: Merge branches interactively with guided conflict resolution.
---

<!-- compiled from: skills/sas-git-merge/SKILL.human.md | 2026-04-13T10:35:00Z -->

## Purpose

<purpose>
[P0] Provide a guided, safe workflow for merging branches — verifying repo state, presenting target branches, executing merge, and handling conflicts without auto-resolution.
</purpose>

## Scope

<scope>
- Target: Git repositories requiring branch merges
- Input: Current branch (source), user-selected target branch
- Output: Clean merge or guided conflict resolution with post-merge actions
- Excluded: Auto-resolving merge conflicts, merging without user awareness, detached HEAD merges
</scope>

## Inputs

<inputs>
- Git repository (verified via `git rev-parse --show-toplevel`)
- Current branch name (source branch to merge)
- User-selected target branch (branch to merge into)
- User-selected merge strategy (fast-forward, no-ff, ff-only, squash)
</inputs>

## Outputs

<outputs>
- Merged target branch with source branch changes integrated
- Post-merge options: push, branch cleanup, source branch deletion, undo guidance
- Conflict report (if conflicts detected): list of conflicted files + resolution options
</outputs>

## Constraints

<constraints>
[P0] Must NOT auto-resolve merge conflicts.
[P0] Must merge current branch (source) INTO target branch — direction is fixed.
[P0] Must NOT proceed with merge if conflicts exist without presenting resolution options.
[P0] Must NOT leave user unaware of merge state (success, conflict, or already up-to-date).
[P1] Must fetch latest state before merge (`git fetch --prune`).
[P1] Must check for in-progress merge before starting new merge.
[P1] Must check for dirty working tree before merge.
[P1] Must check for detached HEAD before merge.
[P2] Must offer dry-run preview option before executing merge.
</constraints>

## Invariants

<invariants>
[P0] User remains in control at every decision point.
[P0] Merge direction: source (current branch) → target (selected branch).
[P0] Conflicts presented with explicit options — never auto-resolved.
[P0] Post-merge actions offered, not forced.
</invariants>

## Failure Modes

<failure_modes>
| Scenario | Handling |
|----------|----------|
| Not in git repository | Inform user git operations not supported in current directory. Exit. |
| Merge already in progress | Inform user, present options: continue, abort, inspect conflicts. Wait for decision. |
| Dirty working tree | Warn user, offer to stash or commit first. Wait for decision. |
| Detached HEAD | Warn user, recommend checking out a branch first. |
| No remote configured | Skip remote branch listing, skip fetch. Proceed with local branches only. |
| Already up to date | Report "Already up to date." Exit. |
| Conflicts detected | Present 5 resolution options (abort, inspect, manual, accept source, accept target). Wait for decision. |
| Target branch checkout fails | Report error, offer to stash/commit first. |
| No branches available to merge into | Inform user there's nowhere to merge to. |
| Shallow clone | Warn that merge may require full history (`git fetch --unshallow`). |
| Target branch ahead of remote | Warn that pushing after merge may require force push. |
</failure_modes>

## Validation Strategy

<validation_strategy>
- Verify `git status` shows clean state after merge (or conflicts clearly listed)
- Verify `git log --oneline -n 3` shows merge commit
- Verify merge direction correct (source merged into target)
- Verify no auto-resolved conflicts
</validation_strategy>

## Relationships

<relationships>
- Depends on: Git repository with at least 2 branches
- Consumed by: Post-merge workflow (push, branch cleanup, source deletion)
- Complementary to: `sas-git-commit-and-push` (committing before merge, pushing after merge)
</relationships>

## Guarantees

<guarantees>
[P0] Conflicts never auto-resolved — user always chooses resolution.
[P0] Merge direction always explicit: source → target.
[P1] Pre-merge state restorable via abort option.
[P2] Post-merge actions always offered, never forced.
</guarantees>

---

## Invocation Conditions

<invocation_conditions>
- User wants to merge branches, review merge options, or handle merge conflicts
- Skill invoked interactively or directly with branch names (e.g., `/sas-git-merge feature/x -> develop`)
</invocation_conditions>

## Forbidden Usage

<forbidden_usage>
- Must NOT auto-resolve merge conflicts under any circumstance
- Must NOT merge without presenting target branch options (unless direct invocation with explicit branches)
- Must NOT proceed past conflicts without user decision
- Must NOT force post-merge actions on user
- Must NOT merge in detached HEAD state without warning
</forbidden_usage>

## Phase Separation

<phase_separation>
- This skill is fully implemented and operational.
- No deferred features.
</phase_separation>

---

## Execution Steps

### Step 1: Repo Check

<step1_repo_check>
[P0] Run `git rev-parse --show-toplevel`.
IF fails:
  THEN inform user git operations not supported in current directory.
  THEN exit.
</step1_repo_check>

### Step 1.5: Fetch Latest State

<step1_5_fetch>
[P1] Run `git fetch --prune`.
IF no remote: skip silently.
</step1_5_fetch>

### Step 2: Pre-Merge State Check

<step2_pre_merge>
[P0] Check for in-progress merge:
  Run `git status`. IF output mentions "merging" or merge in progress:
    THEN inform user merge already in progress.
    THEN present options:
      1. `git merge --continue` — complete merge (requires conflicts resolved first)
      2. `git merge --abort` — cancel and restore pre-merge state
      3. Inspect conflict files — list conflicted files and show markers
    THEN wait for user decision.

[P0] Check for dirty working tree:
  Run `git status --porcelain`. IF uncommitted changes:
    THEN warn user.
    THEN offer to stash (`git stash push -m "pre-merge stash"`) or commit first.
    THEN wait for user decision.

[P1] Check for detached HEAD:
  Run `git branch --show-current`. IF empty: HEAD is detached.
    THEN warn user merges in detached HEAD not recommended.
    THEN offer to checkout a branch first.
</step2_pre_merge>

### Step 3: Branch Context

<step3_branch_context>
[P0] Run `git branch --show-current`.
[P0] Report current branch to user — this is the SOURCE branch (whose changes will be merged into target).
</step3_branch_context>

### Step 4: Discover Target Branches

<step4_discover_targets>
[P1] Run `git branch --list --format='%(refname:short)'` — get clean branch names without `*` prefix.
[P1] Filter out current branch from list.
[P2] Optionally include remote branches with `git branch -r --list --format='%(refname:short)'`.
[P1] Present as numbered list, excluding current branch:

  ```
  Target branches (merge current branch into one of these):

  Local branches:
  1. develop
  2. main

  Remote branches:
  3. origin/develop
  4. origin/main
  ```
</step4_discover_targets>

### Step 5: User Selection

<step5_user_selection>
[P0] Wait for user to pick target branch from list.
[P0] Confirm merge direction: `Merging <current-branch> into <target-branch>`.

IF direct invocation with explicit branch names (e.g., `/sas-git-merge feature/x -> develop`):
  THEN validate both branches exist.
  THEN `<from-branch>` = source, `<into-branch>` = target.
  IF current branch is `<into-branch>`: skip to Step 6 with source branch already known.
  IF current branch is `<from-branch>`: proceed to Step 6.
  IF current branch is neither: warn user, ask if they want to switch to `<into-branch>` first.
</step5_user_selection>

### Step 6: Switch to Target Branch

<step6_switch_target>
[P0] IF target branch is remote tracking branch (e.g., `origin/develop`):
  THEN run `git fetch` to ensure up to date.
[P0] Confirm switch with user: `Switching to <target-branch> to merge <source-branch> into it. Proceed?`
[P0] Upon confirmation: run `git checkout <target-branch>`.
IF checkout fails (e.g., dirty tree):
  THEN report error, offer to stash/commit first.
[P0] After checkout: verify `git branch --show-current` shows `<target-branch>`.
</step6_switch_target>

### Step 7: Merge Strategy Selection

<step7_strategy>
[P1] Present merge strategy options:

| Strategy | Flag | Behavior |
|----------|------|----------|
| Fast-forward (default) | *(none)* | Move HEAD forward without merge commit (fails if not possible) |
| No fast-forward | `--no-ff` | Always create merge commit |
| Fast-forward only | `--ff-only` | Fail if fast-forward not possible |
| Squash | `--squash` | Stage changes only; user must commit manually |

[P2] Offer dry-run preview: `git merge --no-commit --no-ff <source-branch>`.
[P1] Ask user which strategy they prefer. IF unspecified: use default (fast-forward when available, otherwise merge commit).
</step7_strategy>

### Step 8: Execute Merge

<step8_execute_merge>
[P0] Run `git merge <strategy-flags> <source-branch>`.

IF clean merge (non-squash):
  THEN report success, show merge commit message, proceed to Step 10.
IF squash merge:
  THEN changes staged but not committed.
  THEN help user craft commit message (default: `Merge branch '<source-branch>' into <target-branch>`).
  THEN run `git commit -m "<message>"`.
  THEN proceed to Step 10.
IF already up to date:
  THEN report "Already up to date." Exit.
IF conflicts:
  THEN proceed to Step 9.
</step8_execute_merge>

### Step 9: Conflict Handling

<step9_conflicts>
[P0] Must NOT auto-resolve conflicts.

[P0] List conflicting files:
  Run `git diff --name-only --diff-filter=U`.

[P0] Present resolution options:

| Option | Command | Effect |
|--------|---------|--------|
| Abort merge | `git merge --abort` | Cancel, restore pre-merge state |
| Inspect conflicts | `git diff --name-only --diff-filter=U` | Display conflict markers in affected files |
| Resolve manually | — | Guide through manual resolution, then `git add <file>` and `git merge --continue` |
| Accept source version | `git checkout --theirs <file>` for all conflicted files | Accept incoming version |
| Accept target version | `git checkout --ours <file>` for all conflicted files | Keep current version |

[P0] Wait for user decision.
IF user chooses manual resolution:
  THEN show each conflicted file's content with conflict markers.
  THEN guide through editing and marking resolved with `git add <file>`.
  THEN once all resolved: run `git merge --continue`.
</step9_conflicts>

### Step 10: Post-Merge

<step10_post_merge>
[P1] Report final state:
  Run `git status` and `git log --oneline -n 3`.

[P2] Offer to push to remote:
  IF user agrees: run `git push`. IF no upstream: run `git push --set-upstream origin <branch>`.

[P2] Offer to switch back to original branch.

[P2] Offer to delete source branch (optional):
  IF user no longer needs source branch:
    THEN offer `git branch -d <source-branch>` (safe delete, only if fully merged).
    THEN offer `git push origin --delete <source-branch>` (delete remote too).
    THEN proceed only with explicit confirmation.

[P2] Offer undo guidance:
  IF user expresses regret or merge was mistaken:
    THEN inform: `git reset --hard ORIG_HEAD` — undo merge commit (with warning about lost work).
</step10_post_merge>
