# jd - Jenkins Deploy

Deploy contacto projects without opening Jenkins in your browser. Trigger builds, watch logs, check status, abort runaway builds - all from your terminal.

## Quick Start

```bash
# First, set up your credentials (one time)
export JENKINS_USER='your-username'
export JENKINS_TOKEN='your-api-token'  # Get from Jenkins > Your Profile > Configure > API Token
```

## Usage

```bash
jd.sh [REPO] [BRANCH] [OPTIONS]
```

Defaults to `contacto-console` on `dev` branch.

## Common Commands

```bash
jd.sh                                # Deploy contacto-console/dev to dev environment
jd.sh contacto-api staging           # Deploy contacto-api/staging to dev
jd.sh contacto-console dev --prod    # Deploy to production
jd.sh -w                             # Deploy and watch the build logs live
jd.sh -s                             # Check recent build status
jd.sh -a 3390                        # Abort build #3390
jd.sh -i                             # Interactive mode - pick repo/branch with fzf
```

## Options

| Flag | What it does |
|------|--------------|
| `--prod` | Deploy to production instead of dev |
| `-w` | Stream build logs in real-time |
| `-s` | Show last 10 builds with status |
| `-a NUMBER` | Abort a running build |
| `-i` | Pick repo and branch interactively (needs fzf) |
| `-h` | Show help |

## Requirements

- `JENKINS_USER` and `JENKINS_TOKEN` environment variables
- `fzf` (optional, for interactive mode - `brew install fzf`)
