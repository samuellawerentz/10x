# awake - Prevent Mac Sleep

Keep your Mac awake. Runs in background, survives terminal close.

## Usage

```bash
awake [minutes]     # Stay awake for N minutes
awake               # Stay awake indefinitely
awake stop          # Stop keeping awake
awake status        # Check if running
```

## Examples

```bash
awake 60            # Awake for 1 hour
awake 480           # Awake for 8 hours (full workday)
awake               # Awake until manually stopped
awake stop          # Stop early
```

## Features

| Feature | Description |
|---------|-------------|
| Background | Runs detached from terminal |
| Survives | Keeps running after terminal closes |
| Auto-stop | Stops automatically after timeout |
| PID tracking | Stores PID in `/tmp/awake.pid` |
| Single instance | Stops existing before starting new |

Uses macOS `caffeinate` under the hood.

Requires: `caffeinate` (system binary at `/usr/bin/caffeinate`, always available on macOS)
