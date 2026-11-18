#!/bin/sh
alias config="vi /etc/rstudio-connect/rstudio-connect.gcfg"
alias restart="systemctl restart rstudio-connect && sleep 2 && systemctl --no-pager -l status rstudio-connect"
alias status="systemctl --no-pager -l status rstudio-connect"
alias stop="systemctl stop rstudio-connect"
alias start="systemctl start rstudio-connect && sleep 2 && systemctl --no-pager -l status rstudio-connect"
alias diagnostic="/opt/rstudio-connect/scripts/run-diagnostics.sh ~/"
alias license-status="/opt/rstudio-connect/bin/license-manager status"
alias logs='GREEN="\033[0;32m" && NC="\033[0m" && echo -e ${GREEN}"\n Posit Connect Logs:\n"${NC} && tail -n 15 /var/log/rstudio/rstudio-connect/rstudio-connect.log'

