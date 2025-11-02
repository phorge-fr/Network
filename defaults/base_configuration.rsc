# --- Customization ---

/system note set show-at-login=yes show-at-cli-login=yes note="Welcome to Phorge Cloud Infrastructure. Unauthorized access is prohibited."

# --- DNS ---

/ip dns set servers=1.1.1.1 allow-remote-requests=yes
/ip dns forwarders add name=default dns-servers=1.1.1.1 comment="base_configuration;;;"
/ip dns static remove numbers=0
/ip dns static add address=192.168.2.254 type=A name=core0.phorge comment="base_configuration;;;"

# --- Security ---

/tool mac-server set allowed-interface-list=none 
/tool mac-server mac-winbox set allowed-interface-list=none 
/tool mac-server ping set enabled=no

/ip neighbor discovery-settings set discover-interface-list=none 

/tool bandwidth-server set enabled=no

/ip dns set allow-remote-requests=no

/ip proxy set enabled=no
/ip socks set enabled=no
/ip upnp set enabled=no

/ip ssh set strong-crypto=yes

/lcd pin set pin-number=<1234> hide-pin-number=yes

/ip service disable api,api-ssl,ftp,telnet

# --- SSL/TLS---

/certificate
add name=root-cert common-name=Phorge-Core-0 days-valid=3650 key-usage=key-cert-sign,crl-sign
sign root-cert
/certificate
add name=https-cert common-name=Phorge-Core-0_HTTPS days-valid=3650
sign ca=root-cert https-cert

/ip service
set www-ssl certificate=https-cert disabled=no
set www disabled=yes

# --- Interfaces ---

/interface disable ether5,ether6,ether7,ether8,ether9,ether10,sfp1
/interface bridge port disable numbers=3,4,5,6,7,9

# --- DHCP ---

/ip pool set default-dhcp ranges=192.168.2.1-192.168.2.10 comment="base_configuration;;;"
/ip dhcp-server network set numbers=0 address=192.168.2.0/24 gateway=192.168.2.254 dns-server=192.168.2.254 comment="base_configuration;;;"

# --- Addressing ---

/ip address set numbers=0 interface=bridge address=192.168.2.254/24 network=192.168.2.0 comment="base_configuration;;;"

# -- Users ---

/user/add name=<us3r> password=<p4ssw0rd> group=full
/user/remove admin
