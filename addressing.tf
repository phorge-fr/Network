resource "routeros_ip_address" "ip_addresses" {
  for_each = local.ip_addresses

  interface = lookup(local.interface_names, each.value.interface, each.value.interface)
  address   = each.value.address
  network   = each.value.network
  comment   = each.value.comment

  lifecycle {
    prevent_destroy = true
  }
}

resource "routeros_ip_pool" "dhcp_pools" {
  for_each = local.dhcp_networks

  name    = each.key
  ranges  = [each.value.dhcp_pool]
  comment = local.comment
}
