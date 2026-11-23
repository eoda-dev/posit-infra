# posit-infra

```bash
# download env.sh (curl or wget), edit the settings, then source it (bash/zsh)
curl -fsSL -O https://raw.githubusercontent.com/eoda-dev/posit-infra/main/env.sh
# or
wget -q https://raw.githubusercontent.com/eoda-dev/posit-infra/main/env.sh
source env.sh

# aliases for current session only
source <(curl -fsSL https://raw.githubusercontent.com/eoda-dev/posit-infra/main/aliases.sh)

# connect starter config
basic-config-connect | sudo tee /etc/rstudio-connect/rstudio-connect.gcfg
```

