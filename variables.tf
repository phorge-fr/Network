variable "hosturl" {
  description = "RouterOS host URL"
  type        = string
}

variable "username" {
  description = "RouterOS username"
  type        = string
}

variable "password" {
  description = "RouterOS password"
  type        = string
  sensitive   = true
}

variable "networks" {
  description = "Workload VLANs, keyed by name. The name is the interface name and the router takes the last usable address of the subnet. DHCP, the phorge interface list and the <name>-nodes address list derive from it."
  type = map(object({
    vlan_id      = number
    cidr         = string
    mtu          = optional(number, 8152)
    dhcp_pool    = optional(string)
    nodes        = optional(list(string), [])
    address_list = optional(string)
  }))

  validation {
    condition     = alltrue([for n in values(var.networks) : n.vlan_id >= 1 && n.vlan_id <= 4094])
    error_message = "vlan_id must be between 1 and 4094."
  }

  validation {
    condition     = length(distinct([for n in values(var.networks) : n.vlan_id])) == length(var.networks)
    error_message = "Each network needs its own vlan_id."
  }

  validation {
    condition     = alltrue([for n in values(var.networks) : can(cidrhost(n.cidr, 0))])
    error_message = "cidr must be a valid IPv4 CIDR such as 10.1.0.0/24."
  }

  validation {
    condition     = alltrue([for n in values(var.networks) : n.mtu >= 68 && n.mtu <= 65535])
    error_message = "mtu must be between 68 and 65535."
  }

  validation {
    condition     = alltrue([for name in keys(var.networks) : length(name) <= 15])
    error_message = "Network names become interface names, which RouterOS limits to 15 characters."
  }
}

variable "vlan_parent_interface" {
  description = "Interface that carries the VLAN sub-interfaces"
  type        = string
  default     = "bridge"
}

variable "ip_addresses" {
  description = "Extra IP addresses on interfaces that are not in networks (the gateway address of each network is derived)"
  type = list(object({
    interface = string
    address   = string
    network   = optional(string)
    comment   = optional(string, "tofu;;;")
  }))
  default = []

  validation {
    condition     = alltrue([for a in var.ip_addresses : can(cidrhost(a.address, 0))])
    error_message = "address must be an IPv4 address with a prefix length, such as 172.17.0.1/24."
  }
}

variable "dns_records" {
  description = "List of DNS records"
  type = list(object({
    name    = string
    address = optional(string)
    cname   = optional(string)
    type    = string
    comment = optional(string, "tofu;;;")
  }))

  validation {
    condition     = alltrue([for r in var.dns_records : contains(["A", "AAAA", "CNAME", "FWD", "MX", "NS", "NXDOMAIN", "SRV", "TXT"], r.type)])
    error_message = "type is not a RouterOS DNS record type."
  }
}

variable "firewall_rules" {
  description = "List of firewall rules"
  type = list(object({
    action = string
    chain  = string

    address_list              = optional(string)
    address_list_timeout      = optional(string)
    comment                   = optional(string)
    connection_bytes          = optional(string)
    connection_limit          = optional(string)
    connection_mark           = optional(string)
    connection_nat_state      = optional(string)
    connection_rate           = optional(string)
    connection_state          = optional(string)
    connection_type           = optional(string)
    content                   = optional(string)
    disabled                  = optional(bool)
    dscp                      = optional(number)
    dst_address               = optional(string)
    dst_address_list          = optional(string)
    dst_address_type          = optional(string)
    dst_limit                 = optional(string)
    dst_port                  = optional(string)
    fragment                  = optional(bool)
    hotspot                   = optional(string)
    hw_offload                = optional(bool)
    icmp_options              = optional(string)
    in_bridge_port            = optional(string)
    in_bridge_port_list       = optional(string)
    in_interface              = optional(string)
    in_interface_list         = optional(string)
    ingress_priority          = optional(number)
    ipsec_policy              = optional(string)
    ipv4_options              = optional(string)
    jump_target               = optional(string)
    layer7_protocol           = optional(string)
    limit                     = optional(string)
    log                       = optional(bool)
    log_prefix                = optional(string)
    nth                       = optional(string)
    out_bridge_port           = optional(string)
    out_bridge_port_list      = optional(string)
    out_interface             = optional(string)
    out_interface_list        = optional(string)
    packet_mark               = optional(string)
    packet_size               = optional(string)
    per_connection_classifier = optional(string)
    place_before              = optional(string)
    port                      = optional(string)
    priority                  = optional(number)
    protocol                  = optional(string)
    psd                       = optional(string)
    random                    = optional(number)
    reject_with               = optional(string)
    routing_mark              = optional(string)
    routing_table             = optional(string)
    src_address               = optional(string)
    src_address_list          = optional(string)
    src_address_type          = optional(string)
    src_mac_address           = optional(string)
    src_port                  = optional(string)
    tcp_flags                 = optional(string)
    tcp_mss                   = optional(string)
    time                      = optional(string)
    tls_host                  = optional(string)
    ttl                       = optional(string)
  }))

  validation {
    condition     = alltrue([for r in var.firewall_rules : contains(["input", "forward", "output"], r.chain)])
    error_message = "chain must be input, forward or output."
  }

  validation {
    condition = alltrue([
      for r in var.firewall_rules : contains(
        ["accept", "add-dst-to-address-list", "add-src-to-address-list", "drop", "fasttrack-connection", "jump", "log", "passthrough", "reject", "return", "tarpit"],
        r.action
      )
    ])
    error_message = "action is not a RouterOS firewall filter action."
  }
}

