# mdd - Merge to Dev

One command to merge your branch into dev and push. If there are conflicts, it uses AI (cursor-agent) to resolve them automatically.

## Usage

```bash
mdd.sh [BRANCH]
```

No branch? Uses your current branch.

## Examples

```bash
mdd.sh                      # Merge current branch to dev
mdd.sh feature/new-login    # Merge specific branch to dev
```

## How it Works

The script does a lot under the hood to keep things safe and clean:

### 1. Pre-flight Checks
- Validates you're not trying to merge dev to dev (blocked)
- Saves your current branch reference

### 2. Stashing Uncommitted Changes
If you have uncommitted work, it stashes everything with a descriptive message:
```
Auto-stash before merging [branch-name] to dev
```
This gets restored at the end, even if something fails.

### 3. Fetching Remote Branches
Runs `git fetch origin` to get latest remote state.

If your branch doesn't exist locally but exists on remote, it checks out a local copy first.

### 4. Creating Temporary Merge Branch
Instead of touching your local dev, it creates `temp-merge-branch` from `origin/dev`:
```bash
git checkout -B temp-merge-branch origin/dev
```

This keeps your local branches pristine.

### 5. Merging with --no-ff
Attempts to merge your branch with `--no-ff` (no fast-forward):
```bash
git merge [branch] --no-ff -m "Merge [branch] to dev"
```

This preserves merge history even for simple merges.

### 6. AI Conflict Resolution
If conflicts occur, cursor-agent (Claude Sonnet 4.5) steps in:

**What the AI does:**
- Reads each conflicted file
- Understands both versions (HEAD from dev, incoming from your branch)
- Intelligently merges changes, preserving functionality from both sides
- Removes all conflict markers (`<<<<<<<`, `=======`, `>>>>>>>`)
- Validates resulting code is syntactically valid

**AI safety checks:**
- If business logic conflicts require human judgment, AI responds with `HUMAN_REQUIRED` and aborts
- If conflict markers remain after AI resolution, merge aborts
- If commit fails after resolution, merge aborts

### 7. Push to origin/dev
On successful merge (clean or AI-resolved):
```bash
git push origin temp-merge-branch:dev
```

This pushes directly to `origin/dev` without modifying your local dev branch.

### 8. Cleanup
- Switches back to your original branch
- Deletes `temp-merge-branch`
- Restores stashed changes if any

Your working tree ends up exactly how you left it.

## What Happens When

### Clean Merge (No Conflicts)
```
Stashing uncommitted changes...
Fetching remote branches...
Fetching latest dev...
Merging feature/new-login into dev...
Pushing to remote dev...
Successfully merged and pushed to dev!
Restoring stashed changes...
Done!
```

Your branch merged cleanly. No drama.

### Merge with Conflicts (AI Resolves)
```
Merge conflict detected. Invoking cursor-agent to resolve...
Conflicted files:
src/components/Login.tsx
src/utils/auth.ts

Staging resolved files...
Conflict resolved by cursor-agent. Pushing to remote dev...
Successfully merged and pushed to dev!
```

AI read both versions, merged intelligently, and pushed the result.

### Merge with Conflicts AI Can't Resolve
```
Merge conflict detected. Invoking cursor-agent to resolve...
Conflicted files:
src/billing/calculator.ts

Cursor-agent requires human intervention to resolve conflicts.
Aborting merge...
```

When AI detects conflicting business logic (e.g., different pricing calculations), it bails and leaves it to you. Handle it manually, then rerun.

### Branch Doesn't Exist
```
Branch feature/typo not found locally, checking out from remote...
Error: Branch feature/typo not found locally or remotely.
```

If the branch doesn't exist anywhere, script exits cleanly with stash restored.

### Push Fails (Rare)
```
Push failed. Cleaning up...
```

If `origin/dev` was updated between fetch and push, the push fails. Script cleans up temp branch and restores stash. Just rerun - it'll fetch the latest dev and try again.

### Merge Fails Without Conflicts (Very Rare)
```
No conflicted files found but merge failed. Aborting...
```

Git merge failed but didn't produce conflict markers. Usually means git encountered an internal error. Check git status manually and retry.

## Requirements

- `git`
- `cursor-agent` CLI tool (for AI conflict resolution)

Make sure cursor-agent is in your PATH and properly configured.

## Troubleshooting

### "Dev branch is in a worktree, handling differently..."
Your dev branch is checked out in a git worktree. Script handles this automatically by fetching differently. No action needed.

### Conflict markers still present after resolution
AI resolution failed to clean up conflict markers. This triggers abort. Fix conflicts manually:
```bash
git checkout dev
git pull origin dev
git merge feature/your-branch
# Resolve conflicts manually
git commit
git push origin dev
```

### Stash pop fails
If you modified files after running mdd that conflict with stashed changes, git will warn you. Resolve stash conflicts manually:
```bash
git stash list  # Find your stash
git stash show stash@{0}  # Preview changes
git stash pop  # Try again or use --index
```

### Script hangs during cursor-agent invocation
cursor-agent might be waiting for input or hit an error. Kill with Ctrl+C. Script will leave temp-merge-branch around:
```bash
git branch -D temp-merge-branch
```

## Good to Know

- Won't let you merge dev into dev (that's a no-op)
- If AI can't resolve a conflict confidently, it aborts and asks you to handle it manually
- Safe to run - doesn't modify your working branch or local dev
- Creates temp branches internally (`temp-merge-branch`) - transparent to you
- Uses `sonnet-4.5-thinking` model for conflict resolution (high quality, slower)
- Preserves merge history with `--no-ff` even for simple merges
