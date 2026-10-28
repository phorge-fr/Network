# 0002: Keep HAProxy, routes in a template, hot reload

Status: accepted, live.

## Context

The router runs HAProxy in a container to publish services by SNI and HTTP host. Options considered: a Kubernetes ingress (rejected: the platform's ingress does not route outside its cluster, and the official Traefik image has no 32-bit ARM build for this router), or an HAProxy Terraform provider (none can express SNI-based backend switching or the needed request rules).

## Decision

Keep HAProxy. The routing rules are edited in `templates/haproxy.cfg.tftpl`; `tofu apply` renders and pushes the file and a wrapper script (`templates/haproxy-run.sh`) reloads HAProxy in place. The wrapper runs a private copy of the configuration published atomically, refuses an invalid file (the old configuration keeps running) and keeps the last good copy for restarts.

## Lessons

- Changing `entrypoint` or `cmd` of the production container in place once left it started but silent and unresponsive; only recreating it from its original definition recovered it. Validate wrapper changes on isolated throwaway containers first, then apply targeted.
- A syntactically valid but wrong configuration is not caught. `tofu apply` succeeds even when HAProxy refuses the file, so check the router log after an apply.
- A container attribute change still restarts the container (a few seconds).
- Rate limiting is out of scope until the client address HAProxy sees is the real one.
