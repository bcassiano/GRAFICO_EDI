# CHANGELOG

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
