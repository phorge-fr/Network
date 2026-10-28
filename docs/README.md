# Network documentation

Pages are grouped by what the reader wants, following [the organization's documentation standard](https://github.com/phorge-fr/.github/blob/main/docs/reference/documentation-standard.md).

## How-to guides

| Page | Task |
| --- | --- |
| [Reset and bootstrap the router](how-to/reset-and-bootstrap-the-router.md) | Rebuild the router from scratch and bring it back under OpenTofu |
| [Reload the HAProxy configuration](how-to/reload-the-haproxy-configuration.md) | Change a public route |
| [Change the network](how-to/change-the-network.md) | Add a VLAN, a flow or a public hostname |
| [Remove factory rules from the state](how-to/remove-factory-rules-from-the-state.md) | Clear a plan that wants to delete the factory firewall rules |

## Reference

| Page | Content |
| --- | --- |
| [Network plan](reference/network-plan.md) | Addresses, VLANs, wiring, hosts, public services and traffic flows |

## Explanation

| Page | Question it answers |
| --- | --- |
| [Architecture](explanation/architecture.md) | How the infrastructure and the repositories fit together |
| [Known inconsistencies](explanation/known-inconsistencies.md) | Where files and the live router disagreed |

## Decisions

| Record | Status |
| --- | --- |
| [0001 Three configuration layers](decisions/0001-three-configuration-layers.md) | accepted |
| [0002 Keep HAProxy, routes in a template, hot reload](decisions/0002-haproxy-hot-reload.md) | accepted |
| [0003 State and certificates are never committed](decisions/0003-state-and-certificates-not-committed.md) | accepted |
| [0004 Containers reach only what the rules allow](decisions/0004-container-network-containment.md) | accepted |
