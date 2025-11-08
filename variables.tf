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
  sensitive = true
}

variable "vlans" {
  description = "List of VLAN configurations"
  type = list(object({
    interface = string
    name      = string
    vlan_id   = number
    comment   = optional(string, "tofu;;;")
  }))
  default = []
}

variable "ip_addresses" {
  description = "List of IP address configurations"
  type = list(object({
    interface = string
    address   = string
    network   = optional(string)
    comment   = optional(string, "tofu;;;")
  }))
  default = []
}

variable "ip_pools" {
  description = "List of IP pool configurations"
  type = list(object({
    name      = string
    ranges = list(string)
    comment   = optional(string, "tofu;;;")
  }))
  default = []
}

variable "dhcp_server_networks" {
  description = "List of DHCP server network configurations"
  type = list(object({
    address = string
    gateway = string
    dns_server = optional(list(string), [])
    comment = optional(string, "tofu;;;")
  }))
  default = [] 
}

variable "dhcp_servers" {
  description = "List of DHCP server configurations"
  type = list(object({
    address_pool = string
    interface    = string
    name         = string
    comment      = optional(string, "tofu;;;")
  }))
  default = []
}

variable "dns_records" {
  description = "List of DNS records"
  type = list(object({
    name    = string
    address = string
    type    = optional(string, "A")
    comment = optional(string, "tofu;;;")
  }))
  default = []
}

variable "firewall_rules" {
  description = "List of firewall rules"
  type = list(object({
    action = string
    chain  = string

    address_list           = optional(string)
    address_list_timeout   = optional(string)
    comment                = optional(string)
    connection_bytes       = optional(string)
    connection_limit       = optional(string)
    connection_mark        = optional(string)
    connection_nat_state   = optional(string)
    connection_rate        = optional(string)
    connection_state       = optional(string)
    connection_type        = optional(string)
    content                = optional(string)
    disabled               = optional(bool)
    dscp                   = optional(number)
    dst_address            = optional(string)
    dst_address_list       = optional(string)
    dst_address_type       = optional(string)
    dst_limit              = optional(string)
    dst_port               = optional(string)
    fragment               = optional(bool)
    hotspot                = optional(string)
    hw_offload             = optional(bool)
    icmp_options           = optional(string)
    in_bridge_port         = optional(string)
    in_bridge_port_list    = optional(string)
    in_interface           = optional(string)
    in_interface_list      = optional(string)
    ingress_priority       = optional(number)
    ipsec_policy           = optional(string)
    ipv4_options           = optional(string)
    jump_target            = optional(string)
    layer7_protocol        = optional(string)
    limit                  = optional(string)
    log                    = optional(bool)
    log_prefix             = optional(string)
    nth                    = optional(string)
    out_bridge_port        = optional(string)
    out_bridge_port_list   = optional(string)
    out_interface          = optional(string)
    out_interface_list     = optional(string)
    packet_mark            = optional(string)
    packet_size            = optional(string)
    per_connection_classifier = optional(string)
    place_before           = optional(string)
    port                   = optional(string)
    priority               = optional(number)
    protocol               = optional(string)
    psd                    = optional(string)
    random                 = optional(number)
    reject_with            = optional(string)
    routing_mark           = optional(string)
    routing_table          = optional(string)
    src_address            = optional(string)
    src_address_list       = optional(string)
    src_address_type       = optional(string)
    src_mac_address        = optional(string)
    src_port               = optional(string)
    tcp_flags              = optional(string)
    tcp_mss                = optional(string)
    time                   = optional(string)
    tls_host               = optional(string)
    ttl                    = optional(string)
  }))
  default = []
}

variable "firewall_address_lists" {
  description = "List of address lists"
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
    dst_address       = optional(string)
    out_interface     = optional(string)
    in_interface_list = optional(string)
    to_addresses      = optional(string)
    to_ports          = optional(string)
    protocol          = optional(string)
    dst_port          = optional(string)
    comment           = optional(string, "tofu;;;")
  }))
  default = []
}

variable "interface_lists" {
  description = "List of interface lists"
  type = list(object({
    name    = string
    comment = optional(string, "tofu;;;")
  }))
  default = []
}

variable "interface_list_members" {
  description = "List of interface list members"
  type = list(object({
    interface_list = string
    interface      = string
    comment        = optional(string, "tofu;;;")
  }))
  default = []
}

variable "vxlan_interfaces" {
  description = "List of VXLAN interfaces"
  type = list(object({
    name      = string
    vni       = number
    mtu       = optional(number)
    comment   = optional(string, "tofu;;;")
    disabled  = optional(bool)
    hw        = optional(bool)
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
    name           = string
    as             = number
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