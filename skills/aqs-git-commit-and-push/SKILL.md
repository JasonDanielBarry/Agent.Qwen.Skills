---
name: aqs-git-commit-and-push
description: Commit all changes using conventional commit messages and push to remote. Use when the user asks to commit and push, or when work is ready to be saved and shared.
---

# Git Commit and Push

## Skill Goal

This skill streamlines the process of saving and sharing work by autonomously staging, committing, and pushing without asking for user permission. The user invoking the skill has already given implicit consent by requesting the action. It ensures commits follow project conventions, handles edge cases cleanly, and keeps the working tree in a predictable state — reducing friction when users want to persist their changes.

## Instructions

When invoked, this skill stages all changes, creates one or more conventional commits, and pushes to the remote repository. The working tree should be clean afterward.

### Steps

1. **Check current state:**
   - Run `git status` to see what has changed
   - Run `git diff HEAD` to review the full diff of all changes — use this to understand what was modified before writing the commit message
   - Run `git log -n 3 --oneline` to review recent commit message style
   - Check for in-progress operations: if `git status` mentions a merge, rebase, cherry-pick, or conflict in progress, display a warning but proceed with staging and committing.

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
   - **Do not ask the user for permission or confirmation.** Commit directly with your drafted message.

5. **Commit:**
   - Run `git commit -m "message"` (or multiple commits for separate logical groups)
   - Verify with `git status` that the working tree is clean

6. **Push:**
   - Run `git push`. If this fails with "no upstream branch", run `git push --set-upstream origin <branch-name>` instead.
   - Report the result, including the remote URL if a new branch was created.

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
→ Review status and diff, stage all, write commit message, commit, push

User: "/git-commit-and-push"
→ Same flow as above

User: "commit and push" (new branch with no upstream)
→ Same flow, but `git push` fails with "no upstream branch", so run `git push --set-upstream origin <branch>` and report success
