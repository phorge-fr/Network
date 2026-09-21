#!/bin/sh
# Runs HAProxy in master-worker mode and reloads it gracefully when haproxy.cfg changes.
# A RouterOS container cannot send signals, so the reload is triggered from inside.
CFG=/usr/local/etc/haproxy/haproxy.cfg
GOOD=$CFG.good

# A restart with a broken file would take the proxy down: fall back to the last configuration that passed the check
if ! haproxy -c -q -f "$CFG" 2>/dev/null && [ -f "$GOOD" ]; then
  echo "haproxy.cfg is invalid, restoring the last good configuration" >&2
  cp "$GOOD" "$CFG"
fi
cp "$CFG" "$GOOD"

haproxy -W -db -f "$CFG" &
pid=$!

# The image stops with SIGUSR1 (graceful) and RouterOS with SIGTERM: pass either one on to HAProxy
stop() {
  kill -s "$1" "$pid" 2>/dev/null
  wait "$pid"
  exit $?
}
trap 'stop TERM' TERM INT
trap 'stop USR1' USR1

last=$(cksum < "$CFG")
while kill -0 "$pid" 2>/dev/null; do
  sleep 5 &
  wait $!
  now=$(cksum < "$CFG" 2>/dev/null) || continue
  [ "$now" = "$last" ] && continue
  last=$now
  if out=$(haproxy -c -f "$CFG" 2>&1); then
    echo "haproxy.cfg changed: reloading"
    cp "$CFG" "$GOOD"
    kill -USR2 "$pid"
  else
    echo "haproxy.cfg changed but is invalid, keeping the running configuration:" >&2
    echo "$out" >&2
  fi
done
wait "$pid"
