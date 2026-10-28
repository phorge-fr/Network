---
status: accepted
date: 2026-09-21
decision-makers: l-nmch
---

# Containers reach only what the rules allow

## Context and problem statement

A process in a RouterOS container runs with all capabilities, and the RouterOS version in use offers no way to drop them. If a container were compromised, what could it reach?

## Considered options

* Contain the containers at the network: forward drop from the containers bridge unless allowed, plus anti-spoofing.
* Rely on the container user and image alone.

## Decision outcome

Chosen option: "contain at the network". The forward chain drops traffic from the containers bridge that is not explicitly allowed, and an anti-spoof rule drops packets whose source is not one of the containers' own addresses (the address list is derived from the `veths` variable). The accept rules for HAProxy are bound to that address list.

### Consequences

* Good, because a compromised container reaches only its allowed destinations.
* Bad, because every new container flow needs an explicit rule.

### Confirmation

The `ctr-spoof` and `ctr-drop` log counters stay at zero in normal operation (`/ip firewall filter print stats where log-prefix~"ctr-"`).

## Pros and cons of the options

### Contain at the network

* Good, because it does not depend on the container.
* Bad, because more rules to maintain.

### Rely on the container

* Good, because simple.
* Bad, because root in the container has every capability.

## More information

The detailed analysis is kept in the private report, not here.
