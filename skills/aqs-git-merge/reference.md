# Git Merge — Reference

## Merge Strategy Comparison

| Strategy | Flag | Creates merge commit? | Preserves individual commits? | When to use |
|---|---|---|---|---|
| **Fast-forward** (default) | *(none)* | No | Yes | Linear history, no divergence |
| **No fast-forward** | `--no-ff` | Yes | Yes | Feature branches — keeps a clear merge point |
| **Fast-forward only** | `--ff-only` | No | N/A (fails if can't FF) | CI/CD pipelines — guarantees linear history |
| **Squash** | `--squash` | No (manual commit after) | No (all squashed into one) | Cleanup messy branch history before merging |

### Fast-forward
If the target branch has no diverging commits from the source, git simply moves HEAD forward. No merge commit is created. History stays linear.

```
A -- B -- C  (main)
         \
          D -- E  (feature)

After merge (fast-forward):

A -- B -- C -- D -- E  (main, feature)
```

### No fast-forward (`--no-ff`)
Always creates a merge commit, even if a fast-forward is possible. Preserves the fact that a feature branch existed.

```
A -- B -- C -------- M  (main)
         \          /
          D -- E --    (feature)
```

### Fast-forward only (`--ff-only`)
Fails if a fast-forward is not possible. Useful in automated systems to reject merges that would create merge commits.

### Squash (`--squash`)
Combines all changes from the source branch into a single set of staged changes on the current branch. No merge commit is created automatically — you must commit manually.

```
A -- B -- C -- S  (main)    ← S is a single commit containing all changes from feature
         \
          D -- E -- F  (feature)
```

## Conflict Resolution Walkthrough

### How Git Marks Conflicts

When two branches modify the same lines of the same file, git inserts conflict markers:

```python
<<<<<<< HEAD
def authenticate(username, password):
    return db.query(username)
=======
def authenticate(user, pwd):
    return session.validate(user, pwd)
>>>>>>> feature/auth-refactor
```

- `<<<<<<< HEAD` — start of the target branch's version (the branch you checked out to merge into)
- `=======` — separator
- `>>>>>>> feature/auth-refactor` — end of the source branch's version (the branch being merged in)

### Manual Resolution Steps

1. **Open the conflicted file** in your editor.
2. **Decide which version to keep** — current (HEAD), incoming (feature), or a hybrid.
3. **Remove the conflict markers** (`<<<<<<<`, `=======`, `>>>>>>>`) and any unwanted code.
4. **Save the file.**
5. **Mark as resolved:** `git add <file>`
6. **Repeat** for all conflicted files.
7. **Complete the merge:** `git merge --continue`

### Quick Resolution for All Conflicts

If you want to accept one side for *all* conflicted files at once:

```bash
# Accept the source branch's version for all conflicts (incoming)
git checkout --theirs -- <path>
git add -A
git merge --continue

# Accept the target branch's version for all conflicts (current)
git checkout --ours -- <path>
git add -A
git merge --continue
```

> **Warning:** This applies blindly to all conflicted files. Review the diff afterward.

## Git Command Reference

### Discovery

| Command | Purpose |
|---|---|
| `git rev-parse --show-toplevel` | Show the root directory of the repository |
| `git rev-parse --git-dir` | Show the `.git` directory path (used to verify repo exists) |
| `git branch --show-current` | Show the current branch name (empty output = detached HEAD) |
| `git branch --no-merged HEAD` | List local branches with unmerged commits |
| `git branch -r --no-merged HEAD` | List remote tracking branches with unmerged commits |
| `git branch -a` | List all branches (local + remote) |

### State Checks

| Command | Purpose |
|---|---|
| `git status` | Show working tree and merge state |
| `git status --porcelain` | Machine-parseable status output (check for dirty tree) |
| `git diff --name-only --diff-filter=U` | List files with unresolved conflicts |

### Merge Operations

| Command | Purpose |
|---|---|
| `git merge <branch>` | Merge `<branch>` into current branch |
| `git merge --no-ff <branch>` | Merge, always creating a merge commit |
| `git merge --ff-only <branch>` | Merge only if fast-forward is possible |
| `git merge --squash <branch>` | Squash all changes from `<branch>` into staged changes |
| `git merge --no-commit --no-ff <branch>` | Dry-run merge (preview without committing) |
| `git merge --continue` | Complete a merge after resolving conflicts |
| `git merge --abort` | Cancel the merge and restore pre-merge state |

### Undo

| Command | Purpose |
|---|---|
| `git merge --abort` | Cancel an in-progress merge |
| `git reset --hard ORIG_HEAD` | Undo the last merge commit (⚠️ discards all changes since the merge) |
| `git stash push -m "pre-merge stash"` | Temporarily save uncommitted changes before merging |
| `git stash pop` | Restore stashed changes |

### Push

| Command | Purpose |
|---|---|
| `git push` | Push current branch to its upstream remote |
| `git push --set-upstream origin <branch>` | Push and set upstream for a new branch |
| `git push --force-with-lease` | Force push only if no one else has pushed since your last fetch (safer than `--force`) |

## Safety Notes

### Why the Agent Never Auto-Resolves Conflicts

- **Loss of intent:** The agent doesn't know the developer's intent. Choosing "theirs" or "ours" blindly can silently introduce bugs or discard important logic.
- **Hybrid resolutions are common:** Often the correct resolution combines parts of both sides — something only a human can reliably decide.
- **Audit trail:** Auto-resolved conflicts can leave hidden bugs that surface later. Manual resolution ensures the developer reviews every conflict.

### Importance of a Clean Working Tree

Merging with a dirty working tree can:
- Obscure which changes came from the merge vs. what was already in progress.
- Cause unexpected conflicts if uncommitted changes overlap with the merge.
- Make it harder to abort cleanly if the merge goes wrong.

Always **stash or commit** before starting a merge.

### ORIG_HEAD Safety

After a merge commit, git saves the pre-merge HEAD as `ORIG_HEAD`. This is your escape hatch:

```bash
git reset --hard ORIG_HEAD
```

⚠️ **Warnings:**
- This is destructive — all work committed or staged *after* the merge will be lost.
- If you've already pushed the merge, you'll need a force push to undo it remotely.
- Consider `git revert` instead if the merge is already public.

## Edge Case Details

### Shallow Clones

CI environments and some tools create shallow clones (`git clone --depth 1`). A shallow clone may not have the full history needed for a merge.

**Check:** `git rev-parse --is-shallow-repository`
**Fix:** `git fetch --unshallow`

### Submodules

If the repository has submodules, merging branches that modify `.gitmodules` can leave submodules in an inconsistent state.

**After merge, run:** `git submodule update --init --recursive`

### Case-Insensitive Filesystems (Windows/macOS)

If two branches rename a file differently (e.g., `Auth.py` vs `auth.py`), case-insensitive filesystems may report spurious conflicts.

**Mitigation:** Ensure consistent file naming conventions across the team.

### Large Binary Files

Merges involving large binary files (images, compiled assets) cannot be resolved with text-based conflict markers. For these:
- Use `git checkout --ours <file>` or `git checkout --theirs <file>`
- Or manually replace the file with the correct version
