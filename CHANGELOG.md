# CHANGELOG
 
## [1.4.2] - 2026-03-10
### Corrigido
- Ajuste na `Content Security Policy` (CSP) para permitir o carregamento de scripts, fontes e conectividade com CDNs externos (`jsdelivr`, `gstatic`, `perplexity`).
- Resolução do erro `exports is not defined` através da alteração do bundle do `jwt-decode` para uma versão UMD compatível com navegadores.
- Adição da dependência do `Chart.js` no `index.html`, corrigindo falhas na renderização de indicadores.
- Inicialização do estado `toast` no Alpine.js, eliminando erros de referência (`toast is not defined`).


## [1.4.1] - 2026-03-10
### Corrigido
- Removidas datas preenchidas (hardcoded) na carga inicial do dashboard para garantir que o usuário selecione explicitamente o período.

## [1.4.0] - 2026-03-10
### Adicionado
- Implementação de **Single Sign-On (SSO)** via JWT para proteção do dashboard.
- Mecanismo de captura de token via URL e persistência com fallback em `localStorage`.
- Validação de claims de segurança (`iss`, `aud`, `exp`) no frontend.
- Script utilitário `public/generate_test_token.py` para testes de integração local.
### Segurança
- Configuração de headers restritivos (`CSP`, `HSTS`, `X-Frame-Options`) no `firebase.json`.
- Proteção contra renderização de dados sensíveis sem autorização explícita (X-Cloak + IsAuthorized).

## [1.3.2] - 2026-03-06
### Corrigido
- Restabelecimento do layout premium **Glassmorphism** (Dashboard Moderno) via rollback para a tag estável `v3.0.1`.
- Sincronização automática do `public/index.html` com a versão moderna injetada por dados dinâmicos, garantindo que o Firebase Host sirva o visual correto.

## [1.3.1] - 2026-03-06
### Corrigido
- Fix no carregamento do `cnpj_root_map.json` para usar caminho absoluto, garantindo funcionamento em deploy/automação.
- Unificação da rede **Comercial Zaragoza / Spani Atacadista** via fallback de raiz de CNPJ (`05868574`), removendo-os da categoria "Não Identificado".

## [1.3.0] - 2026-03-06
### Segurança
- Criado `.gitignore` na raiz do projeto para proteger `remote_env.txt`, `firebase-service-account.json`, arquivos `.env` e logs de serem comitados inadvertidamente.
- Migradas credenciais hardcoded (`P0w3rB1@25`, `Fant0n@123!`) de `_test_dump_sql.py` e `server-agent/log_worker.py` para `os.environ.get()` com fallbacks seguros de IP e database (sem senha padrão).
- Adicionada documentação completa do sistema em `GRAFICO_EDI_DOCS.md`.

## [1.2.1] - 2026-03-06
### Adicionado
- Integração do `relatorio_analise_moderno.html` com o novo sistema de mapeamento.
- Implementação de injeção automática de dados estáticos no dashboard Alpine.js via `analyze_custom_period.py`.
- Suporte a fallback de CNPJ Raiz também no gerador de relatórios local.

## [1.2.0] - 2026-03-06
- **Agente/Prompt**: Reescrito `ai_system_prompt.txt` com 10 regras completas cobrindo: sanitização de CNPJ (3 variantes), lógica de filiais por CNPJ raiz, separação por `GroupName`, chave composta de pedido e storno de erro por sucesso.
- **Log Worker**: Externalizado `CNPJ_ROOT_MAP` do código Python para `cnpj_root_map.json` — permite adicionar novas redes/filiais sem deploy. Mapa ampliado de 2 para 5 entradas (Tenda, Atacadão SP, Carrefour, Zaragoza, Atacadão S.A.).
- **Contexto Diário**: Enriquecido `ai_daily_context.json` com `redes_ativas_edi`, `cnpj_root_map_ativo` e `instrucao_separacao` para persistência de contexto operacional entre sessões do agente.

## [1.1.0] - 2026-03-05
- **Log Worker**: Implementada lógica de "Sucesso Absoluto" para filtragem de erros históricos em memória, garantindo que sucessos anulem falhas no mesmo dia.
- **Log Worker**: Adicionado sistema de fallback para resolução de CNPJs via raiz (8 dígitos) para suporte a grandes redes (Atacadão, Tenda) que compartilham pedidos entre filiais.
- **Cache**: Unificadas as coleções de cache no Firestore para `search_cache`, corrigindo a divergência entre processamento manual e automático.
