# mdd - Merge to Dev

Merge any branch into dev and push. AI resolves conflicts automatically.

## Usage

```bash
mdd.sh [BRANCH]
```

**Default:** current branch

## Examples

```bash
mdd.sh                      # Merge current branch to dev
mdd.sh feature/new-login    # Merge specific branch to dev
```

## Features

| Feature | Description |
|---------|-------------|
| Temp branch | Uses `temp-merge-branch` - never touches your local dev |
| No branch switching | Returns to your original branch when done |
| Auto stash | Stashes uncommitted changes, restores after |
| AI conflict resolution | cursor-agent (preferred) or claude (fallback) resolves conflicts |
| Human fallback | AI bails on business logic conflicts requiring judgment |
| Merge history | Uses `--no-ff` to preserve merge commits |

## How Conflicts Work

1. Merge fails with conflicts
2. cursor-agent reads both versions
3. AI merges intelligently, removes conflict markers
4. If AI can't resolve confidently -> aborts, you handle manually

Requires: `git`, `cursor-agent` or `claude` (in PATH)
