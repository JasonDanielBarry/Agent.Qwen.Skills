---
name: sas-git-commit-and-push
description: Commit all changes using conventional commit messages and push to remote. Use when the user asks to commit and push, or when work is ready to be saved and shared.
---

## Purpose

Autonomously stage, commit, and push all changes to the remote repository without requesting user permission or confirmation.

## Scope

Single capability: save and share work via conventional commits.

## Inputs

Current working tree state (staged/unstaged changes, untracked files).

## Outputs

One or more conventional commits pushed to the remote; clean working tree.

## Rules

### P0 (Absolute)
- NEVER ask the user for permission, confirmation, or approval at any point.
- NEVER skip committing changes because the diff is large, complex, or touches many files.
- NEVER leave the working tree dirty after a successful commit + push unless an edge case prevents it.
- ALWAYS run `git add -A` to stage all changes before committing.

### P1 (Strong)
- ALWAYS follow Conventional Commits format: `type(scope): description`.
- ALWAYS match the commit message style of recent commits (`git log -n 3 --oneline`).
- ALWAYS commit body should explain *why*, not *what*.
- ALWAYS split multiple independent changes into separate atomic commits.
- ALWAYS commit code and documentation changes as separate atomic commits.

### P2 (Normal)
- Use `feat:` for new features, `fix:` for bug fixes, `docs:` for documentation, `refactor:` for restructuring without behavior change, `chore:` for maintenance/tooling/config, `test:` for test changes, `ci:` for CI/CD, `build:` for build system, `perf:` for performance, `revert:` for reverting commits.
- If `git push` fails with "no upstream branch", run `git push --set-upstream origin <branch-name>`.
- If untracked files should be ignored, add them to `.gitignore` rather than committing them.

## Phase Separation

### Phase 1: Check Current State
1. Run `git status` to see changed files.
2. Run `git diff HEAD` to review the full diff.
3. Run `git log -n 3 --oneline` to review recent commit style.
4. IF `git status` indicates a merge, rebase, cherry-pick, or conflict in progress, THEN display a warning but proceed.
5. IF working tree is clean with no changes, THEN report "working tree is already clean" and stop.

### Phase 2: Stage All Changes
1. Run `git add -A`.

### Phase 3: Determine Commit Strategy
1. IF changes represent a single logical change, THEN plan one conventional commit.
2. IF changes represent multiple independent changes, THEN plan multiple atomic conventional commits.
3. IF changes mix code and documentation, THEN plan separate commits for each.

### Phase 4: Write and Commit
1. Draft commit message(s) following Conventional Commits format.
2. Include body explaining *why* changes were made.
3. Run `git commit -m "message"` for each planned commit.
4. Run `git status` to verify working tree is clean.

### Phase 5: Push
1. Run `git push`.
2. IF push fails with "no upstream branch", THEN run `git push --set-upstream origin <branch-name>`.
3. Report result including remote URL if a new branch was created.

## Invariants

- No user permission, confirmation, or approval is ever requested.
- Large or complex diffs are never skipped.
- Working tree is clean after successful commit + push.
- All commits follow Conventional Commits format.
- Commit messages match the style of recent repository history.
- Code and documentation changes are committed separately.

