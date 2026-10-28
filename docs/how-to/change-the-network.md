---
type: how-to
audience: maintainer adding a VLAN, a flow or a public hostname
verified: 2026-10-27
---

# Change the network

Checklists for the three common changes. Each one touches more than one repository.

## Add a VLAN or a cluster

1. Network: one entry in `networks` (the VLAN, the router address, the DHCP pool and server, the `phorge` interface list membership and the `<name>-nodes` address list are derived), plus `dns_records`.
2. Ansible: inventory group, `firewall_allowed_ports` and `firewall_trusted_sources` in its `group_vars`.
3. FrontPlane: `clusters/<name>/setup/` (k0s config, `ip-pools.yml`, the interface name in `l2announcementpolicy.yml`) and the Traefik patches in `overlays/<name>/controllers/traefik/`.
4. If it is published: `ingress = 11` on its entry in `networks`, `templates/haproxy.cfg.tftpl`, then a router rule towards its ingress with `dst_ingress`.
5. Update this document.

## Add a flow between two VLANs

1. Router: a rule in `firewall_rules` with a unique `id`, `before = "defconf: drop invalid"` (forward accepts) and `in_interface` set.
2. Host: `firewall_allowed_ports` (or `firewall_published_ports` for Docker) in Ansible.
3. Pods: a NetworkPolicy or CiliumNetworkPolicy in FrontPlane if the destination is a pod.
4. After applying, check that the rule counts packets: `/ip firewall filter print stats`.

## Add a public hostname

1. DNS record at Cloudflare.
2. FrontPlane: an Ingress with class `traefik-public` and `cert-manager.io/cluster-issuer: public-issuer`.
3. `templates/haproxy.cfg.tftpl`: the host in the HTTP redirect ACLs and a `use_backend` line on the SNI frontend. After `tofu apply` the container reloads by itself.
4. A router rule from `containers` to that cluster's ingress, if it is a new cluster.

## Related

- [The network plan](../reference/network-plan.md)
