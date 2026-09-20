# Network

![Phorge logo](https://avatars.githubusercontent.com/u/187407936?s=200&v=4)

OpenTofu configuration and bootstrap scripts of the edge router of the [Phorge](https://phorge.fr) infrastructure, a MikroTik RB3011UiAS running RouterOS 7.19. The router owns the VLANs, addressing, DHCP, DNS, firewall and NAT, and runs the HAProxy container that publishes the services to the Internet.

Documentation:

- [Architecture and network plan](docs/architecture.md): topology, VLANs and addresses, wiring, hosts and clusters, public services, traffic flows, change checklists.
- [Reset and bootstrap runbook](docs/runbook-reset.md): rebuild the router from scratch and bring it back under OpenTofu.

Sibling repositories: [FrontPlane](https://github.com/phorge-fr/Frontplane) (Kubernetes clusters), [Ansible](https://github.com/phorge-fr/Ansible) (storage, HPC and compute nodes).

## Repository layout

```text
versions.tf          OpenTofu and provider version constraints
providers.tf         Provider settings
variables.tf         Input variables, with validation
locals.tf            Values derived from the networks variable
interfaces.tf        VLANs, veth, bridges, interface lists, VXLAN
addressing.tf        IP addresses and DHCP pools
dhcp.tf              DHCP networks and servers
dns.tf               DNS records
firewall.tf          Filter rules, NAT rules, address lists
routing.tf           BGP connections
containers.tf        Container runtime, mounts, uploaded files, containers
encryption.tf        State and plan encryption; the passphrase comes from TF_ENCRYPTION
terraform.tfvars     Values: networks, DNS records, firewall, NAT, containers
.terraform.lock.hcl  Pinned provider version and hashes (committed)
templates/           HAProxy configuration uploaded to the router
certs/               Local trust anchor: the router CA (ignored by git, see the runbook)
defaults/            RouterOS scripts: factory defaults, base configuration, Phorge.dpk
docs/                Architecture and runbooks
```

One entry in `networks` (name, VLAN ID, CIDR, optionally a DHCP pool and node ranges) creates the VLAN, the router address (the last usable address of the subnet), the DHCP pool, network and server, the membership of the `phorge` interface list and the `<name>-nodes` address list.

## Requirements

- [OpenTofu](https://opentofu.org/docs/intro/install/) 1.12 or later
- RouterOS 7.19 or later with the `container` package and the container feature enabled in `device-mode`
- Access to the router's REST API (HTTPS, management LAN)

## Usage

1. Create your environment file and restrict it:

   ```bash
   cp .env.example .env
   chmod 600 .env
   ```

   Then set `TF_VAR_hosturl`, `TF_VAR_username` and `TF_VAR_password`, and replace the passphrase in `TF_ENCRYPTION` (at least 16 random characters). Keep a copy of that passphrase outside this machine: without it the state cannot be read.

   The provider verifies the router certificate against `certs/router-ca.pem`, a local file that is not committed. Fetch it as described in [the runbook](docs/runbook-reset.md#6-bring-the-router-back-under-opentofu). The first run after a router reset can use `TF_VAR_insecure_tls=true` instead.

2. Initialize:

   ```bash
   source .env
   tofu init
   ```

3. Plan, read the plan, then apply:

   ```bash
   tofu plan
   tofu apply
   ```

Run every command from the repository root so that `terraform.tfvars` is loaded. Without it the plan stops on missing required variables.

The uploaded HAProxy configuration is adopted automatically (`import` block in `containers.tf`) because RouterOS file IDs shift when other files change.

The VLANs, IP addresses, bridges and bridge ports have `prevent_destroy`: a plan that would delete them fails. To delete one on purpose, remove its `lifecycle` block first.

## Conventions

- Every object created by OpenTofu carries a comment starting with `tofu;;;`.
- Firewall rules are inserted with `place_before`, a position in the router's rule list. See [the runbook](docs/runbook-reset.md#firewall-rule-order) before adding or reordering rules.
- The state is local (`terraform.tfstate`, ignored by git) and encrypted with OpenTofu's native state encryption. Every command needs `source .env`, otherwise it stops with `Reference to undeclared key provider`. Keep a copy of the state after every apply.
- All three Phorge repositories are public. Never commit `.env`, the state (not even encrypted), a reset-edited `base_configuration.rsc` or any other plaintext secret.
- Commit messages follow Conventional Commits (`fix(fw): ...`, `chore(haproxy): ...`).

## Setting up the router for the first time

Follow [the runbook](docs/runbook-reset.md). In short: replace the placeholders in `defaults/base_configuration.rsc`, reset the router with the factory defaults, upload `defaults/Phorge.dpk`, import the base configuration, then run OpenTofu.
