resource "routeros_ip_address" "ip_addresses" {
  for_each = { for ip in var.ip_addresses : "${ip.interface}-${ip.address}" => ip }

  interface = each.value.interface
  address   = each.value.address
  network   = each.value.network
  comment   = each.value.comment
  depends_on = [
    routeros_interface_vlan.vlans,
    routeros_interface_bridge.bridges,
    routeros_interface_vxlan.vxlans
  ]

  lifecycle {
    prevent_destroy = true
  }
}

resource "routeros_ip_pool" "dhcp_pools" {
  for_each = { for pool in var.ip_pools : pool.name => pool }

  name    = each.value.name
  ranges  = each.value.ranges
  comment = each.value.comment
}
