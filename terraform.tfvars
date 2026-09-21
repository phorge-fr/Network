container_config = {
  registry_url = "https://registry-1.docker.io"
  ram_high     = "128"
  tmpdir       = "/usb1/containers/tmp"
  layer_dir    = "/usb1/containers/layers"
}

networks = {
  ctrl    = { vlan_id = 20, cidr = "10.1.0.0/24", dhcp_pool = "10.1.0.1-10.1.0.253", nodes = ["10.1.0.1-10.1.0.3"], ingress = 11 }
  core    = { vlan_id = 30, cidr = "10.2.0.0/24", dhcp_pool = "10.2.0.1-10.2.0.253", nodes = ["10.2.0.1-10.2.0.3"], ingress = 11 }
  svc     = { vlan_id = 40, cidr = "10.3.0.0/24", dhcp_pool = "10.3.0.1-10.3.0.253", nodes = ["10.3.0.1-10.3.0.3"], ingress = 11 }
  stor    = { vlan_id = 50, cidr = "10.4.0.0/24", dhcp_pool = "10.4.0.1-10.4.0.253", nodes = ["10.4.0.1"] }
  ai      = { vlan_id = 60, cidr = "10.5.0.0/24", dhcp_pool = "10.5.0.1-10.5.0.253", nodes = ["10.5.0.1-10.5.0.2"] }
  comp-ew = { vlan_id = 70, cidr = "10.10.0.0/24", dhcp_pool = "10.10.0.1-10.10.0.253", nodes = ["10.10.0.1-10.10.0.3"], address_list = "comp-nodes" }
  comp-ns = { vlan_id = 80, cidr = "10.10.1.0/24" }
}

ip_addresses = [
  { interface = "containers", address = "172.17.0.1/24" },
]

dns_records = [
  { name = "main-gw-0.phorge", address = "192.168.2.254", type = "A" },
  { name = "main-sw-0.phorge", address = "192.168.2.253", type = "A" },
  { name = "main-sw-1.phorge", address = "192.168.2.252", type = "A" },

  { name = "ctrl-rpi4-01.phorge", address = "10.1.0.1", type = "A" },
  { name = "ctrl-rpi4-02.phorge", address = "10.1.0.2", type = "A" },
  { name = "ctrl-rpi4-03.phorge", address = "10.1.0.3", type = "A" },

  { name = "core-wyse-01.phorge", address = "10.2.0.1", type = "A" },
  { name = "core-wyse-02.phorge", address = "10.2.0.2", type = "A" },
  { name = "core-wyse-03.phorge", address = "10.2.0.3", type = "A" },

  { name = "svc-rock64-01.phorge", address = "10.3.0.1", type = "A" },
  { name = "svc-rock64-02.phorge", address = "10.3.0.2", type = "A" },
  { name = "svc-rock64-03.phorge", address = "10.3.0.3", type = "A" },

  { name = "stor-rpi5-01.phorge", address = "10.4.0.1", type = "A" },

  { name = "ai-rpi5-01.phorge", address = "10.5.0.1", type = "A" },

  { name = "comp-opti-01.phorge", address = "10.10.0.1", type = "A" },
  { name = "comp-opti-02.phorge", address = "10.10.0.2", type = "A" },
  { name = "comp-opti-03.phorge", address = "10.10.0.3", type = "A" },

  { name = "prometheus.core.phorge", address = "10.2.0.10", type = "A" },
  { name = "loki.core.phorge", address = "10.2.0.10", type = "A" },
  { name = "openfga.core.phorge", address = "10.2.0.10", type = "A" },
]


