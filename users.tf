# RouterOS users and groups declared in terraform.tfvars (user_groups, users). Only what the variables
# list is managed: the account and the group of the base configuration are left alone.
#
# A user can be limited to the nodes of some networks (allowed_from) or to explicit prefixes
# (allowed_addresses): RouterOS then refuses the login from anywhere else. The passwords never go in
# terraform.tfvars, they come from the sensitive user_passwords variable (see .env.example).

resource "routeros_system_user_group" "groups" {
  for_each = var.user_groups

  name    = each.key
  policy  = each.value.policy
  comment = each.value.comment
}

resource "routeros_system_user" "users" {
  for_each = var.users

  name = each.key
  # A group of the base configuration is not in user_groups: fall back to its name
  group    = try(routeros_system_user_group.groups[each.value.group].name, each.value.group)
  password = lookup(var.user_passwords, each.key, null)
  address  = local.user_sources[each.key] != "" ? local.user_sources[each.key] : null
  comment  = each.value.comment

  lifecycle {
    precondition {
      condition     = length(lookup(var.user_passwords, each.key, "")) >= 24
      error_message = "user_passwords needs a password of at least 24 characters for the user ${each.key}."
    }

    # An empty list of sources means "from anywhere": never let a restriction silently resolve to that
    precondition {
      condition     = length(each.value.allowed_from) + length(each.value.allowed_addresses) == 0 || local.user_sources[each.key] != ""
      error_message = "The networks in allowed_from have no nodes, so the user ${each.key} would not be restricted at all."
    }
  }
}
