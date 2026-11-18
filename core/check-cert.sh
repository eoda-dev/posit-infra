#!/bin/sh
# check-cert.sh - check a server's TLS setup via its DNS name and,
# optionally, compare it with the certificate files on the server.
#
# Usage: check-cert.sh [options] <hostname>
#   -p PORT     TLS port (default 443)
#   -c FILE     certificate file on the server (PEM, leaf first)
#   -k FILE     private key file on the server (only compared, never printed)
#   -a FILE     CA file to trust (e.g. your self-signed cert); replaces the
#               system trust store for the curl and chain checks
#   -d DAYS     warn if the certificate expires within DAYS (default 30)
#   -s USER@HOST  read -c/-k files over SSH instead of locally
#
# Examples:
#   ./check-cert.sh example.com
#   ./check-cert.sh -c /etc/rstudio/server-cert.pem -k /etc/rstudio/server-key.pem myhost.example.com
#   ./check-cert.sh -a server-cert.pem -c /etc/rstudio/server-cert.pem -s root@myhost myhost.example.com
#
# Exit code: 0 = all good, 1 = at least one FAIL, 2 = usage error.
set -u

PORT=443
WARN_DAYS=30
CERT=""
KEY=""
CA=""
SSH=""

usage() { sed -n '2,20p' "$0" | sed 's/^# \{0,1\}//'; exit 2; }

while getopts "p:c:k:a:d:s:h" opt; do
  case "$opt" in
    p) PORT="$OPTARG" ;;
    c) CERT="$OPTARG" ;;
    k) KEY="$OPTARG" ;;
    a) CA="$OPTARG" ;;
    d) WARN_DAYS="$OPTARG" ;;
    s) SSH="$OPTARG" ;;
    *) usage ;;
  esac
done
shift $((OPTIND - 1))
[ $# -eq 1 ] || usage
HOST="$1"

for tool in openssl curl; do
  command -v "$tool" >/dev/null 2>&1 || { echo "Missing tool: $tool" >&2; exit 2; }
done

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

FAILS=0
WARNS=0
section() { printf '\n== %s ==\n' "$1"; }
ok()      { printf '  [ OK ] %s\n' "$1"; }
warn()    { printf '  [WARN] %s\n' "$1"; WARNS=$((WARNS + 1)); }
fail()    { printf '  [FAIL] %s\n' "$1"; FAILS=$((FAILS + 1)); }
info()    { printf '         %s\n' "$1"; }

# Host is an IP address? (IPv4 or anything containing a colon)
case "$HOST" in
  *:*) IS_IP=1 ;;
  *[!0-9.]*) IS_IP=0 ;;
  *) IS_IP=1 ;;
esac

readfile() {
  if [ -n "$SSH" ]; then ssh -o BatchMode=yes "$SSH" "cat '$1'"; else cat "$1"; fi
}

days_left() {  # $1 = PEM file
  end_str="$(openssl x509 -in "$1" -noout -enddate | cut -d= -f2)"
  end_ts="$(date -d "$end_str" +%s 2>/dev/null)" || return 1
  echo $(( (end_ts - $(date +%s)) / 86400 ))
}

pubkey_hash() {  # reads a cert (x509) or key (pkey) from a file
  if [ "$2" = "cert" ]; then
    openssl x509 -in "$1" -noout -pubkey 2>/dev/null | openssl sha256 2>/dev/null
  else
    openssl pkey -in "$1" -pubout 2>/dev/null | openssl sha256 2>/dev/null
  fi
}

check_expiry() {  # $1 = PEM file, $2 = label
  d="$(days_left "$1")" || { warn "$2: could not compute expiry"; return; }
  if openssl x509 -in "$1" -noout -checkend 0 >/dev/null 2>&1; then
    if [ "$d" -lt "$WARN_DAYS" ]; then
      warn "$2 expires in $d days"
    else
      ok "$2 valid for another $d days"
    fi
  else
    fail "$2 has EXPIRED ($(openssl x509 -in "$1" -noout -enddate | cut -d= -f2))"
  fi
}

# --- 1. DNS ---------------------------------------------------------------
section "DNS"
if [ "$IS_IP" -eq 1 ]; then
  info "IP address given, skipping DNS lookup (certificate needs an IP SAN)"
else
  IPS="$(getent ahosts "$HOST" 2>/dev/null | awk '{print $1}' | sort -u | paste -sd' ' -)"
  if [ -n "$IPS" ]; then ok "$HOST resolves to: $IPS"; else fail "$HOST does not resolve"; fi
fi

# --- 2. curl --------------------------------------------------------------
section "curl https://$HOST:$PORT/"
RESULT="$(curl -sS -o /dev/null --max-time 10 \
  -w '%{http_code} %{ssl_verify_result}' \
  ${CA:+--cacert "$CA"} "https://$HOST:$PORT/" 2>"$TMP/curl.err")"
RC=$?
if [ "$RC" -eq 0 ]; then
  ok "TLS handshake and verification succeeded (HTTP ${RESULT%% *})"
