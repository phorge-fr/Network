resource "routeros_file" "files" {
  for_each = { for f in var.files : f.name => f }

  name       = each.value.name
  contents   = file(each.value.contents)
  depends_on = [routeros_container_mounts.container_mounts]
}

resource "routeros_container_mounts" "container_mounts" {
  for_each = { for f in var.container_mounts : f.name => f }

  name = each.value.name
  src  = each.value.src
  dst  = each.value.dst
}

resource "routeros_container_config" "container_config" {
  registry_url = var.container_config.registry_url
  ram_high     = var.container_config.ram_high
  tmpdir       = var.container_config.tmpdir
  layer_dir    = var.container_config.layer_dir
}

resource "routeros_container" "containers" {
  for_each = { for c in var.containers : c.hostname => c }

  remote_image  = each.value.remote_image
  interface     = each.value.interface
  hostname      = each.value.hostname
  start_on_boot = each.value.start_on_boot
  root_dir      = each.value.root_dir
  mounts        = each.value.mounts
  logging       = each.value.logging
  running       = each.value.running
  user          = each.value.user
  cmd           = each.value.cmd
  comment       = each.value.comment

  depends_on = [
    routeros_container_config.container_config,
    routeros_container_mounts.container_mounts
  ]
}
