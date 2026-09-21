data "routeros_ip_firewall" "fw" {
  rules {
    filter = {
      chain = "forward"
    }
  }
  rules {
    filter = {
      chain = "input"
    }
  }
  rules {
    filter = {
      chain = "output"
    }
  }
}

# output "rules" {
#   value = [for value in data.routeros_ip_firewall.fw.rules : [value.id, value.comment]]
# }

locals {
  firewall_rules = [
    for r in var.firewall_rules : merge(r, {
      dst_address = r.dst_ingress != null ? local.ingress_ips[r.dst_ingress] : r.dst_address
    })
  ]

  # Rules of one chain that sit above the same factory rule are moved together
  firewall_groups = {
    for key, rules in {
      for r in local.firewall_rules : "${r.chain}/${r.before != null ? r.before : "end of chain"}" => r...
      } : key => {
      chain  = rules[0].chain
      before = rules[0].before
      ids    = [for r in rules : r.id]
    }
  }

  firewall_anchors = {
    for key, g in local.firewall_groups : key => g.before == null ? [] : [
      for r in data.routeros_ip_firewall.fw.rules : r.id if r.chain == g.chain && r.comment == g.before && !r.dynamic
    ]
  }
}

resource "routeros_ip_firewall_filter" "firewall_rules" {
  for_each = { for r in local.firewall_rules : r.id => r }

  action = each.value.action
  chain  = each.value.chain

  address_list              = each.value.address_list
  address_list_timeout      = each.value.address_list_timeout
  comment                   = each.value.comment
  connection_bytes          = each.value.connection_bytes
  connection_limit          = each.value.connection_limit
  connection_mark           = each.value.connection_mark
  connection_nat_state      = each.value.connection_nat_state
  connection_rate           = each.value.connection_rate
  connection_state          = each.value.connection_state
  connection_type           = each.value.connection_type
  content                   = each.value.content
  disabled                  = each.value.disabled
  dscp                      = each.value.dscp
  dst_address               = each.value.dst_address
  dst_address_list          = each.value.dst_address_list
  dst_address_type          = each.value.dst_address_type
  dst_limit                 = each.value.dst_limit
  dst_port                  = each.value.dst_port
  fragment                  = each.value.fragment
  hotspot                   = each.value.hotspot
  hw_offload                = each.value.hw_offload
  icmp_options              = each.value.icmp_options
  in_bridge_port            = each.value.in_bridge_port
  in_bridge_port_list       = each.value.in_bridge_port_list
  in_interface              = each.value.in_interface
  in_interface_list         = each.value.in_interface_list
  ingress_priority          = each.value.ingress_priority
  ipsec_policy              = each.value.ipsec_policy
  ipv4_options              = each.value.ipv4_options
  jump_target               = each.value.jump_target
  layer7_protocol           = each.value.layer7_protocol
  limit                     = each.value.limit
  log                       = each.value.log
  log_prefix                = each.value.log_prefix
  nth                       = each.value.nth
  out_bridge_port           = each.value.out_bridge_port
  out_bridge_port_list      = each.value.out_bridge_port_list
  out_interface             = each.value.out_interface
  out_interface_list        = each.value.out_interface_list
  packet_mark               = each.value.packet_mark
  packet_size               = each.value.packet_size
  per_connection_classifier = each.value.per_connection_classifier
  port                      = each.value.port
  priority                  = each.value.priority
  protocol                  = each.value.protocol
  psd                       = each.value.psd
  random                    = each.value.random
  reject_with               = each.value.reject_with
  routing_mark              = each.value.routing_mark
  routing_table             = each.value.routing_table
  src_address               = each.value.src_address
  src_address_list          = each.value.src_address_list
  src_address_type          = each.value.src_address_type
  src_mac_address           = each.value.src_mac_address
  src_port                  = each.value.src_port
  tcp_flags                 = each.value.tcp_flags
  tcp_mss                   = each.value.tcp_mss
  time                      = each.value.time
  tls_host                  = each.value.tls_host
  ttl                       = each.value.ttl

  # Rules name address lists by string: wait for the entries, or a negated list is empty and matches everything
  depends_on = [routeros_ip_firewall_addr_list.address_lists]

  # Rules created before ids and routeros_move_items carry a place_before, which forces a new rule
  lifecycle {
    ignore_changes = [place_before]
  }
}

resource "routeros_move_items" "firewall_filter" {
  for_each = { for key, g in local.firewall_groups : key => g if length(g.ids) + (g.before != null ? 1 : 0) >= 2 }

  resource_path = "/ip/firewall/filter"
  sequence = concat(
    [for id in each.value.ids : routeros_ip_firewall_filter.firewall_rules[id].id],
    each.value.before == null ? [] : [try(local.firewall_anchors[each.key][0], "")],
  )

  lifecycle {
    precondition {
      condition     = each.value.before == null ? true : length(local.firewall_anchors[each.key]) == 1
      error_message = "The factory rule of \"${each.key}\" was not found exactly once on the router."
    }
  }
}

resource "routeros_ip_firewall_addr_list" "address_lists" {
  for_each = local.address_list_entries

  list    = each.value.list
  address = each.value.address
  comment = each.value.comment
}

resource "routeros_ip_firewall_nat" "nat_rules" {
  for_each = { for rule in var.firewall_nat_rules :
    "${rule.chain}-${rule.action}-${rule.out_interface != null ? rule.out_interface : ""}-${rule.comment != null ? rule.comment : ""}" => rule
  }

  action            = each.value.action
  chain             = each.value.chain
  comment           = each.value.comment
  dst_address       = each.value.dst_address
  dst_port          = each.value.dst_port
  in_interface_list = each.value.in_interface_list
  out_interface     = each.value.out_interface
  protocol          = each.value.protocol
  src_address       = each.value.src_address
  to_addresses      = each.value.to_addresses
  to_ports          = each.value.to_ports
}
