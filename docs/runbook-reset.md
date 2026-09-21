# Runbook: reset and bootstrap the router

Use it when the router has to be rebuilt from scratch: factory reset, replacement hardware, or a configuration that is beyond repair. The router is the only gateway of the infrastructure, so every step below takes the whole network down until the VLANs and the firewall are back.

## Before you reset

1. Save the running configuration and copy it off the router:

   ```bash
   ssh user@192.168.2.254 '/export file=pre-reset'
   scp user@192.168.2.254:/pre-reset.rsc ./
   ```

2. Copy the OpenTofu state: `cp terraform.tfstate terraform.tfstate.pre-reset`. It is encrypted, so keep the passphrase of `.env` (`TF_ENCRYPTION`) with it.
3. Have physical access: after the reset, MAC-server and neighbor discovery are disabled, so a lockout can only be fixed over IP on the management LAN, on the serial console, or with the reset button.
4. Note that every service published through HAProxy is offline until the container and its configuration file are back.

## 1. Prepare the base configuration

Edit `defaults/base_configuration.rsc` and replace the placeholders. Do not commit the edited file.

| Placeholder | Meaning |
|---|---|
| `<1234>` | PIN of the router LCD |
| `<us3r>` | Name of the administrator account |
| `<p4ssw0rd>` | Password of that account |

## 2. Reset

```bash
ssh admin@192.168.88.1 /system/reset-configuration
```

Keep the factory defaults (do not pass `no-defaults`): [default_configuration.rsc](../defaults/default_configuration.rsc) is what makes the router reachable on 192.168.88.1 afterwards.

## 3. Upload the DPK and reboot

```bash
scp defaults/Phorge.dpk admin@192.168.88.1:/
ssh admin@192.168.88.1 /system/reboot
```

## 4. Apply the base configuration

```bash
scp defaults/base_configuration.rsc admin@192.168.88.1:/
ssh admin@192.168.88.1 import base_configuration.rsc
```

The SSH session may drop halfway: the script moves the router to 192.168.2.254 and changes DHCP. Reconnect on the new address.

The script sets the DNS servers, hardens the management services, generates the certificates, sets the MTU of every Ethernet port, disables the spare ports, configures the management LAN (192.168.2.0/24), and creates your administrator account in place of `admin`.

## 5. Check the base configuration

```bash
ssh user@192.168.2.254 '/interface ethernet print detail where name~"ether|sfp"'
ssh user@192.168.2.254 '/ip dns print'
ssh user@192.168.2.254 '/interface print where disabled'
```

Expected:

- Every port has `l2mtu=8156` and `mtu=8156`. The VLANs use MTU 8152 and the bridge L2MTU is the lowest of its ports, so one port left at 1600 breaks the jumbo VLANs.
- `allow-remote-requests=yes` in `/ip dns`. The VLANs use the router as their resolver.
- The uplink to the managed switch is enabled.

One line of `base_configuration.rsc` is known to disagree with the live setup until the script is reworked: it disables `ether10`, the intended switch uplink. Enable it by hand if the switch is on that port.

## 6. Bring the router back under OpenTofu

The provider checks the router certificate against `certs/router-ca.pem`. That file is a local trust anchor and is not committed. A reset creates a new CA, so fetch it again: export the root certificate on the router, copy it, and remove the export.

```bash
mkdir -p certs
ssh user@192.168.2.254 '/certificate export-certificate root-cert'
scp user@192.168.2.254:/cert_export_root-cert.crt certs/router-ca.pem
ssh user@192.168.2.254 '/file remove cert_export_root-cert.crt'
```

To check the copy, compare `openssl x509 -in certs/router-ca.pem -noout -fingerprint -sha256` with the fingerprint that `/certificate print detail where name=root-cert` shows. Until the file exists, the first run can skip the check with `TF_VAR_insecure_tls=true`.

```bash
cp .env.example .env    # first time only, then set the address, credentials and state passphrase
chmod 600 .env
source .env
tofu init
tofu plan
```

A reset router has none of the objects that the state remembers, and RouterOS identifiers (`*A1`) are not stable. Read the plan before applying it:

- Objects that the plan wants to create and that the router already has (an ID that changed): adopt them with `tofu import '<address>' '<id>'`, or drop the stale entry with `tofu state rm '<address>'` and let the plan create it. The uploaded `haproxy.cfg` is the exception: an `import` block in `containers.tf` adopts it whenever it already exists on the router.
- Objects that no longer exist: the plan recreates them, which is the goal.

