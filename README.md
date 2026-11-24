# posit-infra

```bash
# download posit-env.sh (curl or wget), edit the settings, then source it (bash/zsh)
curl -fsSL -O https://raw.githubusercontent.com/eoda-dev/posit-infra/main/posit-env.sh
# or
wget -q https://raw.githubusercontent.com/eoda-dev/posit-infra/main/posit-env.sh
source posit-env.sh

# aliases for current session only
source <(curl -fsSL https://raw.githubusercontent.com/eoda-dev/posit-infra/main/aliases.sh)

# connect starter config
basic-config-connect | sudo tee /etc/rstudio-connect/rstudio-connect.gcfg

# write connect config from your own template (back up the current one first)
backup-config-connect
my-config-connect | write-config-connect
```

