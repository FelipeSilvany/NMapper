#!/bin/bash

verde="\033[1;32m"
amarelo="\033[1;33m"
vermelho="\033[1;31m"
reset="\033[0m"

echo -e "${amarelo}[*] Gerando relatório HTML...${reset}"

cat > relatorio_html/relatorio_final.html <<EOF
<!DOCTYPE html>
<html lang="pt-BR">
<head>
<meta charset="UTF-8">
<title>Relatório de Varredura</title>
<style>
body { font-family: Arial, sans-serif; margin: 20px; background: #f4f4f4; }
h1 { color: #333; }
table { width: 100%; border-collapse: collapse; margin-bottom: 30px; background: white; }
th, td { border: 1px solid #999; padding: 8px; text-align: left; }
th { background: #555; color: white; }
section { margin-bottom: 40px; }
</style>
</head>
<body>

<h1>Relatório de Varredura - $(date)</h1>

<section>
<h2>IPs e Portas Abertas</h2>
<table>
<tr><th>IP:Porta</th></tr>
$(while read linha; do echo "<tr><td>$linha</td></tr>"; done < relatorio_html/portscan.txt)
</table>
</section>

<section>
<h2>Resultados dos Scripts http-*</h2>
<table>
<tr><th>Resultado</th></tr>
$(while read linha; do echo "<tr><td>$linha</td></tr>"; done < relatorio_html/http_scripts.txt)
</table>
</section>

<section>
<h2>Resultados dos Scripts ssh-*, ssh2-*</h2>
<table>
<tr><th>Resultado</th></tr>
$(while read linha; do echo "<tr><td>$linha</td></tr>"; done < relatorio_html/ssh_scripts.txt)
</table>
</section>

<section>
<h2>Resultados dos Scripts ftp-*</h2>
<table>
<tr><th>Resultado</th></tr>
$(while read linha; do echo "<tr><td>$linha</td></tr>"; done < relatorio_html/ftp_scripts.txt)
</table>
</section>

<section>
<h2>Resultados dos Scripts rdp-*</h2>
<table>
<tr><th>Resultado</th></tr>
$(while read linha; do echo "<tr><td>$linha</td></tr>"; done < relatorio_html/rdp_scripts.txt)
</table>
</section>

<section>
<h2>Resultados dos Scripts smb-*</h2>
<table>
<tr><th>Resultado</th></tr>
$(while read linha; do echo "<tr><td>$linha</td></tr>"; done < relatorio_html/smb_scripts.txt)
</table>
</section>

<section>
<h2>Achados do Nuclei</h2>
<table>
<tr><th>Vulnerabilidade</th></tr>
$(while read linha; do echo "<tr><td>$linha</td></tr>"; done < relatorio_html/nuclei_results.txt)
</table>
</section>

</body>
</html>
EOF

echo -e "${verde}[✔] Relatório gerado em relatorio_html/relatorio_final.html${reset}"

