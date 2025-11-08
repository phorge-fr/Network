vlans = [
  # { interface = "bridge", name = "Office", vlan_id = 10 },
  { interface = "bridge", name = "FrontPlane", vlan_id = 20 },
  { interface = "bridge", name = "IaaS-EW", vlan_id = 30 },
  { interface = "bridge", name = "IaaS-NS", vlan_id = 40 },
  # { interface = "bridge", name = "HPC", vlan_id = 50 },
  # { interface = "bridge", name = "SVLan", vlan_id = 100 },
]

ip_addresses = [
  # { interface = "Office", address = "192.168.3.254/24"},
  { interface = "FrontPlane", address = "10.0.0.254/24" },
  { interface = "IaaS-EW", address = "10.1.0.254/24" },
  { interface = "IaaS-NS", address = "10.2.0.254/24" },
  # { interface = "HPC", address = "10.0.3.254/24" },
  # { interface = "ether10", address = "192.168.10.254/24" },
]

ip_pools = [
  # { name = "FrontPlane", ranges = ["10.0.0.1-10.0.0.253"]},
  # { name = "IaaS-EW", ranges = ["10.1.0.1-10.1.0.253"]},
  # { name = "Office", ranges = ["192.168.3.1-192.168.3.253"] },
  # { name = "SVLan", ranges = ["192.168.10.1-192.168.10.253"] },
]

dhcp_server_networks = [
  # { address = "10.0.0.0/24", gateway = "10.0.0.254", dns_server = ["10.0.0.254"] },
  # { address = "10.1.0.0/24", gateway = "10.1.0.254", dns_server = ["10.1.0.254"] },
]

dhcp_servers = [
  # { address_pool = "FrontPlane", interface = "FrontPlane", name = "FrontPlane" },
  # { address_pool = "IaaS-EW", interface = "IaaS-EW", name = "IaaS-EW" },
]

dns_records = [
  { name = "core-gw0.phorge", address = "192.168.2.254", type = "A" },
  { name = "fp-sw0.phorge", address = "192.168.2.253", type = "A" },
  { name = "iaas-sw0.phorge", address = "192.168.2.252", type = "A" },
  { name = "quiet-lion.phorge", address = "10.0.0.1", type = "A" },
  { name = "happy-whale.phorge", address = "10.0.0.2", type = "A" },
  { name = "sly-deer.phorge", address = "10.0.0.3", type = "A" },
  { name = "strong-owl.phorge", address = "10.0.0.4", type = "A" },
  { name = "silent-lion.phorge", address = "10.0.0.5", type = "A" },
  { name = "calm-rabbit.phorge", address = "10.0.0.6", type = "A" },
  { name = "clever-lynx.phorge", address = "10.1.0.1", type = "A" },
  { name = "gentle-fox.phorge", address = "10.1.0.2", type = "A" },
  { name = "mighty-deer.phorge", address = "10.1.0.3", type = "A" },
  { name = "brave-whale.phorge", address = "10.1.0.4", type = "A" },
  { name = "mighty-rabbit.phorge", address = "10.1.0.5", type = "A" },
  { name = "clever-panda.phorge", address = "10.1.0.6", type = "A" },
]


firewall_rules = [
  { chain = "input", action = "accept", in_interface_list = "!LAN", dst_port = "53", protocol = "tcp", place_before="5" , comment = "tofu;;; Allow TCP DNS from !LAN" },
  { chain = "input", action = "accept", in_interface_list = "!LAN", dst_port = "53", protocol = "udp", place_before="5" , comment = "tofu;;; Allow UDP DNS from !LAN" },
  { chain = "forward", action = "drop", in_interface_list = "!LAN", dst_address = "192.168.1.0/24", place_before="11", comment = "tofu;;; Drop overlay network"},
  { chain = "forward", action = "accept", in_interface = "FrontPlane", out_interface = "IaaS-EW", dst_port="8444", protocol = "tcp", place_before="11", comment = "tofu;;; Allow FrontPlane to IaaS-EW for Prometheus Incus"},
  { chain = "forward", action = "accept", in_interface = "FrontPlane", out_interface = "IaaS-EW", dst_port="9100", protocol = "tcp", place_before="11", comment = "tofu;;; Allow FrontPlane to IaaS-EW for Prometheus Node Exporter"},
  { chain = "forward", action = "accept", in_interface = "IaaS-EW", dst_address = "10.0.0.11", dst_port="3100", protocol = "tcp", place_before="11", comment = "tofu;;; Allow IaaS-EW to Frontplane Service Loki"},
  { chain = "forward", action = "accept", in_interface = "FrontPlane", dst_address = "10.0.0.12", dst_port="8080", protocol = "tcp", place_before="11", comment = "tofu;;; Allow IaaS-EW to Frontplane Service OpenFGA"},
  { chain = "forward", action = "drop", in_interface_list = "PCI", out_interface_list = "PCI", place_before="11", comment = "tofu;;; Drop PCI to PCI" },
]

