locals {
  interface_lists_map = { for list in var.interface_lists : list.name => list }
}

resource "routeros_interface_vlan" "vlans" {
  for_each = { for v in var.vlans : "${v.interface}-${v.vlan_id}" => v }

  interface = each.value.interface
  name      = each.value.name
  vlan_id   = each.value.vlan_id
  mtu       = lookup(each.value, "mtu", null)
  comment   = lookup(each.value, "comment", null)
}

resource "routeros_ip_address" "ip_addresses" {
  for_each = { for ip in var.ip_addresses : "${ip.interface}-${ip.address}" => ip }

  interface = each.value.interface
  address   = each.value.address
  network   = lookup(each.value, "network", null)
  comment   = lookup(each.value, "comment", null)
  depends_on = [
    routeros_interface_vlan.vlans,
    routeros_interface_bridge.bridges,
    routeros_interface_vxlan.vxlans
   ]
}

resource "routeros_ip_pool" "dhcp_pools" {
    for_each = { for pool in var.ip_pools : pool.name => pool }
    
    name        = each.value.name
    ranges      = each.value.ranges
    comment     = lookup(each.value, "comment", null)
}

resource "routeros_ip_dhcp_server_network" "dhcp_networks" {
  for_each = { for net in var.dhcp_server_networks : net.address => net }

  address     = each.value.address
  gateway     = each.value.gateway
  dns_server  = each.value.dns_server
  comment     = lookup(each.value, "comment", null)
}

resource "routeros_ip_dhcp_server" "dhcp_servers" {
  for_each = { for s in var.dhcp_servers : s.name => s }

  address_pool = each.value.address_pool
  interface    = each.value.interface
  name         = each.value.name
  comment      = lookup(each.value, "comment", null)
  depends_on = [ 
    routeros_ip_pool.dhcp_pools,
    routeros_ip_dhcp_server_network.dhcp_networks,
    routeros_ip_address.ip_addresses
  ]
}

resource "routeros_ip_dns_record" "name_records" {
  for_each = { for record in var.dns_records : "${record.type}-${record.name}" => record }

  name    = lookup(each.value, "name", null)
  address = lookup(each.value, "address", null)
  cname   = lookup(each.value, "cname", null)
  type    = lookup(each.value, "type", "A")
  comment = lookup(each.value, "comment", null)
  
}

resource "routeros_ip_firewall_filter" "firewall_rules" {
  for_each = { for rule in var.firewall_rules : "${rule.chain}-${rule.action}-${rule.priority != null ? rule.priority : ""}-${rule.comment != null ? rule.comment : ""}-${rule.dst_address != null ? rule.dst_address : ""}-${rule.src_address != null ? rule.src_address : ""}" => rule }

  action = each.value.action
  chain  = each.value.chain

  address_list           = lookup(each.value, "address_list", null)
  address_list_timeout   = lookup(each.value, "address_list_timeout", null)
  comment                = lookup(each.value, "comment", null)
  connection_bytes       = lookup(each.value, "connection_bytes", null)
  connection_limit       = lookup(each.value, "connection_limit", null)
  connection_mark        = lookup(each.value, "connection_mark", null)
  connection_nat_state   = lookup(each.value, "connection_nat_state", null)
  connection_rate        = lookup(each.value, "connection_rate", null)
  connection_state       = lookup(each.value, "connection_state", null)
  connection_type        = lookup(each.value, "connection_type", null)
  content                = lookup(each.value, "content", null)
  disabled               = lookup(each.value, "disabled", null)
  dscp                   = lookup(each.value, "dscp", null)
  dst_address            = lookup(each.value, "dst_address", null)
  dst_address_list       = lookup(each.value, "dst_address_list", null)
  dst_address_type       = lookup(each.value, "dst_address_type", null)
  dst_limit              = lookup(each.value, "dst_limit", null)
  dst_port               = lookup(each.value, "dst_port", null)
  fragment               = lookup(each.value, "fragment", null)
  hotspot                = lookup(each.value, "hotspot", null)
  hw_offload             = lookup(each.value, "hw_offload", null)
  icmp_options           = lookup(each.value, "icmp_options", null)
  in_bridge_port         = lookup(each.value, "in_bridge_port", null)
  in_bridge_port_list    = lookup(each.value, "in_bridge_port_list", null)
  in_interface           = lookup(each.value, "in_interface", null)
  in_interface_list      = lookup(each.value, "in_interface_list", null)
  ingress_priority       = lookup(each.value, "ingress_priority", null)
  ipsec_policy           = lookup(each.value, "ipsec_policy", null)
  ipv4_options           = lookup(each.value, "ipv4_options", null)
  jump_target            = lookup(each.value, "jump_target", null)
  layer7_protocol        = lookup(each.value, "layer7_protocol", null)
  limit                  = lookup(each.value, "limit", null)
  log                    = lookup(each.value, "log", null)
  log_prefix             = lookup(each.value, "log_prefix", null)
  nth                    = lookup(each.value, "nth", null)
  out_bridge_port        = lookup(each.value, "out_bridge_port", null)
  out_bridge_port_list   = lookup(each.value, "out_bridge_port_list", null)
  out_interface          = lookup(each.value, "out_interface", null)
  out_interface_list     = lookup(each.value, "out_interface_list", null)
  packet_mark            = lookup(each.value, "packet_mark", null)
  packet_size            = lookup(each.value, "packet_size", null)
  per_connection_classifier = lookup(each.value, "per_connection_classifier", null)
  place_before           = lookup(each.value, "place_before", null)
  port                   = lookup(each.value, "port", null)
  priority               = lookup(each.value, "priority", null)
  protocol               = lookup(each.value, "protocol", null)
  psd                    = lookup(each.value, "psd", null)
  random                 = lookup(each.value, "random", null)
  reject_with            = lookup(each.value, "reject_with", null)
  routing_mark           = lookup(each.value, "routing_mark", null)
  routing_table          = lookup(each.value, "routing_table", null)
  src_address            = lookup(each.value, "src_address", null)
  src_address_list       = lookup(each.value, "src_address_list", null)
  src_address_type       = lookup(each.value, "src_address_type", null)
  src_mac_address        = lookup(each.value, "src_mac_address", null)
  src_port               = lookup(each.value, "src_port", null)
  tcp_flags              = lookup(each.value, "tcp_flags", null)
  tcp_mss                = lookup(each.value, "tcp_mss", null)
  time                   = lookup(each.value, "time", null)
  tls_host               = lookup(each.value, "tls_host", null)
  ttl                    = lookup(each.value, "ttl", null)
}

