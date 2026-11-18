```bash
# rlang
curl -fsSL https://raw.githubusercontent.com/eoda-dev/posit-infra/main/install/get-rlang.sh | sh

curl -fsSL https://raw.githubusercontent.com/eoda-dev/posit-infra/main/install/get-rlang.sh | R_VERSION=4.5.3 sh

# python
curl -fsSL https://raw.githubusercontent.com/eoda-dev/posit-infra/main/install/get-python.sh | sh

curl -fsSL https://raw.githubusercontent.com/eoda-dev/posit-infra/main/install/get-python.sh | PYTHON_VERSION=3.10 sh

# posit pro
curl -1sLf https://dl.posit.co/public/pro/setup.deb.sh | sudo -E bash

sudo apt install rstudio-server
sudo apt install rstudio-connect
```

