# AGENTS.md: Network

Instructions for anyone working in this repository, human or AI assistant. The organization-wide rules (issues, pull requests, time tracking, security reporting) are in [phorge-fr/.github](https://github.com/phorge-fr/.github/blob/main/AGENTS.md) and [GOVERNANCE.md](https://github.com/phorge-fr/.github/blob/main/GOVERNANCE.md); this file only adds what is specific to Network.

## What this repository is

The OpenTofu configuration and bootstrap scripts of the edge router (a MikroTik running RouterOS 7). It owns VLANs, addressing, DHCP, DNS records, the firewall, NAT, and the container that runs HAProxy to publish services. Start with [docs/architecture.md](docs/architecture.md); the rebuild procedure is [docs/runbook-reset.md](docs/runbook-reset.md).

Three layers, each with an owner ([decision 0001](docs/decisions/0001-three-configuration-layers.md)):

| Layer | File | Rule |
| --- | --- | --- |
| Factory configuration | `defaults/default_configuration.rsc` | Never edit |
| Bootstrap script | `defaults/base_configuration.rsc` | The maintainer's own script. Interface MTU/L2MTU, port enable/disable, router system settings (DNS servers, NTP, services), certificates and users' base live here. Edit only when asked |
| OpenTofu | `*.tf`, `terraform.tfvars`, `templates/` | Everything else: VLANs, addresses, DHCP, DNS records, firewall, NAT, containers, HAProxy configuration |

When a finding concerns a system-level setting, the answer is "this goes in `base_configuration.rsc`", not a new Terraform resource.

## Workflow

- One issue per change, a short branch cut from the current `origin/main`, one pull request with `Closes #N`. Never commit to `main`. Text is in English.
- `main` is protected: the pull request needs `governance / pr-governance`.
- A change that affects the Kubernetes clusters (a new flow between clusters, a new public host name) usually needs a matching change in `phorge-fr/Hangar`. The router denies traffic between workload VLANs by default: **every new cross-cluster flow needs an explicit `accept` rule here**, or it silently times out.

## Running OpenTofu

- Load the credentials first: `source .env` (gitignored). The provider verifies the router certificate against `certs/router-ca.pem` (gitignored, fetched as in the runbook); `TF_VAR_insecure_tls=true` is for the first run after a reset only.
- The state is never committed, even encrypted, and neither is `certs/`. State encryption is on; its passphrase exists only in `.env`.
- `tofu fmt`, `tofu validate`, then `tofu plan`. For anything touching production, use a **targeted plan** (`tofu plan -target=...`) to prove the blast radius.
- **The maintainer runs `tofu apply`**, not the assistant. Prepare the change, show the targeted plan, give the exact command, explain in one sentence what it changes. Do not build side setups (blue/green, extra containers) unless asked; when told to test on production, test the real object and keep the instructions short.

## Rules specific to this repository

- Never put interface MTU, port state or router system settings in OpenTofu. Ports are off limits unless the maintainer says otherwise. The placeholders in `base_configuration.rsc` stay as they are.
- `prevent_destroy` guards the bridge, its ports, the VLANs and the IP addresses. The firewall order is managed with `routeros_move_items` and must match the live order.
- HAProxy routes are edited in `templates/haproxy.cfg.tftpl`; `tofu apply` pushes the file and the container reloads by itself ([decision 0002](docs/decisions/0002-haproxy-hot-reload.md)). Do not re-add a Terraform data model for routes. Changing a container attribute restarts it; do not change `entrypoint` or `cmd` of the production container in place.
- A new public host name needs a route in the HAProxy template (SNI and HTTP redirect): the edge does not forward unknown hosts to the right cluster.
- `api-ssl` of the router and the monitoring user's password are partly manual, see `phorge-fr/Hangar` `docs/runbooks/router-monitoring.md`.

## Security reports

This repository is public. Network security reports, weakness lists and live-state evidence go to `reports/` (gitignored), never to `docs/`. `docs/` holds what is already public or harmless: address plan, topology, flows, runbooks. Never commit the public WAN address, MAC addresses, credentials or a list of exploitable weaknesses. See the organization `SECURITY.md`.
