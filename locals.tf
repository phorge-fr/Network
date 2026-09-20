locals {
  comment = "tofu;;;"

  # The router takes the last usable address of each network, and DHCP exists only where a pool is given
  networks = {
    for name, n in var.networks : name => merge(n, {
      gateway   = cidrhost(n.cidr, -2)
      prefix    = split("/", n.cidr)[1]
      list_name = coalesce(n.address_list, "${name}-nodes")
    })
  }

  dhcp_networks = { for name, n in local.networks : name => n if n.dhcp_pool != null }

  ip_addresses = merge(
    {
      for name, n in local.networks : "${name}-${n.gateway}/${n.prefix}" => {
        interface = name
        address   = "${n.gateway}/${n.prefix}"
        network   = null
        comment   = local.comment
      }
    },
    { for ip in var.ip_addresses : "${ip.interface}-${ip.address}" => ip },
  )

  address_list_entries = merge(
    {
      for e in flatten([
        for name, n in local.networks : [for node in n.nodes : { list = n.list_name, address = node }]
      ]) : "${e.list}-${e.address}" => merge(e, { comment = local.comment })
    },
    { for e in var.firewall_address_lists : "${e.list}-${e.address}" => e },
  )

  interface_lists = merge(
    { phorge = { name = "phorge", comment = local.comment, members = keys(var.networks) } },
    { for l in var.interface_lists : l.name => l },
  )

  interface_list_members = {
    for m in flatten([
      for l in local.interface_lists : [for p in l.members : { interface_list = l.name, interface = p }]
    ]) : "${m.interface_list}-${m.interface}" => m
  }

  # Names of the interfaces created here: resources that use them wait for the interface to exist
  interface_names = merge(
    { for k, v in routeros_interface_vlan.vlans : k => v.name },
    { for k, v in routeros_interface_bridge.bridges : k => v.name },
    { for k, v in routeros_interface_veth.veths : k => v.name },
    { for k, v in routeros_interface_vxlan.vxlans : k => v.name },
  )
}
