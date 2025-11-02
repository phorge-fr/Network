vlans = [
  # { interface = "bridge", name = "Office", vlan_id = 10 },
  { interface = "bridge", name = "FrontPlane", vlan_id = 20 },
  { interface = "bridge", name = "IaaS-EW", vlan_id = 30 },
  # { interface = "bridge", name = "IaaS-EW", vlan_id = 40 },
  # { interface = "bridge", name = "HPC", vlan_id = 50 },
  # { interface = "bridge", name = "SVLan", vlan_id = 100 },
]

ip_addresses = [
  # { interface = "Office", address = "192.168.3.254/24"},
  { interface = "FrontPlane", address = "10.0.0.254/24" },
  { interface = "IaaS-EW", address = "10.1.0.254/24" },
  # { interface = "IaaS-EW", address = "10.2.2.254/24" },
  # { interface = "HPC", address = "10.0.3.254/24" },
  # { interface = "ether10", address = "192.168.10.254/24" },
]

ip_pools = [
  { name = "FrontPlane", ranges = ["10.0.0.1-10.0.0.253"]},
  { name = "IaaS-EW", ranges = ["10.1.0.1-10.1.0.253"]},
  # { name = "Office", ranges = ["192.168.3.1-192.168.3.253"] },
  # { name = "SVLan", ranges = ["192.168.10.1-192.168.10.253"] },
]

dhcp_server_networks = [
  { address = "10.0.0.0/24", gateway = "10.0.0.254", dns_server = ["10.0.0.254"] },
  { address = "10.1.0.0/24", gateway = "10.1.0.254", dns_server = ["10.1.0.254"] },
  # { address = "192.168.3.0/24", gateway = "192.168.3.254", dns_server = ["192.168.3.254"]},
  # { address = "192.168.10.0/24", gateway = "192.168.10.254", dns_server = ["192.168.10.254"]},
]

dhcp_servers = [
  { address_pool = "FrontPlane", interface = "FrontPlane", name = "FrontPlane" },
  { address_pool = "IaaS-EW", interface = "IaaS-EW", name = "IaaS-EW" },
  # { address_pool = "Office", interface = "Office", name = "Office" },
  # { address_pool = "SVLan", interface = "SVLan", name = "SVLan" },
]

dns_records = [
  { name = "fp-sw0.phorge", address = "192.168.2.253", type = "A" },
  { name = "iaas-sw0.phorge", address = "192.168.2.252", type = "A" },
  { name = "quiet-lion.phorge", address = "10.0.0.1", type = "A" },
  { name = "happy-whale.phorge", address = "10.0.0.2", type = "A" },
  { name = "sly-deer.phorge", address = "10.0.0.3", type = "A" },
  { name = "strong-owl.phorge", address = "10.0.0.4", type = "A" },
  { name = "silent-lion.phorge", address = "10.0.0.5", type = "A" },
  { name = "calm-rabbit.phorge", address = "10.0.0.6", type = "A" },
  # { name = "dell0.phorge", address = "10.1.0.1", type = "A" },
  # { name = "dell1.phorge", address = "10.1.0.2", type = "A" },
  # { name = "dell2.phorge", address = "10.1.0.3", type = "A" },
  # { name = "dell3.phorge", address = "10.1.0.4", type = "A" },
  # { name = "dell4.phorge", address = "10.1.0.5", type = "A" },
  # { name = "dell5.phorge", address = "10.1.0.6", type = "A" },
]


firewall_rules = [
  { chain = "input", action = "accept", in_interface_list = "!LAN", dst_port = "53", protocol = "tcp", place_before="5" , comment = "tofu;;; Allow TCP DNS from !LAN" },
  { chain = "input", action = "accept", in_interface_list = "!LAN", dst_port = "53", protocol = "udp", place_before="5" , comment = "tofu;;; Allow UDP DNS from !LAN" },
  { chain = "forward", action = "drop", in_interface_list = "!LAN", dst_address = "192.168.1.0/24", place_before="11", comment = "tofu;;; Drop overlay network"},
]

firewall_address_lists = [
  { list = "FrontPlane Nodes", address = "10.0.0.1-10.0.0.6" },
  { list = "FrontPlane LoadBalancer IPs", address = "10.0.0.10-10.0.0.20"},
  { list = "FrontPlane API Server", address = "10.0.0.7"},
  { list = "IaaS Nodes", address = "10.1.0.1-10.1.0.6" },
]

firewall_nat_rules = [
  # { chain = "dstnat", action = "dst-nat", protocol = "tcp", dst_port = "80", to_addresses = "10.0.0.10", to_ports = "80", in_interface_list = "WAN", comment = "tofu;;; Redirect HTTP to FrontPlane LB Nginx" },
  # { chain = "dstnat", action = "dst-nat", protocol = "tcp", dst_port = "443", to_addresses = "10.0.0.10", to_ports = "443", in_interface_list = "WAN", comment = "tofu;;; Redirect HTTPS to FrontPlane LB Nginx" },
  # { chain = "dstnat", action = "dst-nat", protocol = "udp", dst_port = "9", to_addresses = "10.0.3.253", dst_address="10.0.3.0/24", comment = "tofu;;; Allow WoL from other networks to HPC" }, # Requires to manually create a static ARP entry such as: 10.0.3.253 -> ff:ff:ff:ff:ff:ff
]

# interface_lists = [ 
#   { name = "PCI"},
#   { name = "FrontPlane Nodes" },
#   { name = "IaaS NS" },
#   { name = "IaaS EW" },
#   { name = "HPC Nodes" },
# ]

interface_list_members = [
  # { interface_list = "PCI", interface = "FrontPlane" },
  # { interface_list = "PCI", interface = "IaaS-NS" },
  # { interface_list = "PCI", interface = "IaaS-EW" },
  # { interface_list = "PCI", interface = "HPC" },
  # { interface_list = "PCI", interface = "SVLan" },
]
