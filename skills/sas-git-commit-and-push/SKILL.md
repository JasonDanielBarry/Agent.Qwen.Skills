<!-- compiled from: skills/sas-git-commit-and-push/SKILL.human.md | 2026-04-13T10:06:06Z -->

---
name: sas-git-commit-and-push
description: Commit all changes using conventional commit messages and push to remote. Use when the user asks to commit and push, or when work is ready to be saved and shared.
---

<Purpose>
[P1] Skill autonomously stages, commits, and pushes without asking user permission. User has given implicit consent by invoking the skill. Ensures commits follow project conventions, handles edge cases, keeps working tree predictable.
</Purpose>

<Scope>
[P1] Target: git repositories with staged or unstaged changes. Applies to any branch, any remote. Excluded: repositories with unresolvable merge conflicts requiring manual intervention, repositories without write access to remote.
</Scope>

<Inputs>
[P1] Working directory containing a git repository. Changes may include new files, modified files, deleted files. Repository may have a configured remote or be local-only.
</Inputs>

<Outputs>
[P1] One or more commits to local repository. Changes pushed to remote branch. Working tree clean after execution. Report of commit message(s), branch name, and remote URL if new branch created.
</Outputs>

<Constraints>
[P0] Must use Conventional Commits format: type(scope): description. Must explain why in body, not what. Must match style of recent commits from git log. [ref: sec-steps-004]
[P0] Must not edit committed files after push. Must not amend pushed commits. Must not force-push over shared history.
</Constraints>

<Invariants>
[P0] NEVER ask user for permission, confirmation, or approval. Do not present draft commit message for approval. Do not ask should I commit or ready to push. Stage, commit, and push directly.
[P0] NEVER skip committing changes because diff is large, complex, or touches many files.
[P0] NEVER leave working tree dirty after successful commit + push (unless edge cases prevent it). [ref: sec-edge-cases-001]
</Invariants>

<Failure Modes>
[P0] FM_001 — No git repository: git status fails with "fatal: not a git repository". Agent reports error and halts. No commit attempted.
IF current directory is not a git repository → report error, halt pipeline.
[P0] FM_002 — Push rejected: remote rejects push due to authentication failure, branch protection, or non-fast-forward. Agent reports error with remote message. Local commits remain intact.
IF git push fails with authentication or protection error → report remote error message, local commits preserved.
[P0] FM_003 — Unresolvable merge conflict in progress: git status shows MERGE_HEAD or REBASE_HEAD with conflicts. Agent warns user but proceeds with staging and committing if possible. [ref: sec-steps-001]
IF merge or rebase conflict is in progress → display warning, attempt staging and committing.
</Failure Modes>

<Validation Strategy>
[P1] Post-execution: Run git status to verify working tree is clean. Run git log -n 1 to verify commit message follows Conventional Commits format. Run git remote -v to verify remote URL if new branch.
</Validation Strategy>

<Relationships>
[P2] Depends on: git CLI available on system. Repository must be initialized (git init or git clone). Remote must be configured (git remote add) for push to succeed. Skill is standalone — no other skills or tools required.
</Relationships>

<Guarantees>
[P0] Working tree is clean after successful execution. All changes are committed with Conventional Commits format. Push succeeds or error is reported with remote message. No partial state: either all changes committed and pushed, or nothing changed.
</Guarantees>

<Invocation Conditions>
[P0] Skill is invoked when user requests commit and push action. User has given implicit consent. Skill executes without permission prompts. Agent must not ask for confirmation at any stage. [ref: sec-invariants-001]
</Invocation Conditions>

<Forbidden Usage>
[P0] Must not ask user for permission or confirmation. Must not present draft commit message for approval. Must not skip commit due to diff size. Must not force-push. Must not amend pushed commits. [ref: sec-invariants-001, sec-invariants-002]
</Forbidden Usage>

<Instructions>
[P1] When invoked, stage all changes, create one or more conventional commits, push to remote repository. Working tree must be clean afterward.
</Instructions>

<Steps>
1. [P1] Check current state: Run git status, git diff HEAD, git log -n 3 --oneline. Check for in-progress operations (merge, rebase, cherry-pick, conflict) — display warning but proceed.
2. [P1] Stage all changes: Run git add -A to stage everything (new, modified, deleted).
3. [P1] Determine commit strategy:
   - Single change → one commit with conventional commit message
   - Multiple independent changes → multiple atomic commits, each with own conventional message
   - Documentation → docs: prefix
   - Code fixes → fix: prefix
   - Refactoring → refactor: prefix
   - Feature → feat: prefix
   - Chore → chore: prefix
   - Tests → test: prefix
4. [P1] Write commit message: Follow Conventional Commits format type(scope): description. Body explains why not what. Match style of recent commits from git log -n 3. Do not ask user for permission or confirmation. [ref: sec-invariants-001]
5. [P1] Commit: Run git commit -m "message" (or multiple commits for separate logical groups). Verify with git status that working tree is clean.
6. [P1] Push: Run git push.
   IF git push fails with no upstream branch → run git push --set-upstream origin branch-name.
   Report result including remote URL if new branch created.
</Steps>

<Edge Cases>
[P1] EC_001 — No changes: Report working tree is already clean. Nothing to do.
IF working tree is clean after git status → report clean state, exit.
[P1] EC_002 — Untracked files in .gitignore: These must be added to .gitignore rather than committed.
[P1] EC_003 — Mixed doc + code changes: Commit code and docs as separate atomic commits. [ref: sec-steps-003]
IF changes include both documentation and code → commit code and docs as separate atomic commits.
</Edge Cases>

<Conventional Commit Types>
| Type | When to use |
|------|-------------|
| feat | New feature |
| fix | Bug fix |
| docs | Documentation-only |
| refactor | Restructuring no behavior change |
| chore | Maintenance, tooling, config |
| test | Test additions |
| ci | CI/CD pipeline |
| build | Build system, dependencies |
| perf | Performance improvements |
| revert | Revert previous commit |
</Conventional Commit Types>

<Examples>
[P2] Standard invocation:
User: "commit and push"
→ Review status and diff, stage all, write commit message, commit, push [ref: sec-steps-001 through sec-steps-006]

[P2] Skill command invocation:
User: "/git-commit-and-push"
→ Same flow as standard invocation [ref: sec-instructions-001]

[P2] New branch with no upstream:
User: "commit and push" (new branch with no upstream)
→ git push fails with "no upstream branch", run git push --set-upstream origin branch and report success [ref: sec-steps-006]
IF new branch with no upstream → run git push --set-upstream origin branch.
</Examples>
