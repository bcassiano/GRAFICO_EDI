# Integração GRAFICO_EDI: Documentação do Sistema

## 1. Visão Geral do Sistema (Executive Summary)

O **GRAFICO_EDI** é um sistema de *middleware* desenvolvido para automatizar, monitorar e resolver problemas na integração de pedidos de venda capturados de redes de varejo (fornecedores de EDI como a Neogrid) e inseridos no ERP SAP Business One. 

O sistema resolve falhas recorrentes de conectividade, divergências de cadastro (ex: CNPJs de filiais não cadastradas), problemas de códigos de barras não reconhecidos e desatualização de catálogos. Ele inclui um robusto painel de análise e diagnóstico, além de um agente inteligente (IA) capaz de curar e processar erros com base em um contexto histórico.

### Principais Atores:
*   **Neogrid (e similares):** Fonte dos pedidos de venda (EDI) no formato JSON.
*   **Worker Local (`log_worker_server_current.py`):** Motor de processamento em Python que busca relatórios de erros, reprocessa pedidos e enriquece os logs.
*   **SAP Business One (Database):** Destino final dos pedidos, acessado primariamente via banco de dados (SQL Server) para consultas de validação e Service Layer / scripts `.js` para inserção.

---

## 2. Arquitetura Técnica e Componentes

A solução é arquitetada em múltiplas camadas que operam de forma assíncrona.

### 2.1. Camada de Integração (Worker Python)
**Arquivo Principal:** `log_worker_server_current.py`
*   **Função:** Baixa relatórios de erro de um servidor remoto via SSH/SFTP, processa os logs identificados como falhos, tenta recuperar detalhes dos pedidos e, em casos de falha por falta de mapeamento ou instabilidade, tenta a re-injeção controlada.
*   **IA e Cura Automática:** Utiliza prompts de sistema (`ai_system_prompt.txt`) e histórico operacional (`ai_daily_context.json`) para que o agente (integrado ao worker) consiga diagnosticar erros de CNPJ/ITENS de forma autônoma.

### 2.2. Camada de Regras de Negócio e SAP (SQL / JS)
*   **Stored Procedure (`SBO_SP_TransactionNotification.sql`):** Bloqueia inserções de pedidos duplicados (chave composta: `CardCode` + Itens + Total + Janela de 3 dias).
*   **Módulo Node.js (`CotacaoService.js` / similares):** Realiza o push dos JSONs parseados via Service Layer.

### 2.3. Camada de Diagnóstico e Relatórios (Análise e Frontend)
*   **Motor Analítico Python (`analyze_logs.py` / `analyze_custom_period.py`):** Agregam arquivos de log diários (formato `.log`), processam as strings JSON, contam sucessos e erros únicos (excluindo os já corrigidos), e exportam relatórios CSV.
*   **Frontend (Alpine.js + Tailwind):** `relatorio_analise_moderno.html`
    *   Um dashboard rico e responsivo que consome dados do `analyze_custom_period.py`.
    *   Filtros reativos, indicadores de KPIs, exibição hierárquica por "Rede -> Cliente -> Pedidos".

### 2.4. Inteligência, Controle de Configuração e Mapeamento Externo
*   **`cnpj_root_map.json`:** Arquivo crítico de mapeamento manual. Associa os 8 dígitos iniciais do CNPJ (CNPJ Raiz) a um `CardCode` do SAP e seu respectivo `GroupName` (Ex: TENDA, CARREFOUR SP). Permite que filiais não diretamente cadastradas caiam na conta matriz ou regional correspondente, sem necessidade de regerar o código do Worker.
*   **`ai_daily_context.json`:** Mantém o controle dinâmico da operação ativa: indica as redes disponíveis e as instruções correntes de agrupamento.

---

## 3. Fluxo de Dados (Data Flow)

O percurso de um pedido até se tornar um dado estruturado no relatório analítico segue este fluxo:

