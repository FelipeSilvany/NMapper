![image](https://github.com/user-attachments/assets/57e6e4f2-0865-4cb0-a4ec-86e9cb9ad152)



Ajude a manter nosso projeto ativo. Faça aqui sua doação: https://www.paypal.com/donate/?hosted_button_id=A6LPT7ERM8AQS


# NMapper v2.1.2

![Banner](https://img.shields.io/badge/NMapper-v2.1.2-blue)

Automatize o mapeamento da sua rede e descubra vulnerabilidades com eficiência profissional! Esta nova versão traz melhorias no paralelismo, novas rotinas de exploração e maior controle de saída.

---

## 👨‍💻 Sobre o NMapper

O **NMapper** é um script Bash completo para mapeamento e auditoria de rede. Com ele você:

- Identifica hosts ativos
- Detecta todas as portas abertas
- Executa scripts NSE para protocolos diversos
- Verifica serviços web com **Nuclei**
- Lança exploits automáticos via **Metasploit**
- Gera relatórios detalhados em HTML

---

## ✨ Novidades na v2.1.2

- Novo exploit automático `ms17_010_psexec` além do EternalBlue
- Geração de arquivos `.rc` com configuração automatizada
- Exportação separada de resultados por tipo de serviço
- Suporte a escaneamento em lista, IP único ou rede completa
- Execução paralela otimizada com controle de threads (`-P`)

---

## 🚀 Como usar

### Opções disponíveis:

```bash
./nmapper.sh [opções]
```

| Parâmetro | Função |
|----------|--------|
| `--help` | Exibir ajuda |
| `-r`     | Escanear uma rede (CIDR) |
| `-i`     | Escanear um IP específico |
| `-l`     | Escanear a partir de uma lista |
| `-h`     | Definir o IP local (LHOST) para exploits |

### Exemplos:

```bash
./nmapper.sh -r 192.168.1.0/24
./nmapper.sh -i 192.168.1.100
./nmapper.sh -l lista.txt -h 192.168.1.50
```

---

## 📂 Resultados gerados

Todos os resultados ficam organizados no diretório `relatorio_html/`:

| Arquivo | Conteúdo |
|--------|----------|
| `portscan.txt` | IPs e portas abertas |
| `http_scripts.txt` | Resultados de scripts `http-*` |
| `ssh_scripts.txt` | Resultados de scripts `ssh-*` |
| `ftp_scripts.txt` | Resultados de scripts `ftp-*` |
| `rdp_scripts.txt` | Resultados de scripts `rdp-*` |
| `smb_scripts.txt` | Resultados de scripts `smb-*` |
| `eternalblue.txt` | Execução do exploit `ms17_010_eternalblue` |
| `smbv1.txt` | Execução do exploit `ms17_010_psexec` |
| `nuclei_results.txt` | Vulnerabilidades detectadas com Nuclei |
| `relatorio_html/index.html` | Relatório visual final |

---

## 📦 Dependências obrigatórias

- `nmap`
- `nuclei`
- `metasploit-framework`
- `bash`, `awk`, `grep`, `cut`, `xargs`, `tee`, `sort`, `uniq`

Instale com:

```bash
sudo apt install nmap nuclei metasploit-framework git -y
```

Atualize os templates do Nuclei com:

```bash
nuclei -update-templates
```

---

## 🔧 Tecnologias utilizadas

| Ferramenta | Uso |
|-----------|-----|
| `nmap` | Portscan e scripts NSE |
| `nuclei` | Vulnerabilidades HTTP |
| `xargs` | Execução paralela |
| `msfconsole` | Execução de exploits via RC scripts |
| `bash` | Automação geral |

---

## 📅 Roadmap futuro

- Integração com bruteforce (Hydra, Medusa)
- PDF automático do relatório final
- Enumeração profunda de SMB/FTP
- Fingerprinting com WhatWeb e Wappalyzer
- Modo silencioso para CI/CD

---

## 🔐 Aviso

Este script é para **uso autorizado e educativo**. Nunca utilize em ambientes sem permissão explícita.

---

Feito com ❤️ por **Felipe Silvany**  
[GitHub: @FelipeSilvany](https://github.com/FelipeSilvany)

Ajude o projeto com uma doação:  
👉 https://www.paypal.com/donate/?hosted_button_id=A6LPT7ERM8AQS


---

> **Aviso:** Utilize este script de maneira ética e somente em redes autorizadas.
