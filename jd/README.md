# jd - Jenkins Deploy

Deploy CX projects from terminal. Trigger builds, watch logs, check status, abort builds.

## Screenshots

![Interactive mode](screenshot-1.png)

![Build triggered](screenshot-2.png)

![Watch mode](screenshot-3.png)

## Setup

```bash
export JENKINS_USER='your-username'
export JENKINS_TOKEN='your-api-token'  # Get from Jenkins > Your Name > Configure > API Token
```

## Usage

```bash
jd [REPO] [BRANCH] [OPTIONS]

# Examples
jd # Deployes contacto-console dev branch to dev env
jd contacto-core # Deploys contacto-core dev branch to dev
jd contacto-core -s # Displays status of dev branch build
jd contacto-core feature/xxx # Deploy feature/xxx to dev env
jd contacto-core main --prod # Deploy contacto-core main branch to prod
```

**Defaults:** `contacto-console` repo, `dev` branch, `dev` environment

## Features

| Flag | Description | Example |
|------|-------------|---------|
| (none) | Trigger build | `jd.sh` or `jd contacto-api staging` |
| `--prod` | Deploy to production | `jd contacto-console main --prod` |
| `-w` | Watch - stream live logs | `jd -w` |
| `-s` | Status - show last 10 builds | `jd -s` |
| `-a NUM` | Abort build | `jd -a 3390` |
| `-i` | Interactive - fzf picker | `jd -i` |

Combine flags: `jd -i -w` (interactive + watch)

Requires: `curl`, `python3` (pre-installed), `fzf` (for `-i`, install via `brew install fzf`)
