#!/bin/bash

# Use provided branch name or get the current branch
branch_name="${1:-$(git branch --show-current)}"

# Check if we're trying to merge dev to dev
if [ "$branch_name" = "dev" ]; then
    echo "Cannot merge dev to dev."
    exit 1
fi

# Save current branch
current_branch=$(git branch --show-current)

# Stash any uncommitted changes
stashed=false
if ! git diff-index --quiet HEAD --; then
    echo "Stashing uncommitted changes..."
    git stash push -m "Auto-stash before merging $branch_name to dev"
    stashed=true
fi

# Fetch all remote branches
echo "Fetching remote branches..."
git fetch origin

# Check if branch exists locally or remotely
if ! git show-ref --verify --quiet "refs/heads/$branch_name"; then
    # Branch doesn't exist locally, check if it exists remotely
    if git show-ref --verify --quiet "refs/remotes/origin/$branch_name"; then
        echo "Branch $branch_name not found locally, checking out from remote..."
        git checkout -b "$branch_name" "origin/$branch_name"
        git checkout "$current_branch"
    else
        echo "Error: Branch $branch_name not found locally or remotely."
        if [ "$stashed" = true ]; then
            git stash pop
        fi
        exit 1
    fi
fi

# Fetch latest dev from remote
echo "Fetching latest dev..."
git fetch origin dev:dev 2>/dev/null || {
    # If dev is checked out in a worktree, fetch and merge instead
    echo "Dev branch is in a worktree, handling differently..."
    git fetch origin dev
}

# Merge the feature branch into remote dev
echo "Merging $branch_name into dev..."
# Create a temporary merge of dev and feature branch
git checkout -B temp-merge-branch origin/dev

if git merge "$branch_name" --no-ff -m "Merge $branch_name to dev"; then
    # Push directly to remote dev
    echo "Pushing to remote dev..."
    if git push origin temp-merge-branch:dev; then
        echo "Successfully merged and pushed to dev!"
        # Clean up temp branch
        git checkout "$current_branch"
        git branch -D temp-merge-branch
    else
        echo "Push failed. Cleaning up..."
        git checkout "$current_branch"
        git branch -D temp-merge-branch
        if [ "$stashed" = true ]; then
            git stash pop
        fi
        exit 1
    fi
else
    echo "Merge conflict detected. Invoking cursor-agent to resolve..."
    
    # Get list of conflicted files
    conflicted_files=$(git diff --name-only --diff-filter=U)
    
    if [ -z "$conflicted_files" ]; then
        echo "No conflicted files found but merge failed. Aborting..."
        git merge --abort
        git checkout "$current_branch"
        git branch -D temp-merge-branch 2>/dev/null
        if [ "$stashed" = true ]; then
            git stash pop
        fi
        exit 1
    fi
    
    echo "Conflicted files:"
    echo "$conflicted_files"
    
    # Invoke cursor-agent to resolve conflicts
    resolution_result=$(cursor-agent -p --force --model sonnet-4.5-thinking \
        "You are resolving git merge conflicts. The following files have conflicts:
$conflicted_files

Instructions:
1. Read each conflicted file and understand both versions (HEAD and incoming changes)
2. Intelligently merge the changes - keep functionality from both sides where appropriate
3. Remove all conflict markers (<<<<<<<, =======, >>>>>>>)
4. Ensure the resulting code is valid and functional
5. If you cannot resolve a conflict intelligently (e.g., conflicting business logic that requires human decision), respond with exactly: HUMAN_REQUIRED

After resolving, ensure no conflict markers remain in any file." 2>&1)
    
    # Check if human intervention is required
    if echo "$resolution_result" | grep -q "HUMAN_REQUIRED"; then
        echo "Cursor-agent requires human intervention to resolve conflicts."
        echo "Aborting merge..."
        git merge --abort
        git checkout "$current_branch"
        git branch -D temp-merge-branch 2>/dev/null
        if [ "$stashed" = true ]; then
            git stash pop
        fi
        exit 1
    fi
    
    # Check if any conflict markers remain
    if grep -rl "^<<<<<<<\|^=======\|^>>>>>>>" $conflicted_files 2>/dev/null; then
        echo "Conflict markers still present. Resolution failed."
        git merge --abort
        git checkout "$current_branch"
        git branch -D temp-merge-branch 2>/dev/null
        if [ "$stashed" = true ]; then
            git stash pop
        fi
        exit 1
    fi
    
    # Stage resolved files and complete merge
    echo "Staging resolved files..."
    echo "$conflicted_files" | xargs git add
    
    if git commit --no-edit; then
        echo "Conflict resolved by cursor-agent. Pushing to remote dev..."
        if git push origin temp-merge-branch:dev; then
            echo "Successfully merged and pushed to dev!"
            git checkout "$current_branch"
            git branch -D temp-merge-branch
        else
            echo "Push failed. Cleaning up..."
            git checkout "$current_branch"
            git branch -D temp-merge-branch
            if [ "$stashed" = true ]; then
                git stash pop
            fi
            exit 1
        fi
    else
        echo "Commit failed after resolution. Aborting..."
        git merge --abort 2>/dev/null
        git checkout "$current_branch"
        git branch -D temp-merge-branch 2>/dev/null
        if [ "$stashed" = true ]; then
            git stash pop
        fi
        exit 1
    fi
fi

# Pop stashed changes if any
if [ "$stashed" = true ]; then
    echo "Restoring stashed changes..."
    git stash pop
fi

echo "Done!"
