# mdd - Merge to Dev

Merge a branch into dev with automatic conflict resolution.

## Requirements

- `git`
- `cursor-agent` - for AI-powered conflict resolution

## Usage

```bash
mdd [BRANCH]
```

If no branch specified, uses current branch.

## What it does

1. Stashes uncommitted changes
2. Fetches latest from remote
3. Creates temp merge branch from origin/dev
4. Merges your branch into it
5. If conflicts: invokes cursor-agent to resolve
6. Pushes to origin/dev
7. Cleans up and restores stashed changes

## Examples

```bash
# Merge current branch to dev
mdd

# Merge specific branch to dev
mdd feature/my-feature
```

## Notes

- Cannot merge dev to dev
- If cursor-agent cannot resolve conflicts, it will abort and require manual intervention
- Original branch and working directory remain unchanged