else
  fail "curl exit code $RC: $(tr '\n' ' ' < "$TMP/curl.err")"
  if grep -qiE "self-signed|local issuer|unknown ca" "$TMP/curl.err"; then
    info "Certificate not trusted: unknown issuer or self-signed. Use -a <cert> to trust it."
  elif grep -qi "subject name" "$TMP/curl.err"; then
    info "Name mismatch: the hostname is not in the certificate's SAN list"
  fi
fi
[ -n "$CA" ] && info "Trust store replaced by: $CA"

# --- 3. Certificate served by the server ----------------------------------
section "Certificate served on $HOST:$PORT"
SNI=""
[ "$IS_IP" -eq 0 ] && SNI="-servername $HOST"
# shellcheck disable=SC2086
openssl s_client -connect "$HOST:$PORT" $SNI -showcerts </dev/null >"$TMP/s_client.txt" 2>/dev/null
if openssl x509 -in "$TMP/s_client.txt" -out "$TMP/served.pem" 2>/dev/null; then
  info "Subject: $(openssl x509 -in "$TMP/served.pem" -noout -subject | sed 's/^subject= *//')"
  info "Issuer:  $(openssl x509 -in "$TMP/served.pem" -noout -issuer | sed 's/^issuer= *//')"
  info "Expires: $(openssl x509 -in "$TMP/served.pem" -noout -enddate | cut -d= -f2)"
  SAN="$(openssl x509 -in "$TMP/served.pem" -noout -ext subjectAltName 2>/dev/null | sed 1d | sed 's/^ *//')"
  info "SAN:     ${SAN:-none}"
  SERVED_FP="$(openssl x509 -in "$TMP/served.pem" -noout -fingerprint -sha256 | cut -d= -f2)"
  info "SHA-256: $SERVED_FP"

  check_expiry "$TMP/served.pem" "Served certificate"

  if [ "$IS_IP" -eq 1 ]; then
    MATCH="$(openssl x509 -in "$TMP/served.pem" -noout -checkip "$HOST" 2>&1)"
  else
    MATCH="$(openssl x509 -in "$TMP/served.pem" -noout -checkhost "$HOST" 2>&1)"
  fi
  if echo "$MATCH" | grep -q "does match"; then
    ok "Certificate matches $HOST"
  else
    fail "Certificate does NOT match $HOST (check the SAN entries above)"
  fi

  if openssl x509 -in "$TMP/served.pem" -noout -subject -issuer | awk -F'= *' 'NR==1{s=$2} NR==2{i=$2} END{exit !(s==i)}'; then
    info "Self-signed (subject equals issuer)"
  fi
else
  fail "Could not read a certificate from $HOST:$PORT (port closed or no TLS?)"
  SERVED_FP=""
fi

# --- 4. Certificate files on the server -----------------------------------
if [ -n "$CERT" ]; then
  section "Certificate file ${SSH:+$SSH:}$CERT"
  if readfile "$CERT" >"$TMP/local-chain.pem" 2>"$TMP/read.err" \
     && openssl x509 -in "$TMP/local-chain.pem" -out "$TMP/local.pem" 2>/dev/null; then
    info "Subject: $(openssl x509 -in "$TMP/local.pem" -noout -subject | sed 's/^subject= *//')"
    info "Expires: $(openssl x509 -in "$TMP/local.pem" -noout -enddate | cut -d= -f2)"
    LOCAL_FP="$(openssl x509 -in "$TMP/local.pem" -noout -fingerprint -sha256 | cut -d= -f2)"
    info "SHA-256: $LOCAL_FP"

    check_expiry "$TMP/local.pem" "Certificate file"

    # Is the file the cert that is actually being served?
    if [ -n "${SERVED_FP:-}" ]; then
      if [ "$LOCAL_FP" = "$SERVED_FP" ]; then
        ok "File matches the certificate served on the wire"
      else
        fail "File differs from the served certificate (service not restarted, or another config/proxy serves a different cert)"
      fi
    fi

    # Chain validation (extra certs in the file are used as intermediates)
    if openssl verify ${CA:+-CAfile "$CA"} -untrusted "$TMP/local-chain.pem" "$TMP/local.pem" >"$TMP/verify.out" 2>&1; then
      ok "Chain verifies against ${CA:-the system trust store}"
    else
      fail "Chain does not verify: $(tr '\n' ' ' < "$TMP/verify.out")"
    fi

    # Key matches certificate?
    if [ -n "$KEY" ]; then
      if readfile "$KEY" >"$TMP/local.key" 2>"$TMP/readkey.err"; then
        CH="$(pubkey_hash "$TMP/local.pem" cert)"
        KH="$(pubkey_hash "$TMP/local.key" key)"
        if [ -n "$KH" ] && [ "$CH" = "$KH" ]; then
          ok "Private key matches the certificate"
        elif [ -z "$KH" ]; then
          fail "Could not read the private key (encrypted with a passphrase, or not a PEM key?)"
        else
          fail "Private key does NOT match the certificate"
        fi
      else
        fail "Could not read key $KEY: $(tr '\n' ' ' < "$TMP/readkey.err")"
      fi
    fi
  else
    fail "Could not read or parse $CERT: $(tr '\n' ' ' < "$TMP/read.err")"
  fi
fi

# --- Summary --------------------------------------------------------------
section "Summary"
echo "  $FAILS failure(s), $WARNS warning(s)"
[ "$FAILS" -eq 0 ]

