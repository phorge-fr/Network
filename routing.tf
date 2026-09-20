resource "routeros_routing_bgp_connection" "bgp_connections" {
  for_each = { for conn in var.bgp_connections : "${conn.name}-${conn.remote.address}" => conn }

  name = each.value.name
  as   = each.value.as
  remote {
    address = each.value.remote.address
    as      = each.value.remote.as
  }
  local {
    role    = each.value.local.role
    address = each.value.local.address
  }
  connect = each.value.connect
  listen  = each.value.listen
  comment = each.value.comment
}