variable "firewall_address_lists" {
  description = "Extra address list entries (the <name>-nodes lists are derived from networks)"
  type = list(object({
    list    = string
    address = string
    comment = optional(string, "tofu;;;")
  }))
  default = []
}

variable "firewall_nat_rules" {
  description = "List of NAT rules"
  type = list(object({
    action            = string
    chain             = string
    src_address       = optional(string)
    dst_address       = optional(string)
    out_interface     = optional(string)
    in_interface_list = optional(string)
    to_addresses      = optional(string)
    to_ports          = optional(string)
    protocol          = optional(string)
    dst_port          = optional(string)
    comment           = optional(string, "tofu;;;")
  }))

  validation {
    condition     = alltrue([for r in var.firewall_nat_rules : contains(["srcnat", "dstnat"], r.chain)])
    error_message = "chain must be srcnat or dstnat."
  }

  validation {
    condition = alltrue([
      for r in var.firewall_nat_rules : contains(
        ["accept", "add-dst-to-address-list", "add-src-to-address-list", "dst-nat", "jump", "log", "masquerade", "netmap", "passthrough", "redirect", "return", "same", "src-nat"],
        r.action
      )
    ])
    error_message = "action is not a RouterOS NAT action."
  }
}

variable "interface_lists" {
  description = "Extra interface lists (the phorge list is derived from networks)"
  type = list(object({
    name    = string
    comment = optional(string, "tofu;;;")
    members = optional(list(string), [])
  }))
  default = []
}

variable "vxlan_interfaces" {
  description = "List of VXLAN interfaces"
  type = list(object({
    name     = string
    vni      = number
    mtu      = optional(number)
    comment  = optional(string, "tofu;;;")
    disabled = optional(bool)
  }))
  default = []
}

variable "vxlan_vteps" {
  description = "List of VXLAN VTEPs"
  type = list(object({
    interface = string
    remote_ip = string
    port      = optional(number)
    comment   = optional(string, "tofu;;;")
  }))
  default = []
}

variable "bgp_connections" {
  description = "List of BGP connections"
  type = list(object({
    name = string
    as   = number
    remote = object({
      address = string
      as      = number
    })
    local = object({
      role    = string
      address = string
    })
    connect = optional(bool)
    listen  = optional(bool)
    comment = optional(string, "tofu;;;")
  }))
  default = []
}

variable "veths" {
  description = "List of veth interfaces"
  type = list(object({
    name    = string
    address = list(string)
    gateway = string
    comment = optional(string, "tofu;;;")
  }))
}

variable "bridges" {
  description = "List of bridge interfaces"
  type = list(object({
    name    = string
    comment = optional(string, "tofu;;;")
    ports   = optional(list(string), [])
  }))
}

variable "files" {
  description = "List of files to upload to the RouterOS device"
  type = list(object({
    name     = string
    contents = string
  }))
}

variable "container_mounts" {
  description = "List of container mounts"
  type = list(object({
    name = string
    src  = string
    dst  = string
  }))
}

variable "container_config" {
  description = "Container configurations"
  type = object({
    registry_url = optional(string, "https://registry-1.docker.io")
    ram_high     = optional(string, "128")
    tmpdir       = optional(string, "usb1/tmp")
    layer_dir    = optional(string)
  })
}

variable "containers" {
  description = "List of containers"
  type = list(object({
    remote_image  = string
    interface     = string
    start_on_boot = optional(bool, true)
    root_dir      = optional(string)
    mounts        = optional(list(string), [])
    logging       = optional(bool, true)
    hostname      = string
    running       = optional(bool, true)
    user          = optional(string)
    cmd           = optional(string)
    comment       = optional(string, "tofu;;;")
  }))
}
