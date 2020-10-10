harden_linux_ufw_rules:
  - rule: allow
    to_port: 51820
    protocol: udp
  - rule: allow
    to_port: 22
    protocol: tcp

harden_linux_ufw_allow_networks:
  - "10.0.0.0/8"
  - "172.16.0.0/12"
  - "192.168.0.0/16"

harden_linux_ufw_defaults_user:
  "^DEFAULT_FORWARD_POLICY": 'DEFAULT_FORWARD_POLICY="ACCEPT"'

harden_linux_sysctl_settings_user:
  "net.ipv4.ip_forward": 1
  "net.ipv6.conf.default.forwarding": 1
  "net.ipv6.conf.all.forwarding": 1

harden_linux_root_password: $1$SomeSalt$NBvT8Ztmo2GQ7YGgV9d6P.
harden_linux_deploy_user: {{ .User }} 
harden_linux_deploy_user_password: $1$SomeSalt$NBvT8Ztmo2GQ7YGgV9d6P.
harden_linux_deploy_user_home: /home/ansible
harden_linux_deploy_user_public_keys:
  - {{ .PublicKey }}


