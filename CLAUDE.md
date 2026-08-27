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
| Meta Ads | Conector MCP `Meta Ads MCP` | Instalado, **não autorizado e não habilitado neste chat**. |
| BigQuery | Service account + `google-cloud-bigquery` | **Sem conector MCP.** Sem credencial e sem rota de rede. |

---

## Contas, propriedades e IDs

Nada aqui foi confirmado ainda. Cada item só sai de PENDENTE depois de a fonte
responder de verdade, na própria sessão que o preencher.

- **Loja Shopify**: domínio público `konjacmassamf.com.br`. Domínio `.myshopify.com`,
  fuso e moeda: **PENDENTE** (`get-shop-info`).
  A conta da agência tem mais de uma loja: **sempre confirme com `get-shop-info`
  antes de consultar** e use `switch-shop` se vier a loja errada.
- **Propriedade GA4**: **PENDENTE** (só dígitos, sem o prefixo `properties/`).
  Stream de dados da loja e ID de medição: **PENDENTE**.
- **Google Ads**: MCC (`login_customer_id`) e conta do cliente (`customer_id`),
  ambos sem hífens: **PENDENTE**. Moeda e fuso da conta: **PENDENTE**.
- **Meta Ads**: `act_<id>` da conta de anúncios, moeda e fuso: **PENDENTE**.
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
- A conta tem mais de uma loja Shopify. **Sempre `get-shop-info` antes de consultar.**

### Autenticação Google

- **Google Ads API não aceita service account comum.** Só OAuth2 com refresh token
  (fluxo de app instalado) ou service account com delegação de domínio no Google
  Workspace, impersonando um usuário. Por isso o contrato de env vars do Ads pede
  `CLIENT_ID`, `CLIENT_SECRET` e `REFRESH_TOKEN`, e não a chave JSON.
- **BigQuery e GA4 aceitam service account direto**, sem impersonação.

### Fuso e datas

- **O fuso de entrega é sempre `America/Sao_Paulo`** (ver FRAMEWORK.md).
- BigQuery guarda `TIMESTAMP` em UTC: converta com
  `DATE(timestamp_col, "America/Sao_Paulo")` antes de agrupar por dia, senão o dia
  vira UTC e as vendas da noite caem no dia seguinte.
- GA4 agrupa pelo fuso configurado **na propriedade**, que pode não ser o de São
  Paulo. Confirmar no inventário e registrar aqui: **PENDENTE**.
- Shopify entrega `createdAt` em UTC (ISO 8601) mas o ShopifyQL usa o fuso da loja.
  Uma mesma pergunta pelos dois caminhos pode dar dias diferentes.

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
