<!-- compiled from: skills/sas-git-merge/SKILL.human.md | 2026-04-14T00:00:00Z -->

---
name: sas-git-merge
description: Merge branches interactively with guided conflict resolution. Use when the user wants to merge branches, review merge options, or handle merge conflicts.
---

<Purpose>
[P2] Guided, safe workflow for merging branches. Verifies repo state, presents target branches, user chooses merge target, executes merge, presents conflict options without auto-resolving. User controls every decision point. Post-merge: push, branch cleanup, undo.
[P0] Core direction: merge the current branch (source) INTO the target branch.
</Purpose>

<Scope>
[P2] Target: Git repositories accessible via CLI. Agent must have git installed and available in PATH. Works with local and remote branches.
[P2] Excluded: non-git version control systems (SVN, Mercurial), GUI git clients, automated CI/CD merge pipelines.
</Scope>

<Inputs>
[P1] Current working directory must be inside a git repository.
[P1] User invocation: interactive (skill triggered without branch names) or direct (explicit source->target branch names provided).
</Inputs>

<Outputs>
[P1] Successful merge commit on target branch (or staged changes for squash).
[P2] Optional: pushed to remote, source branch deleted, user returned to original branch.
</Outputs>

<Constraints>
[P0] Do NOT auto-resolve conflicts.
[P0] User must confirm every decision point before execution.
[P0] Must not proceed with merge if repo state is invalid (not a git repo, dirty tree unresolved, detached HEAD without warning).
[P0] Core direction: merge the current branch (source) INTO the target branch.
</Constraints>

<Invariants>
[P0] User remains in control at every decision point. No automatic branch selection, conflict resolution, or push without explicit consent.
[P0] Source branch is always the current branch at skill invocation time. Target branch is always the branch the user selects to merge into.
[P0] Pre-merge state is always restorable via git merge --abort if merge has conflicts.
</Invariants>

<Failure Modes>
1. [P1] Not in git repository: git rev-parse fails → inform user and exit.
2. [P1] Merge already in progress: present continue/abort/inspect options.
3. [P1] Dirty working tree: warn user, offer stash or commit.
4. [P1] Detached HEAD: warn user, recommend checkout branch.
5. [P1] Checkout fails during branch switch: report error, offer stash/commit.
6. [P1] Merge conflicts: present 5 resolution options, do NOT auto-resolve.
</Failure Modes>

<Validation Strategy>
[P1] After checkout, verify `git branch --show-current` shows target branch.
[P1] After merge, verify `git status` shows clean working tree.
[P1] Post-merge: `git log --oneline -n 3` shows expected merge commit.
</Validation Strategy>

<Relationships>
[P2] Depends on: git CLI installed and accessible in PATH.
[P2] Related skills: sas-git-commit-and-push (post-merge push workflow).
</Relationships>

<Guarantees>
[P0] Pre-merge state is always restorable if merge has not completed.
[P0] No automatic conflict resolution — user controls every merge decision.
</Guarantees>

---

<Invocation Conditions>
[P1] Triggered when user asks to merge branches, review merge options, or handle merge conflicts.
[P1] Interactive mode: skill triggered without branch names (e.g., 'merge my branch').
[P1] Direct mode: skill triggered with explicit source->target (e.g., '/sas-git-merge feature/x -> develop').
</Invocation Conditions>

---

<Forbidden Usage>
[P0] Must NOT auto-resolve merge conflicts.
[P0] Must NOT push to remote without explicit user confirmation.
[P0] Must NOT delete source branch without explicit user confirmation.
[P0] Must NOT proceed if not in a git repository.
[P0] Must NOT merge in detached HEAD state without warning.
</Forbidden Usage>

---

<Phase Separation>
| Phase | Steps | Description |
|---|---|---|
| Phase 1: Pre-merge validation | Steps 1–3 | Verify repo state, check for conflicts/dirty tree/detached HEAD |
| Phase 2: Branch selection | Steps 4–5 | Discover targets, user selects, confirm direction |
| Phase 3: Merge execution | Steps 6–9 | Switch branch, select strategy, execute, handle conflicts |
| Phase 4: Post-merge | Step 10 | Report state, offer push/branch-switch/delete/undo |
</Phase Separation>

---

<Procedural Steps>

### Step 1: Repo Check
[P1] Run `git rev-parse --show-toplevel`.
[P1] If git rev-parse fails, inform user git operations not supported in current directory and exit.

### Step 1.5: Fetch Latest State
[P1] Run `git fetch --prune`.
[P1] If no remote, skip fetch silently.

