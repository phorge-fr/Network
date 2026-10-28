---
type: how-to
audience: maintainer changing a public route or the HAProxy container
verified: 2026-09-26
---

# Reload the HAProxy configuration

The container runs `templates/haproxy-run.sh`, uploaded to `usb1/haproxy-etc/run.sh`. It starts HAProxy in master-worker mode and compares the checksum of `haproxy.cfg` every 5 seconds. When the file changes, it validates it with `haproxy -c` and, if it is valid, asks HAProxy to reload gracefully: existing connections finish on the old process, new ones use the new configuration, and the container does not restart. An invalid file is refused and the running configuration stays. Measured on the router, a change is live 5 to 15 seconds after `tofu apply`, because the check itself takes a few seconds on this CPU.

To add a public hostname, add its two lines (the redirect in `http-dispatcher` and the `use_backend` in `sni-dispatcher`) to `templates/haproxy.cfg.tftpl` and run `tofu apply`. The file in the repository is the source of truth: do not edit it on the router, because the next apply overwrites it and the container reloads the old version. `tofu apply` succeeds even when HAProxy refuses the file, because it only uploads it, so check that the router took the change into account:

```bash
ssh user@192.168.2.254 '/log print where message~"haproxy"'
```

`haproxy.cfg changed: reloading` followed by `Loading success` means it is live. `haproxy.cfg changed but is invalid` means the running configuration did not change, and the next lines give the reason.

The check only catches configurations that HAProxy cannot parse. A valid configuration that is wrong, such as a mistyped address or a removed route, is loaded as it is: fix the template and apply again.

If the container restarts while the file is invalid, for example after a reboot of the router, the script keeps running the last configuration that passed the check and logs it (`haproxy.cfg is invalid, keeping the last good configuration`). The file on the router is left as it was uploaded, so `tofu plan` shows no difference: the log is the only place where the refusal appears.

The old HAProxy process stays until its connections end (`timeout tunnel` is 6 hours), so several reloads in a row leave several processes running for a while. A change to `run.sh` itself only takes effect at the next container restart.

Changing an attribute of the container itself (image, user, entrypoint, mounts) recreates or restarts it: about a minute without service when the image changes, because the container is recreated, and about 10 seconds for a restart.

## Privileges

The container user is `0:0`, and HAProxy still runs as uid 99 (`haproxy`) with no capability and with `no_new_privs`. RouterOS creates every directory without the execute bit (`drw-r--r--`), and it offers no way to change that (`/file` has no permission argument, and neither has the provider), so an unprivileged container user cannot read the mounted directory. `run.sh` therefore stays root, reads `haproxy.cfg`, checks a copy as uid 99 and hands HAProxy that copy in `/etc/haproxy-run`, a directory owned by root that HAProxy can read but not write. The script refuses to start if `setpriv` is missing rather than run HAProxy as root.

Check it in the log after a start:

```bash
ssh user@192.168.2.254 '/log print where message~"haproxy-run"'
```

`haproxy-run: haproxy Uid: 99 99 99 99 CapEff: 0000000000000000 NoNewPrivs: 1` is the expected line. Anything else means HAProxy is not unprivileged.

## The image

The image is pinned by digest in `terraform.tfvars` (`arm32v7/haproxy@sha256:...`, HAProxy 3.4.4). RouterOS honours the digest and the provider reads it back without a difference. To upgrade, look up the digest of the new tag (`https://hub.docker.com/v2/repositories/arm32v7/haproxy/tags/<tag>`, field `digest`), put it in `terraform.tfvars` and apply: the container is recreated. RouterOS 7.19 has no `check-certificate` option for the registry, so the digest is the only integrity check on the pull. A container can hold at most `maxconn` 4096 connections, about 8,300 open files.

## Related

- [Decision: keep HAProxy and reload it in place](../decisions/0002-haproxy-hot-reload.md)
