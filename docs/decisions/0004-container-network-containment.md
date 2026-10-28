# 0004: Containers reach only what the rules allow

Status: accepted, applied.

A process in a RouterOS container runs with all capabilities and the version in use offers no way to drop them, so the network is the containment. The forward chain drops traffic from the containers bridge that is not explicitly allowed, and an anti-spoof rule drops packets whose source is not one of the containers' own addresses (the address list is derived from the `veths` variable). The accept rules for HAProxy are bound to that address list. The detailed analysis is kept in the private report, not here.
