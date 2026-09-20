locals {
  interface_lists_map = { for list in var.interface_lists : list.name => list }
}