# Rules are placed on the router in this order. `before` puts a rule right above the factory rule of
# that name in the same chain; without it the rule goes to the end of the chain.
firewall_rules = [
  { id = "dns-tcp-from-phorge", chain = "input", action = "accept", before = "defconf: drop all not coming from LAN", in_interface_list = "phorge", dst_port = "53", protocol = "tcp", comment = "tofu;;; Allow TCP DNS from phorge" },
  { id = "dns-udp-from-phorge", chain = "input", action = "accept", before = "defconf: drop all not coming from LAN", in_interface_list = "phorge", dst_port = "53", protocol = "udp", comment = "tofu;;; Allow UDP DNS from phorge" },

  { id = "hproxy-to-core-ingress", chain = "forward", action = "accept", before = "defconf: drop invalid", in_interface = "containers", out_interface = "core", dst_ingress = "core", dst_port = "80,443", protocol = "tcp", comment = "tofu;;; Allow Hproxy to core cluster Ingress" },
  { id = "hproxy-to-svc-ingress", chain = "forward", action = "accept", before = "defconf: drop invalid", in_interface = "containers", out_interface = "svc", dst_ingress = "svc", dst_port = "80,443", protocol = "tcp", comment = "tofu;;; Allow Hproxy to svc cluster Ingress" },
  { id = "alloy-ctrl-to-core", chain = "forward", action = "accept", before = "defconf: drop invalid", src_address_list = "ctrl-nodes", dst_address = "10.2.0.10", dst_port = "443", protocol = "tcp", comment = "tofu;;; Allow ctrl cluster nodes to push metrics/logs to core (Alloy)" },
  { id = "alloy-svc-to-core", chain = "forward", action = "accept", before = "defconf: drop invalid", src_address_list = "svc-nodes", dst_address = "10.2.0.10", dst_port = "443", protocol = "tcp", comment = "tofu;;; Allow svc cluster nodes to push metrics/logs to core (Alloy)" },
  { id = "alloy-stor-to-core", chain = "forward", action = "accept", before = "defconf: drop invalid", src_address_list = "stor-nodes", dst_address = "10.2.0.10", dst_port = "443", protocol = "tcp", comment = "tofu;;; Allow stor nodes to push metrics/logs to core (Alloy)" },
  { id = "nfs-tcp-svc-to-stor", chain = "forward", action = "accept", before = "defconf: drop invalid", src_address_list = "svc-nodes", dst_address_list = "stor-nodes", dst_port = "2049", protocol = "tcp", comment = "tofu;;; Allow svc cluster nodes to stor nodes over NFS/TCP" },
  { id = "nfs-udp-svc-to-stor", chain = "forward", action = "accept", before = "defconf: drop invalid", src_address_list = "svc-nodes", dst_address_list = "stor-nodes", dst_port = "2049", protocol = "udp", comment = "tofu;;; Allow svc cluster nodes to stor nodes over NFS/UDP" },
  { id = "s3-core-to-stor", chain = "forward", action = "accept", before = "defconf: drop invalid", src_address_list = "core-nodes", dst_address_list = "stor-nodes", dst_port = "9000", protocol = "tcp", comment = "tofu;;; Allow core cluster nodes to stor rustfs S3 (Longhorn backups)" },

  { id = "drop-this-network", chain = "forward", action = "drop", in_interface_list = "!LAN", dst_address = "192.168.2.0/24", comment = "tofu;;; Drop 'this' network" },
  { id = "drop-overlay-network", chain = "forward", action = "drop", in_interface_list = "!LAN", dst_address = "192.168.1.0/24", comment = "tofu;;; Drop overlay network" },
  { id = "drop-containers-to-phorge", chain = "forward", action = "drop", in_interface_list = "Containers", out_interface_list = "phorge", comment = "tofu;;; Drop Containers to phorge" },
  { id = "drop-phorge-to-phorge", chain = "forward", action = "drop", in_interface_list = "phorge", out_interface_list = "phorge", comment = "tofu;;; Drop phorge to phorge" },
]

firewall_nat_rules = [
  { chain = "dstnat", action = "dst-nat", protocol = "tcp", dst_port = "80", to_addresses = "172.17.0.2", to_ports = "8080", in_interface_list = "WAN", comment = "tofu;;; Allow 80/TCP to Haproxy" },
  { chain = "dstnat", action = "dst-nat", protocol = "tcp", dst_port = "443", to_addresses = "172.17.0.2", to_ports = "8443", in_interface_list = "WAN", comment = "tofu;;; Allow 443/TCP to Haproxy" },
  { chain = "srcnat", action = "masquerade", src_address = "172.17.0.0/24", comment = "tofu;;; Masquerade outbound traffic for docker" },
]
interface_lists = [
  { name = "Containers", members = ["containers", "veth1"] },
]

vxlan_interfaces = [
]

vxlan_vteps = [
]

# bgp_connections = [
#   { as = 65535, comment = "tofu;;; IaaS clever-lynx", connect = true, listen = true, local = { address = "10.1.0.254", role = "ibgp" }, name = "clever-lynx", remote = { address = "10.1.0.1" , as = 65535 } },
#   { as = 65535, comment = "tofu;;; IaaS gentle-fox", connect = true, listen = true, local = { address = "10.1.0.254", role = "ibgp" }, name = "gentle-fox", remote = { address = "10.1.0.2" , as = 65535 } },
#   { as = 65535, comment = "tofu;;; IaaS mighty-deer", connect = true, listen = true, local = { address = "10.1.0.254", role = "ibgp" }, name = "mighty-deer", remote = { address = "10.1.0.3" , as = 65535 } },
#   { as = 65535, comment = "tofu;;; IaaS brave-whale", connect = true, listen = true, local = { address = "10.1.0.254", role = "ibgp" }, name = "brave-whale", remote = { address = "10.1.0.4" , as = 65535 } },
#   { as = 65535, comment = "tofu;;; IaaS mighty-rabbit", connect = true, listen = true, local = { address = "10.1.0.254", role = "ibgp" }, name = "mighty-rabbit", remote = { address = "10.1.0.5" , as = 65535 } },
#   { as = 65535, comment = "tofu;;; IaaS clever-panda", connect = true, listen = true, local = { address = "10.1.0.254", role = "ibgp" }, name = "clever-panda", remote = { address = "10.1.0.6" , as = 65535 } }
# ]

veths = [{
  name = "veth1", address = ["172.17.0.2/24"], gateway = "172.17.0.1", comment = "tofu;;; Containers Veth"
}]

bridges = [{
  name = "containers", ports = ["veth1"], comment = "tofu;;;  Containers Bridge"
}]

files = [
  { name = "usb1/haproxy-etc/haproxy.cfg", template = "templates/haproxy.cfg.tftpl" },
  { name = "usb1/haproxy-etc/run.sh", template = "templates/haproxy-run.sh" },
]

container_mounts = [{
  name = "haproxy_etc", src = "/usb1/haproxy-etc", dst = "/usr/local/etc/haproxy"
}]

containers = [{
  hostname = "haproxy", remote_image = "arm32v7/haproxy:latest", mounts = ["haproxy_etc"], logging = true, root_dir = "usb1/images/haproxy", interface = "veth1", start_on_boot = true, user = "0:0", entrypoint = "/bin/sh", cmd = "/usr/local/etc/haproxy/run.sh"
}]
