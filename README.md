# 10x

Developer scripts and tools for Plivo/Contacto workflows.

## Scripts

| Script | Description |
|--------|-------------|
| [jd](./jd/) | Jenkins deploy - trigger builds from CLI |
| [mdd](./mdd/) | Merge to dev - auto-merge with conflict resolution |

## Installation

### For Humans

```bash
# Clone the repo
git clone git@github.com:plivo/10x.git ~/10x

# Make scripts executable
chmod +x ~/10x/jd/jd.sh
chmod +x ~/10x/mdd/mdd.sh

# Add to PATH (add to your .bashrc or .zshrc)
export PATH="$PATH:$HOME/10x/jd:$HOME/10x/mdd"
```

### For LLMs

```bash
# Clone the repo
git clone git@github.com:plivo/10x.git ~/10x

# Make scripts executable
chmod +x ~/10x/jd/jd.sh
chmod +x ~/10x/mdd/mdd.sh

# Add to PATH
export PATH="$PATH:$HOME/10x/jd:$HOME/10x/mdd"
```

After installation, scripts are available as `jd.sh` and `mdd.sh`.
