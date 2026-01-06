# jd - Jenkins Deploy

Deploy contacto projects without opening Jenkins in your browser. Trigger builds, watch logs, check status, abort runaway builds - all from your terminal.

Connects to Jenkins at https://jenkins.plivops.com

## Screenshots

![Interactive mode](./FreezeFrame 2026-01-06 at 4.29.28 PM.png)

![Build triggered](./FreezeFrame 2026-01-06 at 4.29.36 PM.png)

![Watch mode](./FreezeFrame 2026-01-06 at 4.29.47 PM.png)

## Quick Start

```bash
# 1. Get your Jenkins API token
# Go to https://jenkins.plivops.com
# Click your name (top right) > Configure > API Token > Add new Token

# 2. Set credentials in your shell profile (~/.bashrc or ~/.zshrc)
export JENKINS_USER='your-username'
export JENKINS_TOKEN='your-api-token'

# 3. Reload your shell
source ~/.zshrc  # or ~/.bashrc

# 4. Deploy
jd.sh
```

## Usage

```bash
jd.sh [REPO] [BRANCH] [OPTIONS]
```

**Defaults:** contacto-console repo, dev branch, dev environment

## Features

### 1. Build Triggering

Trigger Jenkins builds with custom repo/branch selection:

```bash
jd.sh                                # contacto-console/dev to dev
jd.sh contacto-api staging           # contacto-api/staging to dev
jd.sh contacto-console dev --prod    # contacto-console/dev to PRODUCTION
```

**What happens:**
- Triggers Jenkins build with `build=true` and `postDeploy=true`
- Sets deployment target (dev or prod)
- Explicitly disables debug, qa, smokeTests to prevent accidental runs
- Returns Jenkins URL to view build progress

### 2. Watch Mode (-w)

Stream live console output while build runs:

```bash
jd.sh -w                    # Deploy and watch
jd.sh contacto-api dev -w   # Deploy specific repo and watch
```

**How it works:**
- Triggers the build
- Polls Jenkins queue until build starts (max 30s)
- Streams console output in real-time using progressive text API
- Shows "Build completed" when finished
- Auto-exits when build ends

**Example output:**
```
Triggering Jenkins build:
  Repo: contacto-console
  Branch: dev
  Deploy to: dev

✓ Build triggered successfully

Build queued, waiting for it to start...
Following build #3391

[console output streams here...]
Started by user samuel.lawerence
Building in workspace...
[INFO] Running npm install...
[INFO] Build successful
[INFO] Deploying to dev...
✓ Deployment complete

Build completed
```

### 3. Status Checking (-s)

View last 10 builds with color-coded status:

```bash
jd.sh -s                           # Status for default (contacto-console/dev)
jd.sh contacto-api staging -s      # Status for specific repo/branch
jd.sh -i -s                        # Pick repo/branch interactively
```

**Output includes:**
- Build number
- Status (SUCCESS, FAILURE, ABORTED, IN PROGRESS)
- Duration (minutes/seconds)
- Timestamp (YYYY-MM-DD HH:MM:SS)
- User who triggered the build

**Example output:**
```
Fetching build status for contacto-console/dev...

Build    Status                       Duration     Timestamp            Started By
-------------------------------------------------------------------------------------
#3391    ✓ SUCCESS                   4m 23s       2026-01-06 14:32:10  samuel.lawerence
#3390    ✗ FAILURE                   2m 15s       2026-01-06 13:45:22  john.doe
#3389    ⊘ ABORTED                   1m 5s        2026-01-06 13:20:18  samuel.lawerence
#3388    ⟳ IN PROGRESS              -            2026-01-06 13:15:00  jane.smith
#3387    ✓ SUCCESS                   5m 12s       2026-01-06 12:50:33  john.doe

View all builds: https://jenkins.plivops.com/job/contacto-io/job/contacto-console/job/dev
```

**Status colors:**
- Green ✓ = SUCCESS
- Red ✗ = FAILURE
- Yellow ⊘ = ABORTED
- Yellow ⟳ = IN PROGRESS

### 4. Build Abort (-a)

Stop a running or queued build:

```bash
jd.sh -a 3390                      # Abort build #3390 on default repo/branch
jd.sh contacto-api dev -a 3390     # Abort build #3390 on contacto-api/dev
```

**Example output:**
```
Aborting build #3390 on contacto-console/dev...
✓ Build #3390 aborted successfully

View build: https://jenkins.plivops.com/job/contacto-io/job/contacto-console/job/dev/3390
```

### 5. Interactive Mode (-i)

Use fzf to pick repo and branch with fuzzy search:

```bash
jd.sh -i           # Interactive repo/branch selection
jd.sh -i -w        # Interactive + watch mode
jd.sh -i -s        # Interactive + status check
```

