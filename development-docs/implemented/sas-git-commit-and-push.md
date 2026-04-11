# sas-git-commit-and-push — Implemented

## Skill Location

`skills/sas-git-commit-and-push/`

## Description

Commits all changes using conventional commit messages and pushes to the remote repository.

## Key Behaviors

- Stages all changes (`git add -A`)
- Creates conventional commits following the `type(scope): description` format
- Pushes to remote; handles new branches with no upstream by setting upstream automatically
- Reports working tree status after commit
- Checks for in-progress operations (merge, rebase, cherry-pick) and warns before proceeding
- Matches recent commit message style from `git log -n 3`
- Runs `git diff HEAD` to review the full diff of all changes — the agent uses this to understand what was modified before writing the commit message (the diff is reviewed internally by the agent, not shown to the user)

## Commit Types Supported

| Type | Use Case |
|---|---|
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

## Edge Cases Handled

- **No changes:** Reports working tree is already clean. Nothing to do.
- **Untracked files in .gitignore:** Recommends adding to `.gitignore` rather than committing.
- **Mixed doc + code changes:** Commits code and docs as separate atomic commits.
- **New branch with no upstream:** Automatically sets upstream on push.
