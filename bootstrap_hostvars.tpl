---
wireguard_address: {{ .IntIP }}/24
PrivateKey: {{ .PrivateKey }}
wireguard_persistent_keepalive: '30'
wireguard_endpoint: {{ .ExtIP }}

