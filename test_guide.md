# Guia Passo a Passo de Testes

Este guia explica como utilizar a coleção do Postman criada para validar a correção do problema de integração Neogrid x SAP (Item sem código).

## 1. Pré-requisitos
*   **Postman** instalado ([Download](https://www.postman.com/downloads/)).
*   Arquivo da coleção: `sap_neogrid_tests.postman_collection.json` (gerado anteriormente).

## 2. Importar a Coleção
1.  Abra o Postman.
2.  Clique no botão **"Import"** (canto superior esquerdo).
3.  Arraste o arquivo `sap_neogrid_tests.postman_collection.json` (Versão Atualizada) para a janela ou selecione-o.
4.  A coleção **"Testes Integração Neogrid x SAP"** aparecerá no menu lateral. **(Se já existir, substitua/delete a antiga)**.

## 3. Configurar Variáveis (Credenciais)
Para que os testes funcionem, o Postman precisa saber onde está seu SAP e qual usuário usar.

1.  Clique sobre o nome da coleção **"Testes Integração Neogrid x SAP"** no menu lateral.
2.  Vá até a aba **"Variables"** (no painel principal, ao lado de Authorization/Pre-request Script).
3.  Preencha a coluna **"Current Value"** para as variáveis:
    *   `SAP_SL_HOST`: O endereço IP da Service Layer (ex: `192.168.1.177` ou o correto do seu ambiente).
    *   `CompanyDB`: O nome do banco de dados (ex: `RUST0N_PRODUCAO`).
    *   `UserName`: Um usuário válido do SAP B1 (ex: `manager`).
    *   `Password`: A senha deste usuário.
4.  Clique no ícone de disco **Save** (ou `Ctrl + S`).

## 4. Aplicar a Correção no SAP (Crucial)
Antes de testar, você precisa "ensinar" ao SAP o código do produto que está vindo errado.

1.  No SAP Business One, acesse: **Estoque > Administração de Item > Números de catálogo de parceiros de negócios**.
2.  No campo "Código do PN", selecione o cliente Carrefour (CardCode `C003612` / CNPJ `45.543.915/0222-31`).
3.  Na grade, adicione uma nova linha:
    *   **Cód.Catálogo PN:** `90896187`
    *   **Nº do Item:** Selecione o código interno correto do produto *"ARROZ T1 1KG FANTASTICO PARB INT"*.
4.  Clique em **Atualizar**.

## 5. Executar os Testes

### Teste A: Validar Login
1.  Abra a requisição **"1. SAP Service Layer - Login"**.
2.  Clique em **Send**.
3.  **Resultado Esperado:** Status `200 OK` e um JSON contendo `SessionId`. O Postman agora salvará a sessão automaticamente na variável `B1SESSION`. Se der erro, verifique se usuário e senha estão corretos na aba "Variables".

### Teste B: Validar Injeção na Integração
Este teste simula o envio do pedido problemático novamente para o serviço de integração.

1.  Abra a requisição **"3. Integração Node.js - Reenviar Payload"**.
2.  **Nota sobre URL:** A requisição está configurada para a raiz `/`. Se você receber **404 Not Found**, significa que o serviço espera um caminho específico (ex: `/api/receive`, `/webhook`). Como não temos acesso ao código fonte, verifique os logs do servidor Linux ou tente endpoints comuns se o 404 persistir.
3.  Clique em **Send**.
4.  **Verificação:**
    *   Acesse o banco de dados SQL Server.
    *   Consulte a tabela de log: `SELECT TOP 1 * FROM [dbo].[SPS_LOG_EDI] ORDER BY ID DESC`.
    *   Se a correção do passo 4 funcionou, o novo registro **NÃO** deve ter o erro *"Número de item não informado"*. Pode ter outro erro ou sucesso, mas o erro de item deve desaparecer.
