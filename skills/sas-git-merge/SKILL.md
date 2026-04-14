---
name: sas-git-merge
description: Merge branches interactively with guided conflict resolution. Use when the user wants to merge branches, review merge options, or handle merge conflicts.
---
<!-- compiled from: D:\Users\jasonbarry\Documents\Development\Agent\semantic-agent-skills\skills\sas-git-merge\SKILL.human.md | 2026-04-14T00:00:00Z -->

## <purpose>
Provide a guided, safe workflow for merging the current branch (source) into a user-selected target branch. The user controls every decision — repo verification, branch selection, strategy choice, conflict resolution, and post-merge actions. The skill never auto-resolves conflicts.
## <scope>
In-scope: interactive branch merges within a single git repository, conflict inspection, post-merge push/cleanup. Out-of-scope: cross-repo merges, automatic conflict resolution, rebasing, cherry-picking.
## <inputs>
- Current git repository state (working directory, HEAD, working tree cleanliness).
- User selection of target branch and merge strategy (interactive or direct invocation with `<from-branch> -> <into-branch>` syntax).
## <outputs>
- Merged target branch with source changes applied, or explicit abort/abort-on-conflict state restored.
- Post-merge state report: `git status`, `git log --oneline -n 3`, optional push, optional source branch deletion.
## <rules>

**P0 — Non-negotiable (inviolable):**
1. The agent must not auto-resolve merge conflicts — only present options and wait for user decision.
2. The agent must verify the working directory is inside a git repository (`git rev-parse --show-toplevel`) before any operation; if check fails, exit.
3. The agent must confirm merge direction with the user (`Merging <source> into <target>`) before executing any merge command.
4. The agent must not execute a merge without first switching to the target branch and verifying `git branch --show-current` matches it.

**P1 — Required (retry on failure, replan after 3):**
5. The agent must run `git fetch --prune` before merge discovery; if no remote exists, skip silently.
6. The agent must detect an in-progress merge (`git status` mentions "merging") and present continue/abort/inspect options before proceeding.
7. The agent must check for dirty working tree (`git status --porcelain`) and warn; offer stash or commit before merge.
8. The agent must check for detached HEAD (`git branch --show-current` returns empty) and warn; recommend checkout of a named branch first.
9. IF the target branch is a remote-tracking branch (e.g., `origin/develop`), THEN the agent must run `git fetch` before checkout.
10. IF the merge produces conflicts, THEN the agent must list conflicted files (`git diff --name-only --diff-filter=U`) and present all five options: abort, inspect, resolve manually, accept theirs (source), accept ours (target).
11. IF the user invokes the skill directly with `<from-branch> -> <into-branch>`, THEN the agent must validate both branches exist; IF the current branch is neither, warn and ask whether to switch to `<into-branch>`.
12. IF a squash merge is selected, THEN the agent must help craft a commit message (default: `Merge branch '<source>' into <target>`) and run `git commit`.

**P2 — Preferences (override with stated justification):**
13. The agent should offer post-merge actions in order: push to remote, switch back to original branch, delete source branch, undo guidance.
14. The agent should present merge strategies with a dry-run preview option (`git merge --no-commit --no-ff <source>`).
15. The agent should warn on shallow clones that merge may require full history (`git fetch --unshallow`).

## <phase_separation>
This skill participates in the CODE and REVIEW phases. It must not bypass PLAN → CODE → REVIEW ordering — merge execution (CODE) always precedes merge verification (REVIEW). Post-merge actions (push, cleanup) are part of the CODE phase.

## <invariants>
1. The current branch at skill start must be the source branch throughout — the source branch name must not change even after switching to target for merge.
2. The repository root determined by `git rev-parse --show-toplevel` at skill start must be used for all subsequent git commands.
3. After a successful non-squash merge, the target branch HEAD must contain all commits from the source branch reachable from the merge base.
4. After `git merge --abort` (whether from in-progress merge detection or conflict handling), the repository state must be identical to pre-merge state.

