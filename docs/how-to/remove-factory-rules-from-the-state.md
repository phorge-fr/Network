---
type: how-to
audience: maintainer whose plan proposes to delete the factory firewall rules
verified: 2026-09-26
---

# Remove factory rules from the state

The factory (defconf) firewall rules are not declared in `terraform.tfvars`. If an earlier session imported them into the state, a plan proposes to delete them from the router. Remove the state entries instead of applying:

```bash
tofu state list | grep defconf
tofu state rm '<address from the list>'
```

The `special dummy rule to show fasttrack counters` entries are dynamic and are never managed.
