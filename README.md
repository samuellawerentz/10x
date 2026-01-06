# 10x

CLI tools that save you time. Built for Contacto devs, useful for anyone.

## What's Inside

| Script | What it does |
|--------|--------------|
| [jd](./jd/) | Deploy to Jenkins without leaving your terminal |
| [mdd](./mdd/) | Merge any branch to dev - handles conflicts with AI |

## Installation

```bash
# 1. Clone
git clone git@github.com:samuellawerentz/10x.git ~/10x

# 2. Make executable
chmod +x ~/10x/jd/jd.sh ~/10x/mdd/mdd.sh

# 3. Add to PATH (put this in your .bashrc or .zshrc)
export PATH="$PATH:$HOME/10x/jd:$HOME/10x/mdd"
```

That's it. Run `jd.sh -h` or `mdd.sh -h` to get started.
