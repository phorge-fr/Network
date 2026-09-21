#!/bin/sh
# Runs HAProxy in master-worker mode as an unprivileged user and reloads it gracefully when haproxy.cfg changes.
# A RouterOS container cannot send signals, so the reload is triggered from inside.
# RouterOS creates the mounted directory without the execute bit and cannot run the container as another user, so
# this script stays root, reads the file and hands HAProxy a copy that lives in a directory owned by root: HAProxy
# runs as uid 99 with no capability and cannot change what it will run at the next start.
SRC=/usr/local/etc/haproxy/haproxy.cfg
DIR=/etc/haproxy-run
RUN=$DIR/haproxy.cfg

command -v setpriv >/dev/null || { echo "setpriv not found: refusing to run HAProxy as root" >&2; exit 1; }
mkdir -p "$DIR" && chmod 755 "$DIR" || { echo "cannot write $DIR" >&2; exit 1; }
echo "haproxy-run: uid=$(id -u) nofile=$(ulimit -Hn)"

# The image stops with SIGUSR1 (graceful) and RouterOS with SIGTERM: pass either one on to HAProxy.
# Installed first: PID 1 drops a signal that has no handler, so a stop right after the start would be lost.
pid=
stop() {
  rc=0
  if [ -n "$pid" ]; then
    kill -s "$1" "$pid" 2>/dev/null
    wait "$pid"
    rc=$?
  fi
  exit $rc
}
trap 'stop TERM' TERM INT
trap 'stop USR1' USR1

# A variable, not a function: HAProxy runs in the background and $! must be its own pid, not a subshell's
UNPRIV="setpriv --reuid=99 --regid=99 --clear-groups --no-new-privs --bounding-set=-all"

# Copy the file next to the running one and check the copy the way HAProxy will run it, unprivileged.
# On success the copy stays in place; on failure the reason is printed and the copy is removed.
stage() {
  cp "$SRC" "$RUN.new" && chmod 644 "$RUN.new" || { echo "cannot write $RUN.new"; return 2; }
  out=$($UNPRIV haproxy -c -f "$RUN.new" 2>&1) && return 0
  echo "$out"
  rm -f "$RUN.new"
  return 1
}

# A restart with a broken file would take the proxy down: keep the last configuration that passed the check
if err=$(stage); then
  mv "$RUN.new" "$RUN"
elif [ -f "$RUN" ]; then
  echo "haproxy.cfg is invalid, keeping the last good configuration" >&2
  echo "$err" >&2
else
  cp "$SRC" "$RUN" # nothing to fall back to: let HAProxy report the error
fi

$UNPRIV haproxy -W -db -f "$RUN" &
pid=$!
sleep 1
echo "haproxy-run: haproxy $(grep -E '^(Uid|CapEff|NoNewPrivs)' "/proc/$pid/status" | tr '\n\t' '  ')"

last=$(cksum < "$SRC")
while kill -0 "$pid" 2>/dev/null; do
  sleep 5 &
  wait $!
  now=$(cksum < "$SRC" 2>/dev/null) || continue
  [ "$now" = "$last" ] && continue
  last=$now
  if err=$(stage); then
    mv "$RUN.new" "$RUN"
    echo "haproxy.cfg changed: reloading"
    kill -USR2 "$pid"
  else
    echo "haproxy.cfg changed but is invalid, keeping the running configuration:" >&2
    echo "$err" >&2
  fi
done
wait "$pid"
