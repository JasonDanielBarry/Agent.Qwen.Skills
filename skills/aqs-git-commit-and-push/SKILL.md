---
name: aqs-git-commit-and-push
description: Commit all changes using conventional commit messages and push to remote. Use when the user asks to commit and push, or when work is ready to be saved and shared.
---

# Git Commit and Push

## Instructions

When invoked, this skill stages all changes, creates one or more conventional commits, and pushes to the remote repository. The working tree should be clean afterward.

### Steps

1. **Check current state:**
   - Run `git status` to see what has changed
   - Run `git diff HEAD` to review the full diff of all changes
   - Run `git log -n 3 --oneline` to review recent commit message style

2. **Stage all changes:**
   - Run `git add -A` to stage everything (new, modified, deleted)

3. **Determine commit strategy:**
   - **Single logical change:** One commit with a conventional commit message
   - **Multiple independent changes:** Multiple atomic commits, each with its own conventional commit message
   - **Documentation-only changes:** Use `docs:` prefix
   - **Code fixes:** Use `fix:` prefix
   - **Refactoring (no behavior change):** Use `refactor:` prefix
   - **Feature work:** Use `feat:` prefix
   - **Chore/misc:** Use `chore:` prefix
   - **Test changes:** Use `test:` prefix

4. **Write commit message:**
   - Follow Conventional Commits format: `type(scope): description`
   - Body should explain *why*, not *what*
   - Match the style of recent commits (from `git log -n 3`)

5. **Commit:**
   - Run `git commit -m "message"` (or multiple commits for separate logical groups)
   - Verify with `git status` that the working tree is clean

6. **Push:**
   - Run `git push`
   - Report the result

### Edge Cases

- **No changes:** Report that the working tree is already clean. Nothing to do.
- **Untracked files in .gitignore:** These should be added to .gitignore rather than committed.
- **Mixed doc + code changes:** Commit code and docs as separate atomic commits.

### Conventional Commit Types

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

## Examples

User: "commit and push"
→ Stage all, review changes, commit, push

User: "/git-commit-and-push"
→ Stage all, review changes, commit, push
