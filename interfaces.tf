resource "routeros_interface_vlan" "vlans" {
  for_each = local.networks

  interface = var.vlan_parent_interface
  name      = each.key
  vlan_id   = each.value.vlan_id
  mtu       = each.value.mtu
  comment   = local.comment

  lifecycle {
    prevent_destroy = true
  }
}

resource "routeros_interface_veth" "veths" {
  for_each = { for veth in var.veths : veth.name => veth }

  name    = each.value.name
  address = each.value.address
  gateway = each.value.gateway
  comment = each.value.comment
}

resource "routeros_interface_bridge" "bridges" {
  for_each = { for b in var.bridges : b.name => b }

  name    = each.value.name
  comment = each.value.comment

  lifecycle {
    prevent_destroy = true
  }
}

resource "routeros_interface_bridge_port" "bridge_ports" {
  for_each = { for bp in flatten([for b in var.bridges : [for p in b.ports : { bridge = b.name, port = p }]]) : "${bp.bridge}-${bp.port}" => bp }

  bridge    = routeros_interface_bridge.bridges[each.value.bridge].name
  interface = lookup(local.interface_names, each.value.port, each.value.port)

  lifecycle {
    prevent_destroy = true
  }
}

resource "routeros_interface_list" "interface_lists" {
  for_each = local.interface_lists

  name    = each.value.name
  comment = each.value.comment
}

resource "routeros_interface_list_member" "interface_list_members" {
  for_each = local.interface_list_members

  list      = routeros_interface_list.interface_lists[each.value.interface_list].name
  interface = lookup(local.interface_names, each.value.interface, each.value.interface)
  comment   = local.interface_lists[each.value.interface_list].comment
}

resource "routeros_interface_vxlan" "vxlans" {
  for_each = { for vxlan in var.vxlan_interfaces : vxlan.name => vxlan }

  name     = each.value.name
  mtu      = each.value.mtu
  vni      = each.value.vni
  comment  = each.value.comment
  disabled = each.value.disabled
}

resource "routeros_interface_vxlan_vteps" "vxlan_vteps" {
  for_each = { for vtep in var.vxlan_vteps : "${vtep.interface}-${vtep.remote_ip}" => vtep }

  interface = routeros_interface_vxlan.vxlans[each.value.interface].name
  remote_ip = each.value.remote_ip
  port      = each.value.port
  comment   = each.value.comment
}
