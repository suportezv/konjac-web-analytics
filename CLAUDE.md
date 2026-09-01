# Konjac Web Analytics (memória persistente da célula)

Este repositório é a **célula de análise de web e mídia da Konjac Massa MF** dentro
da agência. Ele é a memória compartilhada do time: o transcript de uma sessão do
Claude Code não é visível para as outras pessoas, então **só existe para a equipe o
que estiver commitado aqui**.

**Antes de qualquer análise, leia `FRAMEWORK.md`** (definições de métrica, regras de
análise, fluxo por pergunta) e o `LOG.md` (o que já foi respondido). Depois rode
`git log --oneline -20`. Se um colega já respondeu a pergunta, parta do trabalho
dele em vez de refazer.

**Toda sessão termina com commit.** Análise que não virou arquivo commitado não
existe para o resto da equipe.

> Blocos marcados **PENDENTE** ainda não foram verificados contra a fonte. Nunca
> preencha um PENDENTE por estimativa ou por memória: preencha com o que a fonte
> respondeu, e commite. Número sem fonte não sai.

---

## Fontes que esta célula cruza

| Fonte | Caminho de acesso | Status verificado em 2026-08-27 |
|---|---|---|
| Shopify (konjacmassamf.com.br) | Conector MCP `Shopify` | Conectado na conta, **token expirado na sessão**. Loja **não confirmada**. |
| GA4 | Service account + `google-analytics-data` | **Sem conector MCP.** Sem credencial e sem rota de rede. |
| Google Ads | OAuth2 refresh token + `google-ads` | **Sem conector MCP.** Sem credencial e sem rota de rede. |
| Meta Ads | Conector MCP `Meta Ads MCP` | **OPERACIONAL desde 2026-08-31.** Autorizado e habilitado no chat. Leitura completa de campanha, conjunto e anúncio. |
| BigQuery | Service account + `google-cloud-bigquery` | **Sem conector MCP.** Sem credencial e sem rota de rede. |

---

## Contas, propriedades e IDs

Nada aqui foi confirmado ainda. Cada item só sai de PENDENTE depois de a fonte
responder de verdade, na própria sessão que o preencher.

- **Loja Shopify**: domínio público `konjacmassamf.com.br`. Domínio `.myshopify.com`:
  **`konjac-massas-mf.myshopify.com`**, confirmado em 2026-09-01 pelo `store_id` da
  integração Shopify no catálogo da Meta (`ads_catalog_list_partner_integrations`),
  ainda não confirmado pelo próprio conector Shopify. Fuso e moeda: **PENDENTE**
  (`get-shop-info`).
  A conta da agência tem mais de uma loja: **sempre confirme com `get-shop-info`
  antes de consultar** e use `switch-shop` se vier a loja errada.
- **Propriedade GA4**: **PENDENTE** (só dígitos, sem o prefixo `properties/`).
  Stream de dados da loja e ID de medição: **PENDENTE**.
- **Google Ads**: MCC (`login_customer_id`) e conta do cliente (`customer_id`),
  ambos sem hífens: **PENDENTE**. Moeda e fuso da conta: **PENDENTE**.
- **Pixel e catálogo da Meta** (confirmados em 2026-09-01):
  - Pixel vivo: **`233969141719482`** ("Pixel de Konjac Massa MF", criado em 2021).
    `first_party_cookie_enabled`, `data_use_setting: advertising_and_analytics`.
    **Conversions API Gateway da Meta: `NOT_ONBOARDED`**, não é por ali que entram os
    eventos de servidor.
  - Pixel **morto**: `914833979004725`, último disparo em 02.09.2020 e ainda marcado
    `is_active: true`. **Nunca plugue campanha nele.**
  - Catálogo: **`319564296740282`** "Konjac Massa MF - Shopify Product Catalog".
  - Integração Shopify do catálogo: `343139824323905`, `connected`, sincronização a
    cada ~2h, sem webhooks registrados.
- **Meta Ads**: a Konjac tem **três** contas no business `392689994582822`.
  Confirmadas em 2026-08-31:
  - `3051443881648697` **Konjac Massa MF - Performance - Agências**: a conta
    operacional. BRL, ativa, R$ 133.065,14 em 90 dias. **É esta que responde por
    performance.**
  - `474440398443354` **Alfinet | Konjac Massa MF**: ativa e consultável, mas
    **R$ 0,00 gastos em 90 dias**. Vazia hoje.
  - `2345619189520897` **Konjac Massa MF - Awareness**: `is_ads_mcp_enabled: false`,
    então o conector **não permite consultar**. Toda leitura de awareness fica
    incompleta até o Meta liberar o MCP nela.
  - Fuso da conta: **a confirmar**. Os timestamps da API voltam com offset `-0700`,
    o que indica fuso do Pacífico e **não** America/Sao_Paulo (ver Gotchas).
  - Janela de atribuição: **PENDENTE**. A API devolve `attribution_windows:
    ["default"]` sem dizer qual é. Confirmar no Ads Manager.