**How it works:**
1. Fetches all repos from Jenkins (excludes _ prefixed repos)
2. Shows fzf picker for repo selection
3. Fetches branches for selected repo
4. Shows fzf picker for branch selection
5. Proceeds with selected repo/branch

**Requires fzf:** `brew install fzf`

## Command Reference

| Flag | Description | Example |
|------|-------------|---------|
| `REPO` | Repository name (positional) | `jd.sh contacto-api` |
| `BRANCH` | Branch name (positional) | `jd.sh contacto-api staging` |
| `--prod` | Deploy to production instead of dev | `jd.sh contacto-console main --prod` |
| `-w, --watch` | Stream build logs in real-time | `jd.sh -w` |
| `-s, --status` | Show last 10 builds with status | `jd.sh -s` |
| `-a, --abort NUMBER` | Abort specified build number | `jd.sh -a 3390` |
| `-i, --interactive` | Pick repo/branch with fzf | `jd.sh -i` |
| `-h, --help` | Show help message | `jd.sh -h` |

**Flag combinations:**
- `-i -w` = Interactive mode + watch
- `-i -s` = Interactive mode + status
- `REPO BRANCH -a NUMBER` = Abort on specific repo/branch

## Typical Workflows

### Deploy to Dev, Watch Progress
```bash
jd.sh -w
# Triggers build, shows live logs, exits when done
```

### Deploy to Production (Careful!)
```bash
jd.sh contacto-console main --prod
# Always double-check repo and branch for prod deploys
```

### Check Recent Build History
```bash
jd.sh -s
# Quick overview of last 10 builds without opening browser
```

### Kill a Stuck Build
```bash
jd.sh -s              # Find the build number
jd.sh -a 3390         # Abort it
```

### Deploy Different Repo/Branch
```bash
jd.sh -i              # Use interactive mode for fuzzy search
# OR
jd.sh contacto-api staging
```

### Monitor Multiple Repos
```bash
# Terminal 1
jd.sh contacto-console dev -w

# Terminal 2
jd.sh contacto-api staging -w
```

## Troubleshooting

### "JENKINS_USER and JENKINS_TOKEN environment variables must be set"

**Cause:** Credentials not configured

**Fix:**
```bash
# Add to ~/.zshrc or ~/.bashrc
export JENKINS_USER='your-username'
export JENKINS_TOKEN='your-api-token'

# Reload shell
source ~/.zshrc
```

Get token from: https://jenkins.plivops.com > Your Name > Configure > API Token

### "Error: fzf is not installed"

**Cause:** Interactive mode (-i) requires fzf

**Fix:**
```bash
brew install fzf
```

### "Build trigger failed (HTTP 403)"

**Cause:** Invalid credentials or token expired

**Fix:**
1. Generate new API token in Jenkins
2. Update JENKINS_TOKEN environment variable
3. Reload shell

### "Build trigger failed (HTTP 404)"

**Cause:** Repo or branch doesn't exist

**Fix:**
- Check spelling: `jd.sh -i` to see available repos/branches
- Verify branch exists in Jenkins: https://jenkins.plivops.com/job/contacto-io/job/REPO/

### "Could not determine build number" (watch mode)

**Cause:** Build took too long to start (>30s in queue)

**Fix:**
- Build is still running, just can't stream logs
- Check status manually: `jd.sh -s`
- Or visit Jenkins URL directly

### Status shows old builds

**Cause:** Caching or looking at wrong branch

**Fix:**
```bash
# Verify you're checking the right repo/branch
jd.sh contacto-console dev -s  # explicit repo/branch

# Use interactive mode to ensure correct selection
jd.sh -i -s
```

## Technical Details

**Jenkins API endpoints used:**
- Trigger build: `POST /job/contacto-io/job/REPO/job/BRANCH/buildWithParameters`
- Get status: `GET /job/contacto-io/job/REPO/job/BRANCH/api/json?depth=1`
- Stream logs: `GET /job/contacto-io/job/REPO/job/BRANCH/BUILD_NUMBER/logText/progressiveText`
- Abort build: `POST /job/contacto-io/job/REPO/job/BRANCH/BUILD_NUMBER/stop`
- List repos: `GET /job/contacto-io/api/json`
- List branches: `GET /job/contacto-io/job/REPO/api/json`

**Build parameters always set:**
- `build=true` - Always build
- `postDeploy=true` - Always run post-deploy hooks
- `deployDev=true` or `deployProd=true` - Target environment
- `debug=false, qa=false, smokeTests=false` - Disabled by default

**Dependencies:**
- `curl` - API requests (pre-installed on macOS)
- `python3` - JSON parsing for status display (pre-installed on macOS)
- `fzf` - Interactive mode (optional, install via brew)

## Requirements

- `JENKINS_USER` and `JENKINS_TOKEN` environment variables
- `curl` (pre-installed on macOS)
- `python3` (pre-installed on macOS)
- `fzf` (optional, for interactive mode: `brew install fzf`)
