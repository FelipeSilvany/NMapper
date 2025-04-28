![image](https://github.com/user-attachments/assets/57e6e4f2-0865-4cb0-a4ec-86e9cb9ad152)




Ajude a manter nosso projeto ativo. Faça aqui sua doação:

![image](https://github.com/user-attachments/assets/2c37ec35-37e3-40c4-82a2-da7a3ae97a97)


# NMapper v1.2.7

![Banner](https://img.shields.io/badge/NMapper-v1.2.7-blue)

Automatize o mapeamento da sua rede e descubra vulnerabilidades rapidamente! Desenvolvido para facilitar a detecção de hosts, portas abertas, serviços expostos e vulnerabilidades com alta performance.

## 👩‍💻 Sobre o NMapper

O **NMapper** é um script Bash poderoso que realiza:

- Descoberta de hosts ativos
- Varredura completa de portas abertas
- Enumeração de serviços via Nmap NSE scripts
- Detecção de vulnerabilidades em serviços Web via Nuclei
- Geração de relatórios automáticos em HTML
- Execução paralela para alta performance

---

## ✨ Funcionalidades

- Varredura rápida de IPs ativos com `nmap -sn`
- Detecção de todas as portas abertas (`nmap -p-`)
- Execução paralela com `xargs` para acelerar o processo
- Scripts automáticos para protocolos:
  - HTTP (http-*)
  - SSH (ssh-*)
  - FTP (ftp-*)
  - SMB (smb-*)
  - RDP (rdp-*)
- Varredura de vulnerabilidades web com **Nuclei**
- Saída em arquivos `.txt` + Relatório visual em HTML

---

## 📁 Instalação

### 1. Clone o repositório

```bash
git clone https://github.com/FelipeSilvany/NMapper.git
```

### 2. Acesse o diretório do projeto

```bash
cd NMapper
```

### 3. Dê permissão de execução

```bash
chmod +x nmapper.sh gerar_html.sh
```

---

## 🚀 Como usar

Execute o script informando a rede em formato CIDR:

```bash
./nmapper.sh <REDE_CIDR>
```

**Exemplo:**

```bash
./nmapper.sh 192.168.1.0/24
```

O script automaticamente:
- Mapeia hosts ativos
- Escaneia portas abertas
- Executa scripts NSE
- Varre serviços web com Nuclei
- Gera um diretório `relatorio_html/` com os resultados

---

## 📚 Dependências obrigatórias

- `nmap`
- `nuclei`
- `bash`
- `awk`, `grep`, `cut`, `tee`, `sort`, `uniq`, `wc`
- `xargs`

Instale com:

```bash
sudo apt install nmap nuclei git -y
```

Nuclei templates:

```bash
nuclei -update-templates
```

---

## 👥 Integrações

| Ferramenta | Função |
|:-----------|:-------|
| **nmap**   | Descoberta de hosts, escaneamento de portas e execução de scripts NSE |
| **nuclei** | Detecção de vulnerabilidades web em serviços HTTP |
| **xargs**  | Paraleliza o escaneamento para maior velocidade |
| **bash utilities** | Processamento de resultados e geração de relatórios |

---

## 📈 Resultados gerados

- `portscan.txt` - Hosts e portas abertas detectadas
- `http_scripts.txt` - Resultado dos scripts HTTP
- `ssh_scripts.txt` - Resultado dos scripts SSH
- `ftp_scripts.txt` - Resultado dos scripts FTP
- `rdp_scripts.txt` - Resultado dos scripts RDP
- `smb_scripts.txt` - Resultado dos scripts SMB
- `nuclei_results.txt` - Vulnerabilidades detectadas
- Diretório `relatorio_html/` contendo o relatório final

---

## 📅 Roadmap futuro

- Integração com ferramentas de bruteforce
- Geração automática de PDF do relatório
- Detecção de vulnerabilidades em SMB/FTP
- Opções de customização de escaneamento

---

## 💚 Licença

Este projeto é de uso livre para fins educativos e é distribuído sem garantias.

---

Feito com ❤️ por **Felipe Silvany** | [https://github.com/FelipeSilvany](https://github.com/FelipeSilvany)

Ajude a manter este projeto ativo, doando qualquer valor:

https://www.paypal.com/donate/?hosted_button_id=A6LPT7ERM8AQS

---

> **Aviso:** Utilize este script de maneira ética e somente em redes autorizadas.
