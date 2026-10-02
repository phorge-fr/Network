# NTP: the router is the single time source for the whole Phorge infra. Every
# host's systemd-timesyncd syncs against its own VLAN gateway (Ansible repo,
# playbooks/setup-timesync.yml), so the router must keep its own clock accurate
# - client, against public pool servers - and serve it (server, admitted by the
# ntp-from-phorge input rule in terraform.tfvars). Ceph mon quorum and OVN's
# clustered databases care about inter-node clock consistency, which one shared
# source guarantees.
resource "routeros_system_ntp_client" "router" {
  enabled = true
  servers = ["0.fr.pool.ntp.org", "1.fr.pool.ntp.org", "2.fr.pool.ntp.org"]
}

resource "routeros_system_ntp_server" "router" {
  enabled = true
}