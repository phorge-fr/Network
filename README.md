# NetConf

![Phorge logo](https://avatars.githubusercontent.com/u/187407936?s=200&v=4)

NetConf is the network configuration files & OpenTofu plans for the [PCI](https://phorge.fr) Core Infrastructure

## Setup

### Setting up router for the first time

Requirements:

- [DPK](defaults/Phorge.dpk)
- [Default configuration](defaults/base_configuration.rsc)

1. Prepare the configuration

- Line 21: Modify pin number
- Line 47: Change user & password

2. Reset the router

```bash
ssh admin@192.168.88.1 /system/reset-configuration
```

> Make sure that the router loads the [Official default configuration](defaults/default_configuration.rsc) so you can SSH into the router 

3. Upload the DPK:

```bash
scp defaults/Phorge.dpk admin@192.168.88.1:/
ssh admin@192.168.88.1 /system/reboot
```

4. Apply the default configuration

```bash
scp defaults/base_configuration.rsc admin@192.168.88.1:/
ssh admin@192.168.88.1 import base_configuration.rsc
```

> The SSH connection might fail due to DHCP & IP configuration being modified

5. Verify configuration

```bash
ssh user@ip export
```

### Setting up OpenTofu

Requirements:

- [OpenTofu](https://opentofu.org/docs/intro/install/)
- [Environment variable file](./.env.example)

1. Prepare your environment file (.env)

```bash
cp .env.example .env
```

And edit the variables

2. Init the OpenTofu configuration

```bash
tofu init
```

3. Plan the configuration

```bash
source .env && tofu plan -var-file=config.tfvars
```