`tofu apply` needs an explicit go-ahead from whoever owns the router. It creates the VLANs, addresses, DHCP, DNS, firewall, NAT, the veth and bridge for containers, the HAProxy configuration file and the container.

### Firewall rule order

The order of the rules is declared in `terraform.tfvars`: `firewall_rules` is a list, every rule has a stable `id`, and `routeros_move_items` places the rules on the router in list order. A rule with `before` sits right above the factory rule of that comment in the same chain (`defconf: drop invalid` for the forward accepts, `defconf: drop all not coming from LAN` for the input rules). A rule without `before` goes to the end of the chain. The factory rules are found by chain and comment, so this works on any router that carries the factory defconf rules, and the plan stops with a clear message if one of them is missing.

After the first apply on a fresh router, check the result:

```bash
ssh user@192.168.2.254 '/ip firewall filter print'
```

The accept rules must sit above `drop invalid` and `drop all from WAN not DSTNATed`, and the custom drops at the end. `tofu plan` also reports a rule that was moved by hand, because the provider reads the real order of the rules it manages.

## 7. Check the result

1. `tofu plan` shows no changes (apart from known drift).
2. Every VLAN has neighbors: `/ip arp print where interface=ctrl`, and likewise for `core`, `svc`, `stor`, `ai`, `comp-ew`.
3. The rules count packets: `/ip firewall filter print stats`.
4. HAProxy runs: `/container print`. If it does not, check that `usb1` is mounted and that `usb1/haproxy-etc/haproxy.cfg` exists.
5. From outside, `https://status.phorge.fr` answers.
6. The container rules stay quiet: `/ip firewall filter print stats where log-prefix~"ctr-"` shows 0 packets for `ctr-spoof` and `ctr-drop`. A hit means a container tried something the firewall does not allow, and `/log print where message~"ctr-"` shows what.

## HAProxy configuration reload

The container runs `templates/haproxy-run.sh`, uploaded to `usb1/haproxy-etc/run.sh`. It starts HAProxy in master-worker mode and compares the checksum of `haproxy.cfg` every 5 seconds. When the file changes, it validates it with `haproxy -c` and, if it is valid, asks HAProxy to reload gracefully: existing connections finish on the old process, new ones use the new configuration, and the container does not restart. An invalid file is refused and the running configuration stays. Measured on the router, a change is live 3 to 9 seconds after `tofu apply`.

To add a public hostname, add its two lines (the redirect in `http-dispatcher` and the `use_backend` in `sni-dispatcher`) to `templates/haproxy.cfg.tftpl` and run `tofu apply`. The file in the repository is the source of truth: do not edit it on the router, because the next apply overwrites it and the container reloads the old version. `tofu apply` succeeds even when HAProxy refuses the file, because it only uploads it, so check that the router took the change into account:

```bash
ssh user@192.168.2.254 '/log print where message~"haproxy"'
```

`haproxy.cfg changed: reloading` followed by `Loading success` means it is live. `haproxy.cfg changed but is invalid` means the running configuration did not change, and the next lines give the reason.

The check only catches configurations that HAProxy cannot parse. A valid configuration that is wrong, such as a mistyped address or a removed route, is loaded as it is: fix the template and apply again.

If the container restarts while the file is invalid, for example after a reboot of the router, the script restores the last configuration that passed the check (`haproxy.cfg.good`, in the same directory) and logs it. The next `tofu plan` then shows the file as changed, because OpenTofu still holds the invalid version.

The old HAProxy process stays until its connections end (`timeout tunnel` is 6 hours), so several reloads in a row leave several processes running for a while. A change to `run.sh` itself only takes effect at the next container restart.

The first apply that introduces the script restarts the container once, because its entrypoint changes: about 6 seconds without service. The same happens whenever an attribute of the container itself changes (image, user, entrypoint, mounts).

## Factory rules in the state

The factory (defconf) firewall rules are not declared in `terraform.tfvars`. If an earlier session imported them into the state, a plan proposes to delete them from the router. Remove the state entries instead of applying:

```bash
tofu state list | grep defconf
tofu state rm '<address from the list>'
```

The `special dummy rule to show fasttrack counters` entries are dynamic and are never managed.
