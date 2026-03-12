#!/bin/bash

if [ -z "$1" ]; then
  echo "Uso: $0 dominio.com"
  exit 1
fi

TARGET=$1

echo "[+] Extraindo keyword base..."
KEYWORD=$(echo "$TARGET" | awk -F. '{print $1}')

echo "[+] Buscando certificados no crt.sh..."
curl -s "https://crt.sh/?q=%25$KEYWORD%25&output=json" \
| jq -r '.[].name_value' 2>/dev/null \
| grep -Eo '([a-zA-Z0-9.-]+\.[a-zA-Z]{2,})' \
| sed 's/^\*\.//' \
| sed 's/\.$//' \
| sed 's/^\.//' \
| sort -u > .all_domains_tmp

echo "[+] Extraindo root domains..."

awk -F. '
{
  n = NF
  if (n == 2) {
    print $0
  } 
  else if (n >= 3) {
    if ($(n-1) == "com" || $(n-1) == "net" || $(n-1) == "org") {
      print $(n-2)"."$(n-1)"."$n
    } else {
      print $(n-1)"."$n
    }
  }
}
' .all_domains_tmp | sort -u > root_domains.txt

rm .all_domains_tmp

echo "[+] Root domains encontrados:"
cat root_domains.txt
