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

1. Stashes your uncommitted work (safety first)
2. Fetches latest dev from remote
3. Merges your branch into dev
4. If conflicts arise, cursor-agent attempts to resolve them
5. Pushes merged result to origin/dev
6. Restores your stashed changes

Your local branch stays untouched. You stay on your current branch.

## Requirements

- `git`
- `cursor-agent` (for AI conflict resolution)

## Good to Know

- Won't let you merge dev into dev (that's a no-op)
- If AI can't resolve a conflict confidently, it aborts and asks you to handle it manually
- Safe to run - doesn't modify your working branch