firewall_address_lists = [
  { list = "FrontPlane Nodes", address = "10.0.0.1-10.0.0.6" },
  { list = "FrontPlane LoadBalancer IPs", address = "10.0.0.10-10.0.0.20"},
  { list = "FrontPlane API Server", address = "10.0.0.7"},
  { list = "IaaS Nodes", address = "10.1.0.1-10.1.0.6" },
]

firewall_nat_rules = [
  { chain = "dstnat", action = "dst-nat", protocol = "tcp", dst_port = "80", to_addresses = "10.0.0.10", to_ports = "8080", in_interface_list = "WAN", comment = "tofu;;; Redirect HTTP to FrontPlane LB Nginx" },
  { chain = "dstnat", action = "dst-nat", protocol = "tcp", dst_port = "443", to_addresses = "10.0.0.10", to_ports = "8443", in_interface_list = "WAN", comment = "tofu;;; Redirect HTTPS to FrontPlane LB Nginx" },
  # { chain = "dstnat", action = "dst-nat", protocol = "udp", dst_port = "9", to_addresses = "10.0.3.253", dst_address="10.0.3.0/24", comment = "tofu;;; Allow WoL from other networks to HPC" }, # Requires to manually create a static ARP entry such as: 10.0.3.253 -> ff:ff:ff:ff:ff:ff
]

interface_lists = [ 
  { name = "PCI"},
#   { name = "FrontPlane Nodes" },
#   { name = "IaaS NS" },
#   { name = "IaaS EW" },
#   { name = "HPC Nodes" },
]

interface_list_members = [
  { interface_list = "PCI", interface = "FrontPlane" },
  { interface_list = "PCI", interface = "IaaS-EW" },
  # { interface_list = "PCI", interface = "IaaS-NS" },
  # { interface_list = "PCI", interface = "HPC" },
  # { interface_list = "PCI", interface = "SVLan" },
]

vxlan_interfaces = [ 
  { name = "white2net", mtu = 1500, vni = 171, comment = "tofu;;; VXLAN to White2Net"}
]

vxlan_vteps = [
  { interface = "white2net", remote_ip = "194.50.19.45" }
]

bgp_connections = [
  { as = 65535, comment = "tofu;;; IaaS clever-lynx", connect = true, listen = true, local = { address = "10.1.0.254", role = "ibgp" }, name = "clever-lynx", remote = { address = "10.1.0.1" , as = 65535 } },
  { as = 65535, comment = "tofu;;; IaaS gentle-fox", connect = true, listen = true, local = { address = "10.1.0.254", role = "ibgp" }, name = "gentle-fox", remote = { address = "10.1.0.2" , as = 65535 } },
  { as = 65535, comment = "tofu;;; IaaS mighty-deer", connect = true, listen = true, local = { address = "10.1.0.254", role = "ibgp" }, name = "mighty-deer", remote = { address = "10.1.0.3" , as = 65535 } },
  { as = 65535, comment = "tofu;;; IaaS brave-whale", connect = true, listen = true, local = { address = "10.1.0.254", role = "ibgp" }, name = "brave-whale", remote = { address = "10.1.0.4" , as = 65535 } },
  { as = 65535, comment = "tofu;;; IaaS mighty-rabbit", connect = true, listen = true, local = { address = "10.1.0.254", role = "ibgp" }, name = "mighty-rabbit", remote = { address = "10.1.0.5" , as = 65535 } },
  { as = 65535, comment = "tofu;;; IaaS clever-panda", connect = true, listen = true, local = { address = "10.1.0.254", role = "ibgp" }, name = "clever-panda", remote = { address = "10.1.0.6" , as = 65535 } }
]