1.  **Recepção (EDI -> Worker Remoto):** Pedidos chegam no servidor e tentam ser postados na API do SAP MIddleware via JS.
2.  **Geração do Log Local/Remoto:** Falhas (ex: `"Item/CNPJ Nao Encontrado"`) e sucessos disparam logs no arquivo diário `YYYY-MM-DD.log`.
3.  **Monitoramento e Cura (Log Worker em Python):**
    *   Lê o `.log` e isola os erros.
    *   **Sanitização Numérica:** O CNPJ é limpo (remove `/`, `.`, `-`).
    *   **Lookup Direto (SAP):** Procura correspondência perfeita de CNPJ.
    *   **Fallback Root (JSON):** Se falhar, usa os 8 dígitos iniciais contra o `cnpj_root_map.json`.
4.  **Agregação (`analyze_custom_period.py`):**
    *   Faz o parse das linhas de erro e sucesso no período solicitado.
    *   Gera estatísticas consolidadas `group_stats`.
    *   Aplica **Estorno Lógico**: Se um pedido apresentou erro às `10:00` mas teve um log de sucesso às `10:05`, o erro original é abatido dos relatórios KPIs (contagem de "recuperados").
5.  **Apresentação:**
    *   Uma cópia do relatório modificado é persistida no `relatorio_analise_moderno.html` atualizando a variável JS `rawGroupData` estaticamente (injeção).
    *   O usuário abre e consulta no browser local.

---

## 4. Configuração de Ambiente e Dependências

### 4.1. Ambientes Suportados
*   **Execução Principal:** Windows (Local).
*   **Origem dos Logs:** Servidor remoto Linux via protocolo SSH.

### 4.2. Dependências
Para a correta execução dos scripts:
*   **Python 3.10+**: Packages necessários (`paramiko`, `firebase-admin` se em nuvem).
*   **PowerShell 5.1+**: Necessário para execução dos wrappers de query (ex: `ExecQuery.ps1`).
*   **SQL Server**: Acesso de leitura ao banco `RUSTON_PRODUCAO` via credenciais autorizadas.

### 4.3. Estrutura de Diretórios Crítica

```
c:\PERSONAL\BANCO_DE_DADOS\
 ┣ LOGS_EDI\                   # Diretório de cache de logs .log
 ┣ cnpj_root_map.json          # Mapeamento estático raiz -> SAP
 ┣ log_worker_server_current.py# Script principal do worker
 ┣ analyze_custom_period.py    # Motor gerador de relatórios
 ┣ relatorio_analise_moderno.html # Relatório Frontend (Alpine.js)
 ┗ ai_system_prompt.txt        # Prompt carregado ao instanciar Agente AI
```

---

## 5. Instruções de Operação e Uso Diário

### 5.1 Adicionando Novas Redes ou Filiais
Para evitar modificar o Worker, se o envio de uma nova rede (ex: MUFFATO) apresentar problemas com CNPJ não cadastrado:
1. Abra `cnpj_root_map.json`.
2. Adicione os 8 primeiros dígitos do CNPJ da rede apontando para o CardCode principal no SAP.
   ```json
   "76189569": {
       "CardCode": "C001234",
       "CardName": "SUPERMERCADOS MUFATTO",
       "GroupName": "MUFATTO"
   }
   ```
3. O Worker e o Gerador de Relatórios usarão a nova regra instantaneamente no próximo ciclo.

### 5.2 Gerando Atualização de Relatório
Se desejar gerar a fotografia exata do dia para exibição local no painel:
1. Abra o Terminal do VSCode ou PowerShell na pasta raiz.
2. Execute o comando passando `DD-MM-YYYY` (Início e Fim):
   ```bash
   python analyze_custom_period.py 05-03-2026 06-03-2026
   ```
3. Abra o arquivo `relatorio_analise_moderno.html` no Browser.

### 5.3 Execução Contínua do Worker
O worker fica responsável pela resolução e download automático.
```bash
python log_worker_server_current.py
```

---

## 6. Governança e Boas Práticas (Manutenção)

1. **Economia Documental:** Evite duplicar lógicas entre scripts. A lógica que mapeia redes SAP (Root Map) centraliza-se exclusivamente no `cnpj_root_map.json`.
2. **Consultas a Banco de Dados:** Exija e reforce as conexões SQL baseadas nos IPs de produção estabelecidos na governança, sem credenciais inline espalhadas por novos códigos.
3. **Padrão de Logs:** Todo novo fluxo deve prever falhas no parsing de JSON via Neogrid e injetá-las de forma higienizada para o `SPS_LOG_EDI`.
