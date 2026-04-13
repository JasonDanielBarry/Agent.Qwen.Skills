---
name: sas-git-commit-and-push
description: Commit all changes using conventional commit messages and push to remote.
---

<!-- compiled from: skills/sas-git-commit-and-push/SKILL.human.md | 2026-04-13T10:35:00Z -->

## Purpose

<purpose>
[P0] Autonomously stage, commit, and push changes with conventional commit messages — no permission prompts.
</purpose>

## Scope

<scope>
- Target: Git repositories with uncommitted changes ready to be saved and shared
- Input: Current working tree state (staged + unstaged changes)
- Output: One or more conventional commits pushed to remote
- Excluded: Partial staging (commits all changes), interactive rebase, selective file commits
</scope>

## Inputs

<inputs>
- Git repository (current directory or parent contains `.git`)
- Working tree with changes (new, modified, or deleted files)
- Recent commit history (for style matching via `git log -n 3`)
</inputs>

## Outputs

<outputs>
- One or more conventional commits on current branch
- Changes pushed to remote repository
- Working tree clean after successful commit + push (unless edge cases prevent)
</outputs>

## Constraints

<constraints>
[P0] Must NOT ask user for permission, confirmation, or approval at any point.
[P0] Must NOT skip committing changes because diff is large, complex, or touches many files.
[P0] Must NOT leave working tree dirty after successful commit + push (unless edge cases prevent).
[P0] Must NOT present draft commit message and ask "does this look good?"
[P0] Must NOT ask "should I commit?" or "ready to push?"
[P1] Must stage all changes with `git add -A`.
[P1] Must follow Conventional Commits format: `type(scope): description`.
[P1] Must match commit message style of recent commits (`git log -n 3`).
</constraints>

## Invariants

<invariants>
[P0] User invoking the skill has given implicit consent — no explicit confirmation required.
[P0] Commit message body must explain WHY, not WHAT.
[P0] Documentation-only changes use `docs:` prefix.
[P0] Code fixes use `fix:` prefix.
[P0] Refactoring (no behavior change) uses `refactor:` prefix.
[P0] Feature work uses `feat:` prefix.
[P0] Chore/misc uses `chore:` prefix.
[P0] Test changes use `test:` prefix.
</invariants>

## Failure Modes

<failure_modes>
| Scenario | Handling |
|----------|----------|
| No changes | Report: working tree already clean. Nothing to do. Exit. |
| Untracked files in `.gitignore` | Add to `.gitignore` rather than commit. |
| Mixed doc + code changes | Commit code and docs as separate atomic commits. |
| `git push` fails (no upstream) | Run `git push --set-upstream origin <branch-name>`. |
| Merge/rebase/cherry-pick in progress | Display warning, proceed with staging and committing. |
| Not in git repository | Display error: git operations not supported in current directory. Exit. |
</failure_modes>

## Validation Strategy

<validation_strategy>
- Verify `git status` shows clean working tree after commit + push
- Verify commit message follows Conventional Commits format
- Verify changes pushed to remote successfully
- Verify commit count matches logical change groups
</validation_strategy>

## Relationships

<relationships>
- Depends on: Git repository with remote configured
- Consumed by: Remote repository collaborators
- Complementary to: `sas-git-merge` (branch merging workflow)
</relationships>

## Guarantees

<guarantees>
[P0] All changes committed and pushed without user confirmation prompts.
[P0] Conventional commit messages match project style.
[P1] Working tree clean after successful operation.
[P2] Push result reported including remote URL for new branches.
</guarantees>

---

## Invocation Conditions

<invocation_conditions>
- User asks to "commit and push" or similar
- Work is ready to be saved and shared
- User invoking the skill has given implicit consent
</invocation_conditions>

## Forbidden Usage

<forbidden_usage>
- Must NOT ask "should I commit?" before staging
- Must NOT ask "does this commit message look good?" before committing
- Must NOT ask "ready to push?" before pushing
- Must NOT skip commits due to large diffs
- Must NOT leave working tree dirty after completion
- Must NOT commit files that should be in `.gitignore`
</forbidden_usage>

## Phase Separation

<phase_separation>
- This skill is fully implemented and operational.
- No deferred features.
</phase_separation>

---

## Execution Steps

### Step 1: Check Current State

<step1_check_state>
[P0] Run `git status` — determine what has changed.
[P0] Run `git diff HEAD` — review full diff of all changes.
[P0] Run `git log -n 3 --oneline` — review recent commit message style.

IF `git status` indicates merge, rebase, cherry-pick, or conflict in progress:
  THEN display warning but proceed with staging and committing.
</step1_check_state>

### Step 2: Stage All Changes

<step2_stage>
[P0] Run `git add -A` — stage everything (new, modified, deleted).
</step2_stage>

### Step 3: Determine Commit Strategy

<step3_strategy>
IF single logical change:
  THEN one commit with conventional commit message.
IF multiple independent changes:
  THEN multiple atomic commits, each with own conventional commit message.
IF documentation-only changes:
  THEN use `docs:` prefix.
IF code fixes:
  THEN use `fix:` prefix.
IF refactoring (no behavior change):
  THEN use `refactor:` prefix.
IF feature work:
  THEN use `feat:` prefix.
IF chore/misc:
  THEN use `chore:` prefix.
IF test changes:
  THEN use `test:` prefix.
</step3_strategy>

### Step 4: Write Commit Message

<step4_message>
[P0] Follow Conventional Commits format: `type(scope): description`.
[P0] Body must explain WHY, not WHAT.
[P0] Match style of recent commits (from `git log -n 3`).
[P0] Must NOT ask user for permission or confirmation. Commit directly with drafted message.
</step4_message>

### Step 5: Commit

<step5_commit>
[P0] Run `git commit -m "message"` (or multiple commits for separate logical groups).
[P1] Verify with `git status` that working tree is clean.
</step5_commit>

### Step 6: Push

<step6_push>
[P0] Run `git push`.
IF fails with "no upstream branch":
  THEN run `git push --set-upstream origin <branch-name>`.
[P1] Report result including remote URL if new branch was created.
</step6_push>

### Edge Case: No Changes

<edge_no_changes>
Report: working tree already clean. Nothing to do. Exit.
</edge_no_changes>

### Edge Case: Untracked Files in .gitignore

<edge_untracked_gitignore>
Add untracked files to `.gitignore` rather than committing them.
</edge_untracked_gitignore>

### Edge Case: Mixed Doc + Code Changes

<edge_mixed_changes>
Commit code and docs as separate atomic commits.
</edge_mixed_doc_code>

---

## Conventional Commit Types

<commit_types>
| Type | When to use |
|------|-------------|
| `feat` | New feature or capability |
| `fix` | Bug fix or error correction |
| `docs` | Documentation-only changes |
| `refactor` | Code restructuring with no behavior change |
| `chore` | Maintenance, tooling, config changes |
| `test` | Test additions or modifications |
| `ci` | CI/CD pipeline changes |
| `build` | Build system or dependency changes |
| `perf` | Performance improvements |
| `revert` | Reverting a previous commit |
</commit_types>
