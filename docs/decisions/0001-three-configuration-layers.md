# 0001: Three configuration layers

Status: accepted.

## Decision

- `defaults/default_configuration.rsc` is the MikroTik factory configuration. Never edit it.
- `defaults/base_configuration.rsc` is the maintainer's own script that pre-provisions the router after a reset: DNS servers, hardening, certificates, services, Ethernet port MTU/L2MTU, which ports are disabled, the management LAN and base users.
- OpenTofu owns the network objects: VLANs, addresses, DHCP, DNS records, firewall, NAT, containers, HAProxy configuration.

## Why

The bootstrap must stay a plain RouterOS script under the maintainer's control. The router was once reset and rebuilt by hand, and drift between the bootstrap script, the live router and the code caused an L2 MTU incident. An experiment that managed Ethernet ports and the DNS settings in OpenTofu was stopped. All ports use the same large MTU (VLAN MTU depends on the bridge, which depends on the physical ports). The placeholders in the bootstrap script stay as they are (no templating).

## Consequences

System-level settings never move into OpenTofu. A setting that OpenTofu cannot delete (the router API services) is set by hand and documented in the runbook.
