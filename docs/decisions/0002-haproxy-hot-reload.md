---
status: accepted
date: 2026-09-21
decision-makers: l-nmch
---

# Keep HAProxy, routes in a template, hot reload

## Context and problem statement

The router runs HAProxy in a container to publish services by SNI and HTTP host. How are the routes edited, and how does a change reach HAProxy without an outage?

## Decision drivers

* Reload without restarting the container.
* Routes editable by hand in the repository.
* No component that cannot run on this 32-bit ARM router.

## Considered options

* Keep HAProxy, edit `templates/haproxy.cfg.tftpl`, reload in place.
* A Kubernetes ingress as the edge.
* An HAProxy Terraform provider or its Data Plane API.

## Decision outcome

Chosen option: "keep HAProxy with a template and an in-place reload". `tofu apply` renders and pushes the file; a wrapper script (`templates/haproxy-run.sh`) reloads HAProxy. The wrapper runs a private copy of the configuration published atomically, refuses an invalid file (the old configuration keeps running) and keeps the last good copy for restarts.

### Consequences

* Good, because adding a route is one edit and one apply.
* Bad, because a valid but wrong configuration is loaded as is, and `tofu apply` succeeds even when HAProxy refuses the file: read the router log after an apply ([how-to](../how-to/reload-the-haproxy-configuration.md)).
* Bad, because a change to a container attribute still restarts it (a few seconds), and rate limiting is out of scope until the client address HAProxy sees is the real one.

### Confirmation

The router log shows `haproxy.cfg changed: reloading` followed by `Loading success`.

## Pros and cons of the options

### HAProxy with a template

* Good, because it works today.
* Bad, because routes are text, not data.

### A Kubernetes ingress

* Good, because it reuses a cluster tool.
* Bad, because a cluster ingress does not route outside its cluster (Hangar decision 0005), and the official Traefik image has no 32-bit ARM build.

### An HAProxy provider or Data Plane API

* Good, because it models the routes as resources.
* Bad, because no provider can express SNI-based backend switching.

## More information

Changing `entrypoint` or `cmd` of the production container in place once left it started but silent and unresponsive; only recreating it from its original definition recovered it. Validate wrapper changes on isolated throwaway containers first, then apply targeted. A data model for routes was written and then removed on purpose: do not add one back.