resource "routeros_ip_firewall_addr_list" "address_lists" {
  for_each = { for list in var.firewall_address_lists : list.list => list }

  list        = each.value.list
  address     = each.value.address
  comment     = lookup(each.value, "comment", null)
  disabled    = lookup(each.value, "disabled", false)
}

resource "routeros_ip_firewall_nat" "nat_rules" {
  for_each = { for rule in var.firewall_nat_rules : 
    "${rule.chain}-${rule.action}-${rule.out_interface != null ? rule.out_interface : ""}-${rule.comment != null ? rule.comment : ""}" => rule 
  }

  action        = each.value.action
  chain         = each.value.chain

  address_list           = lookup(each.value, "address_list", null)
  address_list_timeout   = lookup(each.value, "address_list_timeout", null)
  comment                = lookup(each.value, "comment", null)
  connection_bytes       = lookup(each.value, "connection_bytes", null)
  connection_limit       = lookup(each.value, "connection_limit", null)
  connection_mark        = lookup(each.value, "connection_mark", null)
  connection_rate        = lookup(each.value, "connection_rate", null)
  connection_type        = lookup(each.value, "connection_type", null)
  content                = lookup(each.value, "content", null)
  disabled               = lookup(each.value, "disabled", null)
  dscp                   = lookup(each.value, "dscp", null)
  dst_address            = lookup(each.value, "dst_address", null)
  dst_address_list       = lookup(each.value, "dst_address_list", null)
  dst_address_type       = lookup(each.value, "dst_address_type", null)
  dst_limit              = lookup(each.value, "dst_limit", null)
  dst_port               = lookup(each.value, "dst_port", null)
  fragment               = lookup(each.value, "fragment", null)
  hotspot                = lookup(each.value, "hotspot", null)
  icmp_options           = lookup(each.value, "icmp_options", null)
  in_bridge_port         = lookup(each.value, "in_bridge_port", null)
  in_bridge_port_list    = lookup(each.value, "in_bridge_port_list", null)
  in_interface           = lookup(each.value, "in_interface", null)
  in_interface_list      = lookup(each.value, "in_interface_list", null)
  ingress_priority       = lookup(each.value, "ingress_priority", null)
  ipsec_policy           = lookup(each.value, "ipsec_policy", null)
  ipv4_options           = lookup(each.value, "ipv4_options", null)
  jump_target            = lookup(each.value, "jump_target", null)
  layer7_protocol        = lookup(each.value, "layer7_protocol", null)
  limit                  = lookup(each.value, "limit", null)
  log                    = lookup(each.value, "log", null)
  log_prefix             = lookup(each.value, "log_prefix", null)
  nth                    = lookup(each.value, "nth", null)
  out_bridge_port        = lookup(each.value, "out_bridge_port", null)
  out_bridge_port_list   = lookup(each.value, "out_bridge_port_list", null)
  out_interface          = lookup(each.value, "out_interface", null)
  out_interface_list     = lookup(each.value, "out_interface_list", null)
  packet_mark            = lookup(each.value, "packet_mark", null)
  packet_size            = lookup(each.value, "packet_size", null)
  per_connection_classifier = lookup(each.value, "per_connection_classifier", null)
  place_before           = lookup(each.value, "place_before", null)
  port                   = lookup(each.value, "port", null)
  priority               = lookup(each.value, "priority", null)
  protocol               = lookup(each.value, "protocol", null)
  psd                    = lookup(each.value, "psd", null)
  random                 = lookup(each.value, "random", null)
  randomise_ports        = lookup(each.value, "randomise_ports", null)
  routing_mark           = lookup(each.value, "routing_mark", null)
  same_not_by_dst        = lookup(each.value, "same_not_by_dst", null)
  src_address            = lookup(each.value, "src_address", null)
  src_address_list       = lookup(each.value, "src_address_list", null)
  src_address_type       = lookup(each.value, "src_address_type", null)
  src_mac_address        = lookup(each.value, "src_mac_address", null)
  src_port               = lookup(each.value, "src_port", null)
  tcp_mss                = lookup(each.value, "tcp_mss", null)
  time                   = lookup(each.value, "time", null)
  to_addresses           = lookup(each.value, "to_addresses", null)
  to_ports               = lookup(each.value, "to_ports", null)
  ttl                    = lookup(each.value, "ttl", null)
}

