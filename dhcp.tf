resource "routeros_ip_dhcp_server_network" "dhcp_networks" {
  for_each = { for net in var.dhcp_server_networks : net.address => net }

  address    = each.value.address
  gateway    = each.value.gateway
  dns_server = each.value.dns_server
  comment    = each.value.comment
}

resource "routeros_ip_dhcp_server" "dhcp_servers" {
  for_each = { for s in var.dhcp_servers : s.name => s }

  address_pool = each.value.address_pool
  interface    = each.value.interface
  name         = each.value.name
  comment      = each.value.comment
  depends_on = [
    routeros_ip_pool.dhcp_pools,
    routeros_ip_dhcp_server_network.dhcp_networks,
    routeros_ip_address.ip_addresses
  ]
}
