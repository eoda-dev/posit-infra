alias ls-r="ls -l /opt/R"
alias ls-py="ls -l /opt/python"
alias ls-quarto="ls -l /opt/quarto"

alias get-r="curl -fsSL https://raw.githubusercontent.com/eoda-dev/posit-infra/main/install/get-rlang.sh | sh"
alias get-py="curl -fsSL https://raw.githubusercontent.com/eoda-dev/posit-infra/main/install/get-python.sh | sh"
alias get-quarto="curl -fsSL https://raw.githubusercontent.com/eoda-dev/posit-infra/main/install/get-quarto.sh | sh"
alias get-sys-deps="curl -fsSL https://raw.githubusercontent.com/eoda-dev/posit-infra/main/install/get-sys-deps.sh | sh"

alias add-posit-apt-sources="curl -1sLf https://dl.posit.co/public/pro/setup.deb.sh | sudo bash"
alias get-workbench="sudo apt install -y rstudio-server"
alias get-connect="sudo apt install -y rstudio-connect"

alias status-workbench="sudo systemctl --no-pager -l status rstudio-server"
alias status-connect="sudo systemctl --no-pager -l status rstudio-connect"
alias restart-workbench="sudo systemctl restart rstudio-server && sleep 2 && sudo systemctl --no-pager -l status rstudio-server"
alias restart-connect="sudo systemctl restart rstudio-connect && sleep 2 && sudo systemctl --no-pager -l status rstudio-connect"
alias sysinfo="curl -fsSL https://raw.githubusercontent.com/eoda-dev/posit-infra/main/core/sysinfo.sh | sh"

alias get-pro-drivers="sudo apt install -y rstudio-drivers"
alias ls-pro-drivers="ls -l /opt/rstudio-drivers"
alias configure-pro-drivers="sudo cp /etc/odbcinst.ini /etc/odbcinst.ini.bak && cat /opt/rstudio-drivers/odbcinst.ini.sample | sudo tee -a /etc/odbcinst.ini"

alias run-pg-test="curl -fsSL https://raw.githubusercontent.com/eoda-dev/posit-infra/main/db/run-testdb.sh | sh"
alias stop-pg-test='podman stop "${PG_CONTAINER:-pg-test}"'
alias test-pg-conn="curl -fsSL https://raw.githubusercontent.com/eoda-dev/posit-infra/main/db/test-pg-conn.sh | sh"
alias test-odbcini-r="curl -fsSL https://raw.githubusercontent.com/eoda-dev/posit-infra/main/db/test-pg-conn-r.sh | sh"
alias add-odbcini-entry="curl -fsSL https://raw.githubusercontent.com/eoda-dev/posit-infra/main/db/add-odbcini-entry.sh | sh"
alias config-odbcini="sudo vim /etc/odbc.ini"
alias get-r-pkgs="curl -fsSL https://raw.githubusercontent.com/eoda-dev/posit-infra/main/rlang/install-packages.sh | sh"

alias run-gitea="curl -fsSL https://raw.githubusercontent.com/eoda-dev/posit-infra/main/containers/run-gitea.sh | sh"
alias stop-gitea="podman stop gitea"

alias run-rstudio="curl -fsSL https://raw.githubusercontent.com/eoda-dev/posit-infra/main/containers/run-rstudio.sh | sh"
alias stop-rstudio='podman stop "${RSTUDIO_CONTAINER:-rstudio}"'

alias config-connect="sudo vi /etc/rstudio-connect/rstudio-connect.gcfg"
alias backup-config-connect='(f=/etc/rstudio-connect/rstudio-connect.gcfg; b="$f.bak.$(date +%Y%m%d-%H%M%S)"; sudo cp -p "$f" "$b" && echo "Backup: $b")'
alias write-config-connect="sudo tee /etc/rstudio-connect/rstudio-connect.gcfg >/dev/null"
alias logs-connect='GREEN="\033[0;32m" && NC="\033[0m" && echo -e ${GREEN}"\n Posit Connect Logs:\n"${NC} && sudo tail -n 15 /var/log/rstudio/rstudio-connect/rstudio-connect.log'
alias license-status-connect="sudo /opt/rstudio-connect/bin/license-manager status"

alias get-certificate='sudo apt install -y certbot && sudo certbot certonly --standalone -d "$FQDN" --register-unsafely-without-email --agree-tos --non-interactive'

alias basic-config-connect="curl -fsSL https://raw.githubusercontent.com/eoda-dev/posit-infra/main/config/connect/rstudio-connect.gcfg | envsubst"
alias render-config-connect='envsubst < "$CONNECT_CONFIG_TPL"'
alias diff-config-connect='render-config-connect | sudo diff -u --label /etc/rstudio-connect/rstudio-connect.gcfg --label render-config-connect /etc/rstudio-connect/rstudio-connect.gcfg -'

alias enc-value-connect="sudo /opt/rstudio-connect/bin/rscadmin encrypt-config-value"

alias rpm-binary-url="echo https://packagemanager.posit.co/cran/__linux__/$(lsb_release -cs)/latest"

