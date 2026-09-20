# Network

![Phorge logo](https://avatars.githubusercontent.com/u/187407936?s=200&v=4)

OpenTofu configuration and bootstrap scripts of the edge router of the [Phorge](https://phorge.fr) infrastructure, a MikroTik RB3011UiAS running RouterOS 7.19. The router owns the VLANs, addressing, DHCP, DNS, firewall and NAT, and runs the HAProxy container that publishes the services to the Internet.

Documentation:

- [Architecture and network plan](docs/architecture.md): topology, VLANs and addresses, wiring, hosts and clusters, public services, traffic flows, change checklists.
- [Reset and bootstrap runbook](docs/runbook-reset.md): rebuild the router from scratch and bring it back under OpenTofu.

Sibling repositories: [FrontPlane](https://github.com/phorge-fr/Frontplane) (Kubernetes clusters), [Ansible](https://github.com/phorge-fr/Ansible) (storage, HPC and compute nodes).

## Repository layout

```text
main.tf              OpenTofu resources
variables.tf         Types of the input variables
terraform.tfvars     Values: VLANs, addressing, DHCP, DNS, firewall, NAT, containers
provider.tf          OpenTofu and provider version constraints, provider settings
.terraform.lock.hcl  Pinned provider version and hashes (committed)
templates/           HAProxy configuration uploaded to the router
defaults/            RouterOS scripts: factory defaults, base configuration, Phorge.dpk
docs/                Architecture and runbooks
```

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

   Then set `TF_VAR_hosturl`, `TF_VAR_username` and `TF_VAR_password`.

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

Run every command from the repository root: `terraform.tfvars` is loaded automatically, and without it the variables default to empty lists, which plans the deletion of the VLANs, addresses and firewall of the router.

## Conventions

- Every object created by OpenTofu carries a comment starting with `tofu;;;`.
- Firewall rules are inserted with `place_before`, a position in the router's rule list. See [the runbook](docs/runbook-reset.md#firewall-rule-order) before adding or reordering rules.
- The state is local (`terraform.tfstate`, ignored by git). Keep a copy after every apply.
- All three Phorge repositories are public. Never commit `.env`, the state, a reset-edited `base_configuration.rsc` or any other plaintext secret.
- Commit messages follow Conventional Commits (`fix(fw): ...`, `chore(haproxy): ...`).

## Setting up the router for the first time

Follow [the runbook](docs/runbook-reset.md). In short: replace the placeholders in `defaults/base_configuration.rsc`, reset the router with the factory defaults, upload `defaults/Phorge.dpk`, import the base configuration, then run OpenTofu.
