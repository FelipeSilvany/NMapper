#!/bin/bash

verde="\033[1;32m"
amarelo="\033[1;33m"
vermelho="\033[1;31m"
reset="\033[0m"

echo -e "${amarelo}[*] Gerando relatório HTML...${reset}"

# Pegar diretamente do portscan.txt
OPEN_PORTS=$(cat relatorio_html/portscan.txt)

NUM_IPS=$(echo "$OPEN_PORTS" | cut -d: -f1 | sort | uniq | wc -l)
NUM_PORTAS=$(echo "$OPEN_PORTS" | wc -l)
NUM_VULNS=$(grep -Ev "^\+|^-|^$" relatorio_html/nuclei_results.txt | wc -l)

DATA_ATUAL=$(LC_TIME=pt_BR.UTF-8 date +"%a %d %b %Y %T")

cat > relatorio_html/relatorio_final.html <<EOF
<!DOCTYPE html>
<html lang="pt-BR">
<head>
<meta charset="UTF-8">
<title>Relatório de Assessment de Rede - NMapper</title>
<style>
body { font-family: Arial, sans-serif; margin: 20px; background: #f4f4f4; }
h1 { color: #333; display: flex; align-items: center; }
h1 img { height: 112px; margin-right: 20px; }
table { width: 100%; border-collapse: collapse; margin-bottom: 30px; background: white; }
th, td { border: 1px solid #999; padding: 8px; text-align: left; }
th { background: #555; color: white; }
section { margin-bottom: 40px; }
.summary { background: white; padding: 15px; margin-bottom: 30px; border: 1px solid #ccc; }
.network-section, .http-section, .ssh-section, .ftp-section, .rdp-section, .smb-section, .nuclei-section {
 background: #e6f9e6; padding: 10px; border-radius: 5px; margin-bottom: 20px; border: 2px solid #28a745; }
.network-section h2, .http-section h2, .ssh-section h2, .ftp-section h2, .rdp-section h2, .smb-section h2, .nuclei-section h2 {
 display: flex; align-items: center; color: #155724; }
.network-section h2::before, .http-section h2::before, .ssh-section h2::before, .ftp-section h2::before, .rdp-section h2::before, .smb-section h2::before, .nuclei-section h2::before {
 content: '\1F5A7'; margin-right: 10px; font-size: 24px; }
</style>
</head>
<body>

<h1><img src="https://github.com/FelipeSilvany/NMapper/blob/main/logo.png?raw=true" alt="NMapper Logo"> Relatório de Assessment de Rede - $DATA_ATUAL</h1>

<div class="summary">
<b>Resumo:</b><br>
Total de IPs ativos: $NUM_IPS<br>
Total de portas abertas: $NUM_PORTAS<br>
Total de vulnerabilidades encontradas: $NUM_VULNS<br>
</div>

<section class="network-section">
<h2>IPs e Portas Abertas (Status: OPEN)</h2>
<table>
<tr><th>IP:Porta</th></tr>
$(echo "$OPEN_PORTS" | while read linha; do echo "<tr><td>$linha</td></tr>"; done)
</table>
</section>

<section class="http-section">
<h2>Resultados dos Scripts http-*</h2>
<table>
<tr><th>Resultado</th></tr>
$(while read linha; do echo "<tr><td>$linha</td></tr>"; done < relatorio_html/http_scripts.txt)
</table>
</section>

<section class="ssh-section">
<h2>Resultados dos Scripts ssh-*</h2>
<table>
<tr><th>Resultado</th></tr>
$(while read linha; do echo "<tr><td>$linha</td></tr>"; done < relatorio_html/ssh_scripts.txt)
</table>
</section>

<section class="ftp-section">
<h2>Resultados dos Scripts ftp-*</h2>
<table>
<tr><th>Resultado</th></tr>
$(while read linha; do echo "<tr><td>$linha</td></tr>"; done < relatorio_html/ftp_scripts.txt)
</table>
</section>

<section class="rdp-section">
<h2>Resultados dos Scripts rdp-*</h2>
<table>
<tr><th>Resultado</th></tr>
$(while read linha; do echo "<tr><td>$linha</td></tr>"; done < relatorio_html/rdp_scripts.txt)
</table>
</section>

<section class="smb-section">
<h2>Resultados dos Scripts smb-*</h2>
<table>
<tr><th>Resultado</th></tr>
$(while read linha; do echo "<tr><td>$linha</td></tr>"; done < relatorio_html/smb_scripts.txt)
</table>
</section>

<section class="nuclei-section">
<h2>Achados do Nuclei</h2>
<table>
<tr><th>Vulnerabilidade</th></tr>
$(grep -Ev "^\+|^-|^$" relatorio_html/nuclei_results.txt | while read linha; do echo "<tr><td>$linha</td></tr>"; done)
</table>
</section>

</body>
</html>
EOF

echo -e "${verde}[✔] Relatório gerado em relatorio_html/relatorio_final.html${reset}"