resource "routeros_interface_list" "interface_lists" {
  for_each = { for list in var.interface_lists : list.name => list }

  name        = each.value.name
  comment     = lookup(each.value, "comment", null)
}

resource "routeros_interface_list_member" "interface_list_members" {
  for_each = { for member in flatten([for list in var.interface_lists : [for p in list.members : { interface_list = list.name, interface = p }]]) : "${member.interface_list}-${member.interface}" => member }

  list       = each.value.interface_list
  interface  = each.value.interface
  comment    = lookup(local.interface_lists_map[each.value.interface_list], "comment", null)

  depends_on = [
    routeros_interface_list.interface_lists
  ]
}

resource "routeros_interface_vxlan" "vxlans" {
  for_each = { for vxlan in var.vxlan_interfaces : vxlan.name => vxlan }

  name        = each.value.name
  mtu         = lookup(each.value, "mtu", null)
  vni         = each.value.vni
  comment     = lookup(each.value, "comment", null)
  disabled    = lookup(each.value, "disabled", null)
}

resource "routeros_interface_vxlan_vteps" "vxlan_vteps" {
  for_each = { for vtep in var.vxlan_vteps : "${vtep.interface}-${vtep.remote_ip}" => vtep }

  interface  = each.value.interface
  remote_ip  = each.value.remote_ip
  port       = lookup(each.value, "port", null)
  comment    = lookup(each.value, "comment", null)

  depends_on = [
    routeros_interface_vxlan.vxlans
  ]
}

resource "routeros_routing_bgp_connection" "bgp_connections" {
  for_each = { for conn in var.bgp_connections : "${conn.name}-${conn.remote.address}" => conn }

  name               = each.value.name
  as                 = each.value.as
  remote {
    address          = each.value.remote.address
    as               = each.value.remote.as
  }
  local {
    role             = each.value.local.role
    address          = each.value.local.address
  }
  connect            = each.value.connect
  listen             = each.value.listen
  comment            = lookup(each.value, "comment", null)
}

resource "routeros_interface_veth" "veths" {
  for_each = { for veth in var.veths : veth.name => veth }
  name       = each.value.name
  address    = each.value.address
  gateway    = each.value.gateway
  comment    = lookup(each.value, "comment", null)
}

resource "routeros_interface_bridge" "bridges" {
  for_each = { for b in var.bridges : b.name => b }
  name           = each.value.name
  comment        = lookup(each.value, "comment", null)
}

resource "routeros_interface_bridge_port" "bridge_ports" {
  for_each = { for bp in flatten([for b in var.bridges : [for p in b.ports : { bridge = b.name, port = p }]]) : "${bp.bridge}-${bp.port}" => bp }
  bridge    = each.value.bridge
  interface = each.value.port

  depends_on = [ routeros_interface_bridge.bridges ]
}

resource "routeros_file" "files" {
  for_each = { for f in var.files : f.name => f }

  name        = each.value.name
  contents    = file(each.value.contents)
  depends_on = [ routeros_container_mounts.container_mounts ]
}

resource "routeros_container_mounts" "container_mounts" {
  for_each = { for f in var.container_mounts : f.name => f }

  name           = each.value.name
  src            = each.value.src
  dst            = each.value.dst
}

resource "routeros_container_config" "container_config" {
  registry_url = var.container_config.registry_url
  ram_high     = var.container_config.ram_high
  tmpdir       = var.container_config.tmpdir
  layer_dir    = var.container_config.layer_dir
}

resource "routeros_container" "containers" {
  for_each = { for c in var.containers : c.hostname => c }

    remote_image  = each.value.remote_image
    interface     = each.value.interface
    hostname      = each.value.hostname
    start_on_boot = lookup(each.value, "start_on_boot", null)
    stop_signal   = lookup(each.value, "stop_signal", null)
    root_dir      = lookup(each.value, "root_dir", null)
    mounts        = lookup(each.value, "mounts", null)
    logging       = lookup(each.value, "logging", null)
    running       = lookup(each.value, "running", null)
    user          = lookup(each.value, "user", null)
    cmd           = lookup(each.value, "cmd", null)
    comment       = lookup(each.value, "comment", null)

    depends_on = [ 
      routeros_container_config.container_config, 
      routeros_container_mounts.container_mounts 
    ]
}