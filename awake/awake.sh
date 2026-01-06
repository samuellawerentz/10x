#!/bin/bash

# Prevent Mac from sleeping
# Usage: awake [minutes]
#        awake stop
#        awake status

PIDFILE="/tmp/awake.pid"

stop_awake() {
    if [[ -f "$PIDFILE" ]]; then
        pid=$(cat "$PIDFILE")
        if kill -0 "$pid" 2>/dev/null; then
            kill "$pid" 2>/dev/null
            rm -f "$PIDFILE"
            echo "Stopped (PID: $pid)"
            return 0
        fi
        rm -f "$PIDFILE"
    fi
    echo "Not running"
    return 1
}

case "$1" in
    stop)
        stop_awake
        exit 0
        ;;
    status)
        if [[ -f "$PIDFILE" ]] && kill -0 "$(cat "$PIDFILE")" 2>/dev/null; then
            echo "Running (PID: $(cat "$PIDFILE"))"
        else
            echo "Not running"
        fi
        exit 0
        ;;
    "")
        # Stop existing, run indefinitely
        stop_awake 2>/dev/null
        caffeinate -is &
        echo $! > "$PIDFILE"
        disown
        echo "Awake indefinitely. Use 'awake stop' to stop."
        ;;
    *)
        if ! [[ "$1" =~ ^[0-9]+$ ]]; then
            echo "Usage: awake [minutes] | stop | status"
            exit 1
        fi
        
        # Stop existing, run with timeout
        stop_awake 2>/dev/null
        minutes=$1
        
        caffeinate -is -t $((minutes * 60)) &
        echo $! > "$PIDFILE"
        disown
        
        echo "Awake for $minutes min. Use 'awake stop' to stop early."
        ;;
esac
