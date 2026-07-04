container_config = {
  registry_url = "https://registry-1.docker.io"
  ram_high     = "128"
  tmpdir       = "/usb1/containers/tmp"
  layer_dir    = "/usb1/containers/layers"
}

vlans = [
  { interface = "bridge", name = "ctrl", vlan_id = 20, mtu = 8152 },
  { interface = "bridge", name = "core", vlan_id = 30, mtu = 8152 },
  { interface = "bridge", name = "svc", vlan_id = 40, mtu = 8152 },
  { interface = "bridge", name = "stor", vlan_id = 50, mtu = 8152 },
  { interface = "bridge", name = "ai", vlan_id = 60, mtu = 8152},
  { interface = "bridge", name = "comp-ew", vlan_id = 70, mtu = 8152 },
  { interface = "bridge", name = "comp-ns", vlan_id = 80, mtu = 8152 },
]

ip_addresses = [
  { interface = "ctrl", address = "10.1.0.254/24" },
  { interface = "core", address = "10.2.0.254/24" },
  { interface = "svc", address = "10.3.0.254/24" },
  { interface = "stor", address = "10.4.0.254/24" },
  { interface = "ai", address = "10.5.0.254/24" },
  { interface = "comp-ew", address = "10.10.0.254/24" },
  { interface = "comp-ns", address = "10.10.1.254/24" },
  { interface = "containers", address = "172.17.0.1/24"}
]

ip_pools = [
  { name = "ctrl", ranges = ["10.1.0.1-10.1.0.253"]},
  { name = "core", ranges = ["10.2.0.1-10.2.0.253"]},
  { name = "svc", ranges = ["10.3.0.1-10.3.0.253"]},
  { name = "stor", ranges = ["10.4.0.1-10.4.0.253"]},
  { name = "ai", ranges = ["10.5.0.1-10.5.0.253"]},
  { name = "comp-ew", ranges = ["10.10.0.1-10.10.0.253"]},
]

dhcp_server_networks = [
  { address = "10.1.0.0/24", gateway = "10.1.0.254", dns_server = ["10.1.0.254"] },
  { address = "10.2.0.0/24", gateway = "10.2.0.254", dns_server = ["10.2.0.254"] },
  { address = "10.3.0.0/24", gateway = "10.3.0.254", dns_server = ["10.3.0.254"] },
  { address = "10.4.0.0/24", gateway = "10.4.0.254", dns_server = ["10.4.0.254"] },
  { address = "10.5.0.0/24", gateway = "10.5.0.254", dns_server = ["10.5.0.254"] },
  { address = "10.10.0.0/24", gateway = "10.10.0.254", dns_server = ["10.10.0.254"] },
]

dhcp_servers = [
  { address_pool = "ctrl", interface = "ctrl", name = "ctrl" },
  { address_pool = "core", interface = "core", name = "core" },
  { address_pool = "svc", interface = "svc", name = "svc" },
  { address_pool = "stor", interface = "stor", name = "stor" },
  { address_pool = "ai", interface = "ai", name = "ai" },
  { address_pool = "comp-ew", interface = "comp-ew", name = "comp-ew" },
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
]


firewall_rules = [
  { chain = "input", action = "accept", in_interface_list = "!LAN", dst_port = "53", protocol = "tcp", place_before="5", comment = "tofu;;; Allow TCP DNS from !LAN" },
  { chain = "input", action = "accept", in_interface_list = "!LAN", dst_port = "53", protocol = "udp", place_before="5", comment = "tofu;;; Allow UDP DNS from !LAN" },
  { chain = "forward", action = "accept", in_interface = "containers", out_interface = "core", dst_address = "10.2.0.11", dst_port="80,443", protocol = "tcp", place_before="12", comment = "tofu;;; Allow Hproxy to core cluster Ingress"},
  { chain = "forward", action = "accept", in_interface = "containers", out_interface = "svc", dst_address = "10.3.0.11", dst_port="80,443", protocol = "tcp", place_before="12", comment = "tofu;;; Allow Hproxy to svc cluster Ingress"},
  { chain = "forward", action = "accept", src_address_list = "svc-nodes", dst_address_list = "stor-nodes", dst_port = "2049", protocol = "tcp", place_before="12", comment = "tofu;;; Allow svc cluster nodes to stor nodes over NFS/TCP" },
  { chain = "forward", action = "accept", src_address_list = "svc-nodes", dst_address_list = "stor-nodes", dst_port = "2049", protocol = "udp", place_before="12", comment = "tofu;;; Allow svc cluster nodes to stor nodes over NFS/UDP" },
  { chain = "forward", action = "drop", in_interface_list = "!LAN", dst_address = "192.168.1.0/24", comment = "tofu;;; Drop overlay network"},
  { chain = "forward", action = "drop", in_interface_list = "!LAN", dst_address = "192.168.2.0/24", comment = "tofu;;; Drop 'this' network"},
  { chain = "forward", action = "drop", in_interface_list = "phorge", out_interface_list = "phorge", comment = "tofu;;; Drop phorge to phorge" },
  { chain = "forward", action = "drop", in_interface_list = "Containers", out_interface_list = "phorge", comment = "tofu;;; Drop Containers to phorge" },
]

firewall_address_lists = [
  { list = "ctrl-nodes", address = "10.1.0.1-10.1.0.3" },
  { list = "core-nodes", address = "10.2.0.1-10.2.0.3" },
  { list = "svc-nodes", address = "10.3.0.1-10.3.0.3" },
  { list = "stor-nodes", address = "10.4.0.1" },
  { list = "ai-nodes", address = "10.5.0.1-10.5.0.2" },
  { list = "comp-nodes", address = "10.10.0.1-10.10.0.3" },
]

firewall_nat_rules = [
  { chain = "dstnat", action = "dst-nat", protocol = "tcp", dst_port = "80", to_addresses = "172.17.0.2", to_ports = "8080", in_interface_list = "WAN", comment = "tofu;;; Allow 80/TCP to Haproxy" },
  { chain = "dstnat", action = "dst-nat", protocol = "tcp", dst_port = "443", to_addresses = "172.17.0.2", to_ports = "8443", in_interface_list = "WAN", comment = "tofu;;; Allow 443/TCP to Haproxy" },
  { chain = "srcnat", action = "masquerade", src_address = "172.17.0.0/24", comment = "tofu;;; Masquerade outbound traffic for docker" },
]
interface_lists = [ 
  { name = "phorge", members = [ "ctrl", "core", "svc", "stor", "ai", "comp-ew", "comp-ns" ] },
  { name = "Containers", members = [ "containers", "veth1" ] },
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

veths = [ {
  name = "veth1", address = ["172.17.0.2/24"], gateway = "172.17.0.1", comment = "tofu;;; Containers Veth"
} ]

bridges = [ {
  name = "containers", ports = ["veth1"], comment = "tofu;;;  Containers Bridge"
} ]

files = [ {
  name = "usb1/haproxy-etc/haproxy.cfg", contents = "templates/haproxy.cfg"
} ]

container_mounts = [ {
  name = "haproxy_etc", src = "/usb1/haproxy-etc", dst = "/usr/local/etc/haproxy"
} ]

containers = [ {
  hostname = "haproxy", remote_image = "arm32v7/haproxy:latest", mounts = [ "haproxy_etc" ], logging = true, root_dir = "usb1/images/haproxy", interface = "veth1", start_on_boot = true, user = "0:0"
} ]