- **BigQuery**: projeto, dataset consolidado, localização (`US`, `southamerica-east1`
  ou outra): **PENDENTE**. Tabelas e granularidade: **PENDENTE** (ver Inventário).

## Inventário das fontes

**Não levantado.** Nenhuma fonte respondeu nesta sessão (rede bloqueada e conector
Shopify com token vencido). Assim que houver acesso, preencher aqui:

- **Shopify**: período coberto, número de pedidos, campos disponíveis por pedido,
  coleções ativas, política de teste/cancelado.
- **BigQuery**: datasets, tabelas, granularidade de cada uma, data mais recente,
  particionamento e clusterização.
- **GA4**: propriedade, streams, janela de retenção de dados, dimensões
  personalizadas, se há export nativo para BigQuery.
- **Google Ads e Meta Ads**: contas, campanhas ativas, janela de dados disponível,
  janelas de atribuição configuradas na plataforma.

---

## Credenciais: contrato de variáveis de ambiente

Credencial **nunca** entra no chat nem no repo. Entra sempre pelo painel de
environment do Claude Code na web (ícone de nuvem acima da caixa de mensagem),
em Environment variables.

| Variável | Para quê | Formato |
|---|---|---|
| `GOOGLE_APPLICATION_CREDENTIALS_JSON` | BigQuery e GA4 | conteúdo **inteiro** do JSON da service account, em uma linha |
| `GCP_PROJECT_ID` | projeto do BigQuery | ex.: `konjac-analytics` |
| `BQ_DATASET` | dataset consolidado | ex.: `konjac_consolidado` |
| `BQ_LOCATION` | região do dataset | ex.: `southamerica-east1` |
| `GA4_PROPERTY_ID` | propriedade GA4 | só dígitos |
| `GOOGLE_ADS_DEVELOPER_TOKEN` | Google Ads | token do MCC |
| `GOOGLE_ADS_CLIENT_ID` | Google Ads OAuth2 | `...apps.googleusercontent.com` |
| `GOOGLE_ADS_CLIENT_SECRET` | Google Ads OAuth2 | segredo do cliente OAuth |
| `GOOGLE_ADS_REFRESH_TOKEN` | Google Ads OAuth2 | refresh token do fluxo de app instalado |
| `GOOGLE_ADS_LOGIN_CUSTOMER_ID` | Google Ads | MCC, sem hífens |
| `GOOGLE_ADS_CUSTOMER_ID` | Google Ads | conta do cliente, sem hífens |
| `META_ADS_ACCESS_TOKEN` | Meta Ads (fallback do MCP) | token de System User |
| `META_ADS_ACCOUNT_ID` | Meta Ads | `act_<id>` |
| `SHOPIFY_STORE_DOMAIN` | Shopify (fallback do MCP) | `<loja>.myshopify.com` |
| `SHOPIFY_ADMIN_TOKEN` | Shopify (fallback do MCP) | `shpat_...` |

`scripts/setup.sh` materializa `GOOGLE_APPLICATION_CREDENTIALS_JSON` em
`.credentials/gcp-service-account.json` (modo 600) e monta
`.credentials/google-ads.yaml`. **`.credentials/` é barrado pelo `.gitignore`.**

### Permissões mínimas a conceder

- **BigQuery**: à service account, `roles/bigquery.jobUser` no projeto (para rodar
  query) e `roles/bigquery.dataViewer` no dataset (para ler). Só leitura.
- **GA4**: adicionar o `client_email` da service account como **Visualizador** (ou
  Analista) na propriedade, em Administrador > Gerenciamento de acesso à propriedade.
- **Google Ads**: acesso somente leitura à conta para o usuário do OAuth, e
  developer token aprovado no MCC. **Service account simples não serve** (ver Gotchas).
- **Meta Ads**: System User no Business Manager com a permissão `ads_read` sobre a
  conta de anúncios.
- **Shopify**: pelo conector MCP não há escopo a configurar. No fallback por Admin
  API, app customizado com `read_orders`, `read_products`, `read_customers`,
  `read_inventory` e `read_analytics`. Atenção: `read_orders` cobre apenas 60 dias
  por padrão; histórico maior exige o escopo `read_all_orders`, que a Shopify
  aprova sob solicitação.

