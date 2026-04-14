<!-- compiled from: skills/sas-git-merge/SKILL.human.md | 2026-04-14T10:00:00Z -->

---
name: sas-git-merge
description: Merge branches interactively with guided conflict resolution. Use when the user wants to merge branches, review merge options, or handle merge conflicts.
---

<purpose>
[P0] Guided workflow for merging branches. Verifies repo state, presents targets, user chooses, executes merge, presents conflict options without auto-resolving. Core direction: merge current branch (source) INTO target branch.
</purpose>

<scope>Target: git repos via CLI. Excluded: non-git VCS, GUI clients, CI/CD pipelines.</scope>

<inputs>Current directory inside git repo. User invocation: interactive or direct (source→target specified).</inputs>

<outputs>
[P0] Successful merge commit on target branch. Optional: pushed to remote, source branch deleted.
</outputs>

<rules>
[P0] Do NOT auto-resolve conflicts.
[P0] User confirms every decision before execution.
[P0] Must not proceed if repo state invalid (not git repo, dirty tree unresolved, detached HEAD without warning).
[P0] User remains in control — no automatic branch selection, conflict resolution, or push without explicit consent.
[P0] Pre-merge state always restorable via git merge --abort.
</rules>

<phase_separation>
1. Repo check: `git rev-parse --show-toplevel`. If fails → inform user, exit.
1.5. Fetch: `git fetch --prune`. If no remote → skip silently.
2. Pre-merge state:
   - `git status`: IF merge in progress → present continue/abort/inspect, wait.
   - `git status --porcelain`: IF uncommitted changes → warn, offer stash or commit, wait.
   - `git branch --show-current`: IF empty (detached HEAD) → warn, offer checkout.
3. Report current branch as source branch.
4. Discover targets: `git branch --list`. Present as numbered list (Local + Remote sections). Exclude current branch.
5. User selection. Confirm: "Merging <current> into <target>."
   IF direct invocation with explicit names → validate both exist.
6. Switch to target: `git checkout <target>`. Verify `git branch --show-current` shows target.
   IF checkout fails → report error, offer stash/commit.
7. Present strategies: fast-forward (default), --no-ff, --ff-only, --squash. IF unspecified → use default.
8. Execute: `git merge <flags> <source>`.
   IF clean → report success, show commit message. IF up to date → report, exit. IF conflicts → go to step 9. IF squash → stage, craft commit, continue.
9. Conflict handling:
   - List conflicts: `git diff --name-only --diff-filter=U`
   - Present options: (1) Abort `git merge --abort`, (2) Inspect, (3) Resolve manually, (4) Accept theirs --theirs, (5) Accept ours --ours
   - IF manual → show conflict markers, guide editing, `git add`, `git merge --continue`
10. Post-merge: `git status` + `git log --oneline -n 3`.
    Offer push. Offer return to original branch. Offer delete source. Offer undo `git reset --hard ORIG_HEAD`.

**Edge cases:**
1. No remote → skip remote listing and fetch.
2. Already up to date → report and exit.
3. Detached HEAD → warn, recommend checkout.
4. Shallow clone → warn, suggest `git fetch --unshallow`.
5. Untracked files → include in dirty-tree warning, offer .gitignore.
6. Cross-repo subdirectory → operate from repo root (step 1).
7. Target ahead of remote → warn about force push requirement.
8. Only one branch → inform nowhere to merge to.
</phase_separation>

<examples>
Interactive: 'merge my feature branch' → discover targets → pick one → merge --no-ff → success, offer push.
Direct: `/sas-git-merge feature/x -> develop` → validates, switches, merges.
Conflict: conflicts in app/auth.py, tests/test_auth.py → present 5 options → wait for decision.
</examples>
