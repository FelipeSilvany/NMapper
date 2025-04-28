#!/bin/bash

# Banner de abertura
echo -e "\033[1;36m"
echo "====================================="
echo "             NMapper              "
echo "    Powered by Silvanystro - v1.2.7  "
echo "====================================="
echo -e "\033[0m"

# Espaço de 5 linhas
for i in {1..5}; do echo ""; done

# Definição de cores
verde="\033[1;32m"
amarelo="\033[1;33m"
vermelho="\033[1;31m"
reset="\033[0m"

# Verifica se a rede foi passada como argumento
if [ -z "$1" ]; then
  echo -e "${vermelho}[!] Uso: $0 <REDE_CIDR> (ex: $0 192.168.0.0/24)${reset}"
  exit 1
fi

REDE="$1"
PORTSCAN_OUT="portscan.txt"
HTTP_OUT="http_scripts.txt"
SSH_OUT="ssh_scripts.txt"
FTP_OUT="ftp_scripts.txt"
RDP_OUT="rdp_scripts.txt"
SMB_OUT="smb_scripts.txt"
NUCLEI_OUT="nuclei_results.txt"

PORTAS_HTTP="1521 5432 3306 2082 2083 2086 2087 2095 2077 2078 80 443 8000 8080 8081 4463 8091 8443 9000 9001 9002 9003 4443 4433 9090 9443 989 990"
TEMPLATE_PATH="$HOME/nuclei-templates"
PARALLEL=8

# Limpando arquivos antigos
echo -e "${amarelo}[*] Limpando arquivos antigos...${reset}"
> "$PORTSCAN_OUT"
> "$HTTP_OUT"
> "$SSH_OUT"
> "$FTP_OUT"
> "$RDP_OUT"
> "$SMB_OUT"
> "$NUCLEI_OUT"

# Descobrir hosts ativos
echo -e "${amarelo}[*] Descobrindo hosts ativos em $REDE...${reset}"
HOSTS_ATIVOS=$(nmap -n -sn "$REDE" | grep "report for" | awk '{print $5}')

if [ -z "$HOSTS_ATIVOS" ]; then
  echo -e "${vermelho}[!] Nenhum host ativo encontrado.${reset}"
  exit 1
fi

echo -e "${verde}[+] Hosts ativos encontrados:${reset}"
echo "$HOSTS_ATIVOS"

# Função de scan para paralelização
scan_ip() {
  local ip="$1"
  echo -e "${amarelo}[*] Escaneando $ip...${reset}"
  PORTAS_ABERTAS=$(nmap -p- --min-rate=500 -T4 -oG - "$ip" | awk '/Ports:/{split($0,a,"Ports: "); split(a[2],b,","); for(i in b) {split(b[i],c,"/"); print "'$ip':"c[1]}}')

  for linha in $PORTAS_ABERTAS; do
    echo "$linha" | tee -a "$PORTSCAN_OUT"
    IP=$(echo "$linha" | cut -d: -f1)
    PORTA=$(echo "$linha" | cut -d: -f2)

    if echo "$PORTAS_HTTP" | grep -wq "$PORTA"; then
      echo -e "${amarelo}[*] Rodando http-* scripts em $IP:$PORTA${reset}"
      nmap --script "http-*" -p "$PORTA" "$IP" >> "$HTTP_OUT"
      echo "------------------------" >> "$HTTP_OUT"
    fi

    if [ "$PORTA" = "22" ]; then
      echo -e "${amarelo}[*] Rodando ssh-* scripts em $IP:22${reset}"
      nmap --script "ssh-*" -p 22 "$IP" >> "$SSH_OUT"
      echo "------------------------" >> "$SSH_OUT"
    fi

    if [ "$PORTA" = "20" ] || [ "$PORTA" = "21" ]; then
      echo -e "${amarelo}[*] Rodando ftp-* scripts em $IP:$PORTA${reset}"
      nmap --script "ftp-*" -p "$PORTA" "$IP" >> "$FTP_OUT"
      echo "------------------------" >> "$FTP_OUT"
    fi

    if [ "$PORTA" = "3389" ]; then
      echo -e "${amarelo}[*] Rodando rdp-* scripts em $IP:3389${reset}"
      nmap --script "rdp-*" -p 3389 "$IP" >> "$RDP_OUT"
      echo "------------------------" >> "$RDP_OUT"
    fi

    if [ "$PORTA" = "445" ]; then
      echo -e "${amarelo}[*] Rodando smb-* scripts em $IP:445${reset}"
      nmap --script "smb-*" -p 445 "$IP" >> "$SMB_OUT"
      echo "------------------------" >> "$SMB_OUT"
    fi
  done
}

export -f scan_ip
export PORTSCAN_OUT HTTP_OUT SSH_OUT FTP_OUT RDP_OUT SMB_OUT PORTAS_HTTP verde amarelo vermelho reset

# Executar scans em paralelo
echo -e "${amarelo}[*] Iniciando varredura paralela de portas abertas com $PARALLEL threads...${reset}"
echo "$HOSTS_ATIVOS" | xargs -n 1 -P "$PARALLEL" bash -c 'scan_ip "$@"' _

# Executar Nuclei apenas em serviços web
echo -e "${amarelo}[*] Executando Nuclei nos serviços web...${reset}"
for linha in $(cat "$PORTSCAN_OUT"); do
  IP=$(echo "$linha" | cut -d: -f1)
  PORTA=$(echo "$linha" | cut -d: -f2)

  if echo "$PORTAS_HTTP" | grep -wq "$PORTA"; then
    URL="http://$IP:$PORTA"
    echo -e "${amarelo}[*] Rodando Nuclei em $URL${reset}"
    nuclei -u "$URL" -t "$TEMPLATE_PATH" -timeout 10 -rate-limit 100 >> "$NUCLEI_OUT"
    echo "------------------------" >> "$NUCLEI_OUT"
  fi
  done

# Resumo rápido
NUM_HOSTS=$(cat "$PORTSCAN_OUT" | cut -d: -f1 | sort | uniq | wc -l)
NUM_PORTAS=$(cat "$PORTSCAN_OUT" | wc -l)
NUM_VULNS=$(cat "$NUCLEI_OUT" | grep -c "matched at")

echo -e "${verde}"
echo "========= RESUMO ========="
echo "Hosts ativos encontrados         : $NUM_HOSTS"
echo "Total de portas abertas mapeadas : $NUM_PORTAS"
echo "Vulnerabilidades encontradas     : $NUM_VULNS"
echo -e "${reset}"

# Preparar relatório
mkdir -p relatorio_html
cp "$PORTSCAN_OUT" relatorio_html/
cp "$HTTP_OUT" relatorio_html/
cp "$SSH_OUT" relatorio_html/
cp "$FTP_OUT" relatorio_html/
cp "$RDP_OUT" relatorio_html/
cp "$SMB_OUT" relatorio_html/
cp "$NUCLEI_OUT" relatorio_html/

# Chamar script de geração de HTML
echo -e "${amarelo}[*] Gerando relatório HTML...${reset}"
bash gerar_html.sh

