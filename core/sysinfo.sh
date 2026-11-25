#!/bin/sh
# sysinfo.sh - hardware and system overview for Ubuntu/Linux
# Usage: ./sysinfo.sh          (most info works without root)
#        sudo ./sysinfo.sh     (adds board, RAM modules and disk health)
set -u

have() { command -v "$1" >/dev/null 2>&1; }
section() { printf '\n== %s ==\n' "$1"; }
IS_ROOT=0
[ "$(id -u)" -eq 0 ] && IS_ROOT=1

section "System"
if [ -r /etc/os-release ]; then
  # shellcheck disable=SC1091
  . /etc/os-release
  echo "OS:        ${PRETTY_NAME:-unknown}"
fi
echo "Kernel:    $(uname -r)"
echo "Hostname:  $(hostname)"
echo "Uptime:    $(uptime -p 2>/dev/null || uptime)"
echo "Load avg:  $(cut -d' ' -f1-3 /proc/loadavg)"
if have systemd-detect-virt; then
  echo "Virtual:   $(systemd-detect-virt 2>/dev/null || true)"
fi
if [ "$IS_ROOT" -eq 1 ] && have dmidecode; then
  echo "Board:     $(dmidecode -s baseboard-manufacturer 2>/dev/null) $(dmidecode -s baseboard-product-name 2>/dev/null)"
  echo "System:    $(dmidecode -s system-manufacturer 2>/dev/null) $(dmidecode -s system-product-name 2>/dev/null)"
fi

# List installed versions under /opt, mark the one /usr/local/bin points to
# Usage: opt_versions LABEL DIR BIN (BIN relative to the version dir)
opt_versions() {
  default="$(readlink -f "/usr/local/bin/$(basename "$3")" 2>/dev/null || true)"
  found=""
  for d in "$2"/[0-9]*; do
    [ -x "$d/$3" ] || continue
    v="$(basename "$d")"
    [ -n "$default" ] && [ "$(readlink -f "$d/$3")" = "$default" ] && v="$v (default)"
    found="${found:+$found, }$v"
  done
  printf '%-10s %s\n' "$1:" "${found:-none}"
}

section "R / Python / Quarto (/opt)"
opt_versions "R" /opt/R bin/R
opt_versions "Python" /opt/python bin/python3
opt_versions "Quarto" /opt/quarto bin/quarto

section "CPU"
if have lscpu; then
  lscpu | grep -E '^(Model name|Architecture|CPU\(s\)|Thread\(s\) per core|Core\(s\) per socket|Socket\(s\)|CPU max MHz):'
else
  grep -m1 'model name' /proc/cpuinfo
  echo "CPU(s): $(grep -c '^processor' /proc/cpuinfo)"
fi

section "Memory"
free -h
if [ "$IS_ROOT" -eq 1 ] && have dmidecode; then
  echo
  echo "Modules:"
  dmidecode -t memory 2>/dev/null \
    | grep -E '^\s+(Size|Type|Speed|Locator):' | grep -v 'No Module' \
    | paste -sd' ' | sed 's/  */ /g; s/ Size:/\nSize:/g' | sed 1d
fi

section "Disks"
lsblk -e7 -o NAME,SIZE,TYPE,FSTYPE,MOUNTPOINT,MODEL 2>/dev/null || lsblk

section "Filesystems (usage)"
df -hT -x tmpfs -x devtmpfs -x squashfs -x overlay -x efivarfs 2>/dev/null

section "Inode usage"
df -i -x tmpfs -x devtmpfs -x squashfs -x overlay -x efivarfs 2>/dev/null

if have lvs && [ "$IS_ROOT" -eq 1 ]; then
  section "LVM"
  lvs 2>/dev/null
fi

if [ -r /proc/mdstat ] && grep -q '^md' /proc/mdstat; then
  section "Software RAID"
  cat /proc/mdstat
fi

if [ "$IS_ROOT" -eq 1 ] && have smartctl; then
  section "Disk health (SMART)"
  for dev in $(lsblk -dno NAME,TYPE | awk '$2=="disk"{print $1}'); do
    printf '/dev/%s: ' "$dev"
    smartctl -H "/dev/$dev" 2>/dev/null | grep -iE 'overall-health|SMART Health Status' || echo "n/a"
  done
fi

section "GPU"
if have lspci; then
  lspci | grep -iE 'vga|3d controller|display controller' || echo "No GPU found via lspci"
else
  echo "lspci not found (sudo apt install pciutils)"
fi
if have nvidia-smi; then
  echo
  nvidia-smi --query-gpu=index,name,driver_version,memory.total,memory.used,utilization.gpu,temperature.gpu \
    --format=csv 2>/dev/null || echo "nvidia-smi failed (driver not loaded?)"
fi

section "Network"
if have ip; then
  ip -br addr
else
  hostname -I
fi

if have sensors; then
  section "Temperatures"
  sensors 2>/dev/null | grep -E '^(Package id|Core [0-9]+|Tctl|temp[0-9]+|Composite)' | head -n 10
fi

section "Top 5 processes by memory"
ps -eo pid,user,%mem,%cpu,comm --sort=-%mem | head -n 6

echo

