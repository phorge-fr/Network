---
type: explanation
audience: maintainer deciding what to clean up in the network configuration
verified: 2026-10-27
---

# Known inconsistencies

Things that disagree between files, or between a file and the live router, as observed on 2026-09-20. Check an item before relying on it: some may be fixed since.

1. DHCP pools span `.1` to `.253` of every cluster VLAN, so they overlap the nodes (`.1`-`.3`), the API virtual IP (`.4`) and the Cilium pool (`.10`-`.20`).
2. The `nfs-uncritical` StorageClass on `control` and `core` points to NFS server 10.6.0.1. No 10.6.0.0/24 network exists on the router.
3. HAProxy targets 10.1.0.11 that the firewall does not allow (about 406,000 packets dropped by `Drop Containers to phorge` in the 3 days before 2026-09-20, most of them towards 10.10.0.1-3:8443 until `Allow Hproxy to Incus cluster API` was added).
4. The GPU host is `ai-z440-01` in the inventory, holds a DHCP lease (10.5.0.4) under the hostname `hpc1`, has no DNS record, and is outside `ai-nodes` (10.5.0.1-2). The HPC monitoring config scrapes `hpc0.phorge`.
5. The FrontPlane README bootstraps Flux from a repository called `Hangar`.
6. The three clusters share the pod and service CIDRs (10.244.0.0/16, 10.96.0.0/12), which rules out a future cluster mesh or direct pod routing between them.
7. `base_configuration.rsc` disables `ether10`, the intended switch uplink.