### Step 2: Pre-Merge State Check
[P1] Run `git status`. IF merge in progress THEN inform user, present options (git merge --continue / git merge --abort / inspect conflict files), wait for decision.
[P1] Run `git status --porcelain`. IF uncommitted changes THEN warn user, offer stash (`git stash push -m "pre-merge stash"`) or commit, wait for decision.
[P1] Run `git branch --show-current`. IF empty (detached HEAD) THEN warn user, offer checkout branch first.

### Step 3: Branch Context
[P1] Run `git branch --show-current` and report current branch as source branch.

### Step 4: Discover Target Branches
[P1] Run `git branch --list --format='%(refname:short)'`. Filter out current branch.
[P2] Optionally include remote branches with `git branch -r --list --format='%(refname:short)'`.
[P1] Present as numbered list excluding current branch, separated into Local and Remote sections.

### Step 5: User Selection
[P1] Wait for user pick. Confirm: Merging <current-branch> into <target-branch>.
[P1] IF direct invocation with explicit branch names THEN validate both exist. IF current is into-branch THEN skip to Step 6. IF current is from-branch THEN proceed to Step 6. IF neither THEN warn and ask to switch to into-branch.

### Step 6: Switch to Target Branch
[P1] IF remote tracking branch THEN run `git fetch` first.
[P1] Confirm switch: 'Switching to <target-branch> to merge <source-branch> into it. Proceed?'
[P1] Upon confirmation, run `git checkout <target-branch>`.
[P1] IF checkout fails THEN report error and offer stash/commit.
[P1] Verify `git branch --show-current` shows <target-branch>.

### Step 7: Merge Strategy Selection
[P1] Present strategies: Fast-forward (default, no flag), No fast-forward (--no-ff), Fast-forward only (--ff-only), Squash (--squash).
[P2] Offer dry-run: `git merge --no-commit --no-ff <source-branch>`.
[P1] Ask strategy. IF unspecified THEN use default (fast-forward if possible).

### Step 8: Execute Merge
[P1] Run `git merge <strategy-flags> <source-branch>`.
[P1] IF clean non-squash merge THEN report success, show commit message, proceed to Step 10.
[P1] IF squash merge THEN stage changes, help craft commit (default: `Merge branch '<source-branch>' into <target-branch>`), run `git commit`. Proceed to Step 10.
[P1] IF already up to date THEN report and exit.
[P1] IF conflicts THEN proceed to Step 9.

### Step 9: Conflict Handling
[P0] Do NOT auto-resolve conflicts.
[P1] List conflicts: `git diff --name-only --diff-filter=U`.
[P1] Present options:
  1. Abort — `git merge --abort` (restore pre-merge state)
  2. Inspect — show conflict files
  3. Resolve manually — guide through resolution, `git add`, `git merge --continue`
  4. Accept source (--theirs) for all conflicted files
  5. Accept target (--ours) for all conflicted files
[P1] IF manual resolution THEN show conflict markers, guide editing and `git add`, run `git merge --continue`.

### Step 10: Post-Merge
[P1] Report: `git status` and `git log --oneline -n 3`.
[P1] Offer push. IF yes THEN `git push`. IF no upstream THEN `git push --set-upstream origin <branch>`.
[P1] Offer return to original branch: `git checkout <original-branch>`.
[P1] Offer delete source branch: `git branch -d` (safe), `git push origin --delete` (remote). Only with explicit confirmation.
[P1] Offer undo: `git reset --hard ORIG_HEAD` (warn about lost work).

</Procedural Steps>

---

<Edge Cases>
1. [P1] IF no remote THEN skip remote branch listing (see Step 4) and fetch (see Step 1.5).
2. [P1] IF already up to date THEN report and exit.
3. [P1] IF detached HEAD THEN warn, recommend checkout branch first (see Step 2).
4. [P1] IF shallow clone THEN warn about full history requirement (`git fetch --unshallow`).
5. [P1] IF untracked files THEN include in dirty-tree warning (see Step 2); offer .gitignore.
6. [P1] IF cross-repo subdirectory THEN operate from repo root (see Step 1).
7. [P1] IF target ahead of remote THEN warn about force push requirement (see Step 10).
8. [P1] IF only one branch THEN inform nowhere to merge to (see Step 4).
</Edge Cases>

---

<Examples>
[P2] Interactive: 'merge my feature branch' → current branch is `feature/user-auth` → targets: develop, main, origin/develop → pick 1 → merge into develop, --no-ff → success, offer push.
[P2] Direct: `/sas-git-merge feature/x -> develop` → validates, switches to develop, merges with default.
[P2] Conflict: merge fix/urgent-hotfix into develop → conflicts in app/auth.py, tests/test_auth.py → present 5 options → wait for decision.
</Examples>