---

## Environment do Claude Code na web

Configurar no ícone de nuvem acima da caixa de mensagem. **Mudança de environment
só vale para sessões novas**, então crie o environment e abra outra sessão.

1. **Network access: Custom.** Liberar, no mínimo:
   `bigquery.googleapis.com`, `analyticsdata.googleapis.com`,
   `analyticsadmin.googleapis.com`, `googleads.googleapis.com`,
   `oauth2.googleapis.com`, `accounts.google.com`, `storage.googleapis.com`,
   `graph.facebook.com`, `konjacmassamf.com.br` e o domínio `.myshopify.com` da loja.
2. **Environment variables**: as da tabela acima.
3. **Setup script**: `bash scripts/setup.sh`.

---

## Gotchas validados

Cada item abaixo foi verificado nesta infraestrutura. Não repita o teste, confie e
siga; se algum deixar de valer, corrija aqui e commite.

### Ambiente cloud

- **`apt` não funciona**: o proxy responde 403 em `archive.ubuntu.com` e nos PPAs.
  Instale por **pip** ou por binário baixado via HTTPS. Confirmado em 2026-08-27.
- **`pypi.org` e `files.pythonhosted.org` estão no `NO_PROXY`** e respondem direto,
  então `pip install` funciona mesmo com o resto da rede fechado.
- **Sem `gcloud`, `bq` ou `gsutil` no container.** Use as bibliotecas Python
  (`google-cloud-bigquery`), não CLI.
- **Diagnóstico de rede**: `curl -sS "$HTTPS_PROXY/__agentproxy/status"` lista os
  bloqueios recentes com o motivo. `HTTP 000` no curl é CONNECT recusado, não
  timeout da fonte.
- Container: Ubuntu 24.04, Python 3.11.15, Node 22.22.2, `jq` e `curl` presentes.

### Conectores MCP

- **Shopify e Meta Ads vencem o token.** O erro é
  `requires re-authorization (token expired)` e **não** se resolve por código:
  reautorize em claude.ai > Configurações > Conectores.
- **Conector instalado não é conector habilitado.** O `Meta Ads MCP` aparece
  instalado na conta mas com `enabledInChat: false`, e por isso as ferramentas dele
  nem carregam na sessão. Precisa ser ligado nas configurações de conectores **deste
  chat**, além de autorizado.
- **Não existe conector MCP de GA4, Google Ads ou BigQuery nesta conta.** O caminho
  é credencial de serviço pelas bibliotecas Python.
- **O Metricool não serve de atalho para Meta Ads nesta célula.** O conector está
  conectado e habilitado, e a API dele tem as redes `metaAds` e `facebookAds`, mas
  `getBrandSettings` em 2026-08-27 devolveu 5 marcas da agência e **nenhuma é a
  Konjac**; todas estão só com Instagram, nenhuma com conta de anúncios ligada.
  Antes de tentar esse caminho de novo, confira se a Konjac virou marca no painel.
  Não confunda o Metricool desta célula com o do estúdio de conteúdo: lá ele serve
  para agendamento, aqui só serviria como fonte de mídia, e hoje não serve.
- A conta tem mais de uma loja Shopify. **Sempre `get-shop-info` antes de consultar.**
- **O Meta Ads MCP devolve resultado grande em arquivo, não no chat.** Consulta de
  100 campanhas com 20 campos estoura o limite de tokens e o conteúdo vai para
  `tool-results/*.txt`, com schema `{ad_entities: <string JSON>, pagination}`.
  Processe com `jq -r '.ad_entities' arquivo | ...`: é um JSON **dentro de uma
  string**, precisa de dois parses.
- **`ads_get_ad_entities` pagina por linha, não por entidade.** Com
  `time_increment: "1"` o `limit` conta linhas de dia, então 60 linhas cobrem poucas
  campanhas. Confira sempre se a soma dos gastos bate com o total da conta antes de
  concluir qualquer coisa.
- **Nomes de campo do Meta MCP não são os da Graph API.** Não existe `spend`,
  `purchases` nem `purchase_value`: é `amount_spent`, `omni_purchase` e
  `purchase_roas`. `cost_per_result` não existe em nível de conta. Rode
  `ads_get_field_context` antes de montar a consulta.
- **`ads_get_ad_accounts` devolve as contas de TODOS os clientes da agência.** Filtre
  por `business_name` antes de qualquer coisa e nunca consulte conta de outro cliente.
