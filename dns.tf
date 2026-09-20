resource "routeros_ip_dns_record" "name_records" {
  for_each = { for record in var.dns_records : "${record.type}-${record.name}" => record }

  name    = each.value.name
  address = each.value.address
  cname   = each.value.cname
  type    = each.value.type
  comment = each.value.comment

}
