---
status: accepted
date: 2026-09-20
decision-makers: l-nmch
---

# Three configuration layers: factory, bootstrap script, OpenTofu

## Context and problem statement

The router was reset and rebuilt by hand once. Drift between the bootstrap script, the live router and the code caused an L2 MTU incident. Where does each kind of setting live?

## Decision drivers

* The bootstrap must stay a plain RouterOS script under the maintainer's control.
* OpenTofu should own only network objects, and only what it can also delete.

## Considered options

* Three layers: factory configuration, the maintainer's bootstrap script, OpenTofu for the rest.
* OpenTofu for everything, including Ethernet ports, and DNS settings.

## Decision outcome

Chosen option: "three layers".

* `defaults/default_configuration.rsc` is the MikroTik factory configuration. Never edit it.
* `defaults/base_configuration.rsc` is the maintainer's script that pre-provisions the router after a reset: DNS servers, hardening, certificates, services, Ethernet port MTU and L2MTU, which ports are disabled, the management LAN, and base users.
* OpenTofu owns VLANs, addresses, DHCP, DNS records, the firewall, NAT, containers, and the HAProxy configuration.

### Consequences

* Good, because a reset is a script plus `tofu apply`.
* Bad, because a system setting that OpenTofu cannot delete (the router API services) is set by hand and documented in the [reset how-to](../how-to/reset-and-bootstrap-the-router.md).

## Pros and cons of the options

### Three layers

* Good, because each layer has one owner.
* Bad, because one must know which layer a setting belongs to.

### OpenTofu for everything

* Good, because one tool.
* Bad, because an experiment that managed Ethernet ports and DNS in OpenTofu was stopped: the maintainer wants the bootstrap to be theirs, and all ports use the same large MTU (the VLAN MTU depends on the bridge, which depends on the ports).

## More information

The placeholders in the bootstrap script stay as they are (no templating).
