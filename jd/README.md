# jd - Jenkins Deploy

Trigger Jenkins builds for contacto projects from the command line.

## Requirements

- `JENKINS_USER` - your Jenkins username
- `JENKINS_TOKEN` - your Jenkins API token (get from Jenkins > User > Configure > API Token)
- `fzf` (optional) - for interactive mode

## Usage

```bash
jd [REPO] [BRANCH] [OPTIONS]
```

### Arguments

| Arg | Default | Description |
|-----|---------|-------------|
| REPO | contacto-console | Repository name |
| BRANCH | dev | Branch name |

### Options

| Flag | Description |
|------|-------------|
| `--prod` | Deploy to production |
| `-w` | Watch build progress |
| `-s` | Show recent build status |
| `-a BUILD_NUMBER` | Abort specified build |
| `-i` | Interactive mode (fzf) |
| `-h` | Help |

## Examples

```bash
# Build contacto-console dev, deploy to dev
jd

# Deploy to prod
jd contacto-console dev --prod

# Build and watch progress
jd contacto-api staging -w

# Show recent builds
jd -s

# Abort a build
jd -a 3390

# Interactive mode
jd -i
```

## Setup

```bash
export JENKINS_USER='your-username'
export JENKINS_TOKEN='your-api-token'
```
