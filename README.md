# 10x

CLI tools that automate tedious workflows. Built for CX devs, useful for anyone who wants to stop context-switching between terminal and browser.

## Why 10x?

Become 10x, save 5-10 minutes on every deploy and merge. That adds up fast when you're shipping multiple times a day. These scripts eliminate manual browser work, handle repetitive git operations, and use AI to resolve merge conflicts automatically.

## What's Inside

| Script | What it does |
|--------|--------------|
| [jd](./jd/) | Deploy from your terminal. Skip opening browsers, clicking through UI, and waiting for pages to load. Select project, branch, and deploy in seconds. |
| [mdd](./mdd/) | Merge any branch to dev with zero manual intervention without the branch switching headache. Detects conflicts, uses AI (Claude/OpenAI) to resolve them intelligently, and pushes the result. No more copy-pasting conflict markers. |

## Quick Start

```bash
# Deploy current branch to Jenkins
jd.sh

# Merge feature branch to dev (handles conflicts automatically)
mdd.sh feature/new-thing
```

Run with `-h` flag for all options and configuration details.

## Installation

### Install Manually

```bash
# 1. Clone
git clone git@github.com:samuellawerentz/10x.git ~/10x

# 2. Make executable
chmod +x ~/10x/jd/jd.sh ~/10x/mdd/mdd.sh

# 3. Add to PATH (put this in your .bashrc or .zshrc)
export PATH="$PATH:$HOME/10x/jd:$HOME/10x/mdd"
```

Restart your terminal or source your rc file. Done.

### Install via LLM

Give your LLM this prompt:

> Clone the 10x repo from `git@github.com:samuellawerentz/10x.git` into my home directory, make the scripts `jd/jd.sh` and `mdd/mdd.sh` executable, and add both directories to my PATH in my shell rc file. Then source the rc file.
