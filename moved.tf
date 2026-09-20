moved {
  from = routeros_ip_firewall_filter.firewall_rules["forward-accept--tofu;;; Allow Hproxy to core cluster Ingress-10.2.0.11-"]
  to   = routeros_ip_firewall_filter.firewall_rules["hproxy-to-core-ingress"]
}

moved {
  from = routeros_ip_firewall_filter.firewall_rules["forward-accept--tofu;;; Allow Hproxy to svc cluster Ingress-10.3.0.11-"]
  to   = routeros_ip_firewall_filter.firewall_rules["hproxy-to-svc-ingress"]
}

moved {
  from = routeros_ip_firewall_filter.firewall_rules["forward-accept--tofu;;; Allow core cluster nodes to stor rustfs S3 (Longhorn backups)--"]
  to   = routeros_ip_firewall_filter.firewall_rules["s3-core-to-stor"]
}

moved {
  from = routeros_ip_firewall_filter.firewall_rules["forward-accept--tofu;;; Allow ctrl cluster nodes to push metrics/logs to core (Alloy)-10.2.0.10-"]
  to   = routeros_ip_firewall_filter.firewall_rules["alloy-ctrl-to-core"]
}

moved {
  from = routeros_ip_firewall_filter.firewall_rules["forward-accept--tofu;;; Allow stor nodes to push metrics/logs to core (Alloy)-10.2.0.10-"]
  to   = routeros_ip_firewall_filter.firewall_rules["alloy-stor-to-core"]
}

moved {
  from = routeros_ip_firewall_filter.firewall_rules["forward-accept--tofu;;; Allow svc cluster nodes to push metrics/logs to core (Alloy)-10.2.0.10-"]
  to   = routeros_ip_firewall_filter.firewall_rules["alloy-svc-to-core"]
}

moved {
  from = routeros_ip_firewall_filter.firewall_rules["forward-accept--tofu;;; Allow svc cluster nodes to stor nodes over NFS/TCP--"]
  to   = routeros_ip_firewall_filter.firewall_rules["nfs-tcp-svc-to-stor"]
}

moved {
  from = routeros_ip_firewall_filter.firewall_rules["forward-accept--tofu;;; Allow svc cluster nodes to stor nodes over NFS/UDP--"]
  to   = routeros_ip_firewall_filter.firewall_rules["nfs-udp-svc-to-stor"]
}

moved {
  from = routeros_ip_firewall_filter.firewall_rules["forward-drop--tofu;;; Drop 'this' network-192.168.2.0/24-"]
  to   = routeros_ip_firewall_filter.firewall_rules["drop-this-network"]
}

moved {
  from = routeros_ip_firewall_filter.firewall_rules["forward-drop--tofu;;; Drop Containers to phorge--"]
  to   = routeros_ip_firewall_filter.firewall_rules["drop-containers-to-phorge"]
}

moved {
  from = routeros_ip_firewall_filter.firewall_rules["forward-drop--tofu;;; Drop overlay network-192.168.1.0/24-"]
  to   = routeros_ip_firewall_filter.firewall_rules["drop-overlay-network"]
}

moved {
  from = routeros_ip_firewall_filter.firewall_rules["forward-drop--tofu;;; Drop phorge to phorge--"]
  to   = routeros_ip_firewall_filter.firewall_rules["drop-phorge-to-phorge"]
}

moved {
  from = routeros_ip_firewall_filter.firewall_rules["input-accept--tofu;;; Allow TCP DNS from !LAN--"]
  to   = routeros_ip_firewall_filter.firewall_rules["dns-tcp-from-non-lan"]
}

moved {
  from = routeros_ip_firewall_filter.firewall_rules["input-accept--tofu;;; Allow UDP DNS from !LAN--"]
  to   = routeros_ip_firewall_filter.firewall_rules["dns-udp-from-non-lan"]
}