- **`is_ads_mcp_enabled: false` bloqueia a conta**, mesmo com `is_queryable: true`.
  É o caso da conta de Awareness da Konjac.

### Autenticação Google

- **Google Ads API não aceita service account comum.** Só OAuth2 com refresh token
  (fluxo de app instalado) ou service account com delegação de domínio no Google
  Workspace, impersonando um usuário. Por isso o contrato de env vars do Ads pede
  `CLIENT_ID`, `CLIENT_SECRET` e `REFRESH_TOKEN`, e não a chave JSON.
- **BigQuery e GA4 aceitam service account direto**, sem impersonação.

### Instrumentação e CAPI

- **A CAPI da Meta já roda pelo app oficial da Shopify, não por server side próprio.**
  Verificado em 2026-09-01: 47,9% dos eventos de uma semana chegaram por servidor,
  Purchase com EMQ **9,3** e `fn`, `ln`, `ct`, `st`, `zip` e `country` em 100%, que só
  o objeto de pedido produz. **Derrubar o GTM server side não derruba a CAPI da Meta.**
- **EMQ de topo de funil é baixo por natureza, não por falha.** PageView e ViewContent
  ficam em 6,4 porque o visitante ainda não se identificou. Server side não conserta
  isso; captura de e-mail antes da compra conserta.
- **`fbc` em 80,9% no Purchase.** 19% das compras chegam sem identificador de clique.
  A causa está no caminho do clique (encurtador que corta query string, redirect que
  perde `fbclid`, app de consentimento bloqueando `_fbc`), não no envio.
- **Não confie em ROAS sem antes checar deduplicação.** Se navegador e servidor não
  deduplicam por `event_id`, a compra conta duas vezes e todo ROAS fica inflado.
  Ainda **não verificado** nesta conta: exige o Events Manager ou o cruzamento com
  pedidos da Shopify.

### Fuso e datas

- **O fuso de entrega é sempre `America/Sao_Paulo`** (ver FRAMEWORK.md).
- BigQuery guarda `TIMESTAMP` em UTC: converta com
  `DATE(timestamp_col, "America/Sao_Paulo")` antes de agrupar por dia, senão o dia
  vira UTC e as vendas da noite caem no dia seguinte.
- GA4 agrupa pelo fuso configurado **na propriedade**, que pode não ser o de São
  Paulo. Confirmar no inventário e registrar aqui: **PENDENTE**.
- Shopify entrega `createdAt` em UTC (ISO 8601) mas o ShopifyQL usa o fuso da loja.
  Uma mesma pergunta pelos dois caminhos pode dar dias diferentes.
- **A conta de Meta Ads parece não estar em America/Sao_Paulo.** Todo timestamp da
  API (`created_time`, `updated_time`) volta com offset `-0700`, que é fuso do
  Pacífico. Se for isso mesmo, o dia do Meta vira às 4h da manhã em São Paulo e
  **não fecha com o dia da Shopify**. Confirmar no Ads Manager e registrar aqui:
  **PENDENTE**. Até confirmar, não cruze dia a dia de Meta com dia a dia de Shopify
  sem avisar da diferença.

---

## Estrutura do repo

```
CLAUDE.md                    este arquivo: contas, IDs, credenciais, gotchas
FRAMEWORK.md                 definições de métrica, regras de análise, fluxo
LOG.md                       histórico cronológico inverso da célula
README.md                    o que é o repo e como começar
scripts/setup.sh             prepara o container (pip, venv, credenciais por env var)
scripts/validate.sh          valida item a item, com chamada real a cada fonte
scripts/requirements.txt     dependências Python fixadas
queries/bigquery/            SQL reutilizável
queries/shopifyql/           ShopifyQL reutilizável
analyses/<AAAA-MM-DD>-<assunto>/   uma pasta por análise entregue
dashboards/                  fontes dos canvas do Claude Design (.dc.html + canvas.json)
assets/brand/                paleta e tipografia da marca para os dashboards
exports/                     dado bruto, ignorado pelo git (PII nunca sobe)
```

## Higiene inegociável

- **Nunca commitar** credencial, token, chave JSON, `.env` ou export com dado
  pessoal de cliente (nome, e-mail, telefone, endereço, CPF).
- Recorte commitado em `analyses/` tem que ser **agregado**. Nada de linha por
  cliente identificável.
- `scripts/validate.sh` item 7 checa isso a cada rodada e falha se encontrar
  arquivo de credencial rastreado. Rode antes de commitar.
