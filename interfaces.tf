resource "routeros_interface_vlan" "vlans" {
  for_each = { for v in var.vlans : "${v.interface}-${v.vlan_id}" => v }

  interface = each.value.interface
  name      = each.value.name
  vlan_id   = each.value.vlan_id
  mtu       = each.value.mtu
  comment   = each.value.comment

  lifecycle {
    prevent_destroy = true
  }
}

resource "routeros_interface_list" "interface_lists" {
  for_each = { for list in var.interface_lists : list.name => list }

  name    = each.value.name
  comment = each.value.comment
}

resource "routeros_interface_list_member" "interface_list_members" {
  for_each = { for member in flatten([for list in var.interface_lists : [for p in list.members : { interface_list = list.name, interface = p }]]) : "${member.interface_list}-${member.interface}" => member }

  list      = each.value.interface_list
  interface = each.value.interface
  comment   = local.interface_lists_map[each.value.interface_list].comment

  depends_on = [
    routeros_interface_list.interface_lists
  ]
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

  interface = each.value.interface
  remote_ip = each.value.remote_ip
  port      = each.value.port
  comment   = each.value.comment

  depends_on = [
    routeros_interface_vxlan.vxlans
  ]
}

resource "routeros_interface_veth" "veths" {
  for_each = { for veth in var.veths : veth.name => veth }
  name     = each.value.name
  address  = each.value.address
  gateway  = each.value.gateway
  comment  = each.value.comment
}

resource "routeros_interface_bridge" "bridges" {
  for_each = { for b in var.bridges : b.name => b }
  name     = each.value.name
  comment  = each.value.comment

  lifecycle {
    prevent_destroy = true
  }
}

resource "routeros_interface_bridge_port" "bridge_ports" {
  for_each  = { for bp in flatten([for b in var.bridges : [for p in b.ports : { bridge = b.name, port = p }]]) : "${bp.bridge}-${bp.port}" => bp }
  bridge    = each.value.bridge
  interface = each.value.port

  depends_on = [routeros_interface_bridge.bridges]

  lifecycle {
    prevent_destroy = true
  }
}
