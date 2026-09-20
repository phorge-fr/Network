resource "routeros_ip_dhcp_server_network" "dhcp_networks" {
  for_each = { for name, n in local.dhcp_networks : n.cidr => n }

  address    = each.key
  gateway    = each.value.gateway
  dns_server = [each.value.gateway]
  comment    = local.comment
}

resource "routeros_ip_dhcp_server" "dhcp_servers" {
  for_each = local.dhcp_networks

  name         = each.key
  interface    = routeros_interface_vlan.vlans[each.key].name
  address_pool = routeros_ip_pool.dhcp_pools[each.key].name
  comment      = local.comment

  depends_on = [
    routeros_ip_dhcp_server_network.dhcp_networks,
    routeros_ip_address.ip_addresses,
  ]
}
