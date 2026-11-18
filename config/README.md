```bash
# rserver.conf

# -- ssl
# -- self-signed certificate

# sudo apt install ssl-cert
ssl-enabled=1
ssl-certificate=/etc/ssl/certs/ssl-cert-snakeoil.pem
ssl-certificate-key=/etc/ssl/private/ssl-cert-snakeoil.key

launcher-sessions-callback-address=https://<hostname>
```

