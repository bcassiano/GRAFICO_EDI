# Project Mapping: [BANCO_DE_DADOS]

## 1. Stack Tecnológica e Infraestrutura
- **Runtime:** Especifique versão exata (ex: Node v20.11.0).
- **Frameworks:** Liste os principais e versões (ex: React 18, NestJS 10).
- **Infraestrutura:** Descreva o ambiente de execução (ex: AWS ECS Fargate, Vercel Edge).
- **Persistência:** Detalhe bancos de dados e camadas de cache.

## 2. Arquitetura e Fluxos de Dados
- **Domínios:** Liste as entidades core do sistema.
- **Integrações:** Liste APIs de terceiros e protocolos (REST, gRPC, Webhooks).
- **Auth:** Descreva o método de segurança (ex: OAuth2, JWT com RSA256).

## 3. Regras de Negócio e SLAs
- **Constraints:** Defina limites de tempo e recursos (ex: timeouts de 30s).
- **Compliance:** Liste normas obrigatórias (ex: ISO 27001, LGPD).
- **Performance:** Defina métricas de sucesso (ex: P95 < 150ms).

## 4. Dívida Técnica e Vulnerabilidades
- **Gargalos:** Onde o sistema falha sob carga.
- **Obsoleto:** Bibliotecas ou padrões que precisam de substituição.
- **Riscos:** Dependências críticas ou pontos únicos de falha.

## 5. Histórico de Decisões (ADR)
- **Decisões Críticas:** Explique o "porquê" de escolhas controversas para evitar que o agente sugira caminhos já descartados.