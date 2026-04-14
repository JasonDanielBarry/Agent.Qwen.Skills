<!-- compiled from: skills/sas-git-commit-and-push/SKILL.human.md | 2026-04-14T10:00:00Z -->

---
name: sas-git-commit-and-push
description: Commit all changes using conventional commit messages and push to remote. Use when the user asks to commit and push, or when work is ready to be saved and shared.
---

<purpose>
[P0] Skill autonomously stages, commits, and pushes without asking user permission. User has given implicit consent by invoking the skill.
</purpose>

<scope>Target: git repositories with staged or unstaged changes. Excluded: repos with unresolvable merge conflicts requiring manual intervention.</scope>

<inputs>Working directory containing git repo. Changes may include new/modified/deleted files. Remote may or may not be configured.</inputs>

<outputs>
[P0] One or more commits with Conventional Commits format. Changes pushed to remote. Working tree clean.
</outputs>

<rules>
[P0] NEVER ask user for permission, confirmation, or approval. Stage, commit, and push directly.
[P0] NEVER skip committing because diff is large, complex, or touches many files.
[P0] NEVER leave working tree dirty after successful commit + push.
[P0] Must use Conventional Commits format: type(scope): description. Body explains why, not what. Match style of recent commits.
[P0] Must not edit committed files after push. Must not amend pushed commits. Must not force-push over shared history.
</rules>

<phase_separation>
1. Check state: `git status`, `git diff HEAD`, `git log -n 3 --oneline`. If merge/rebase/cherry-pick/conflict in progress → warn but proceed.
2. Stage all changes: `git add -A`.
3. Determine commit strategy:
   - Single change → one commit
   - Multiple independent changes → multiple atomic commits
   - Code+doc changes → separate commits (EC_003)
   - Prefix by type: feat/fix/docs/refactor/chore/test/ci/build/perf/revert
4. Write commit message: `type(scope): description`. Body explains why. Match recent commit style. Do not ask permission.
5. Commit: `git commit -m "message"`. Verify `git status` clean.
6. Push: `git push`.
   IF no upstream → `git push --set-upstream origin <branch>`. Report result with remote URL.

**Failure handling:**
- Not a git repo: report error, halt.
- Push rejected (auth/protection/non-fast-forward): report remote error, local commits preserved.
- Unresolvable merge conflict: warn but proceed with staging/committing.

**Edge cases:**
- No changes: "Working tree already clean." Exit.
- Untracked files in .gitignore: add to .gitignore, not committed.
- Mixed doc+code: commit separately (EC_003).
</phase_separation>

<commit_types>
| feat | New feature | fix | Bug fix | docs | Documentation | refactor | Restructuring | chore | Maintenance | test | Tests | ci | CI/CD | build | Build system | perf | Performance | revert | Revert |
</commit_types>
