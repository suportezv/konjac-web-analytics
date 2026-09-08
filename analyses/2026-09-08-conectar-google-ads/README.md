# Conectar o Google Ads, e o que a Shopify já diz sobre o PMax

**Data:** 2026-09-08 | **Pediu:** suporte@zavi.ag
**Perguntas:** (1) o PMax está com ROAS péssimo e a taxa de conversão caiu, por quê?
(2) O que é preciso para conectar o Google Ads, passo a passo?

---

## Achado

**Não existe conexão de Google Ads nesta célula, por nenhum caminho.** Rechecado em
2026-09-08: sem conector MCP (o diretório do claude.ai não tem um oficial), sem as
seis variáveis de ambiente, sem rota de rede (`googleads.googleapis.com` responde
CONNECT 403). **A pergunta "por que o PMax caiu" não tem resposta com número até
essa conexão existir**, porque custo, cliques e conversões do Google só vivem lá.

O que existe, e apareceu nesta sessão, é o conector **Elos Link**, que lê a Shopify
direto. Por ele, a atribuição de último clique da loja mostra que **os pedidos
atribuídos ao PMax não caíram: subiram de 2,4 para 3,1 por dia**. Se o Google Ads
mostra queda de conversão enquanto a Shopify mostra pedidos estáveis, a hipótese
mais forte é **medição quebrada**, não campanha quebrada. E isso conversa direto com
o server side que saiu do ar.

---

## Método

- **Fontes:** conector Elos Link (`shopify_admin_query` e `origem_das_vendas`,
  janelas 7, 30 e 90 dias até 2026-09-08). **Coleta pontual, feita antes da decisão
  de não usar esse conector; não repetir por ele.** Diretório de conectores do claude.ai
  (`SearchMcpRegistry`). Ambiente do container (env vars e proxy).
- **Loja confirmada antes de qualquer número:** `Konjac Massa®`,
  `konjac-massas-mf.myshopify.com`, domínio `konjacmassamf.com.br`, fuso
  **America/Sao_Paulo**, BRL.
- **Atribuição da Shopify:** último clique por `utm_campaign` e referrer, na jornada
  do cliente. É **outro modelo** que o do Google Ads e o da Meta. Não compare os
  números absolutos entre eles; compare tendência.
- **Definições:** `FRAMEWORK.md`. A Shopify é a fonte canônica de receita.

---

## 1. O que a Shopify já mostra sobre o PMax

Campanha `pmaxsemrecurso`, último clique na Shopify:

| Janela | Pedidos | Receita | Pedidos por dia | Ticket | Participação nos pedidos da loja |
|---|---|---|---|---|---|
| 90 dias | 218 | R$ 57.414 | 2,42 | R$ 263 | 7,4% |
| 30 dias | 89 | R$ 22.873 | 2,97 | R$ 257 | 6,6% |
| 7 dias | 22 | R$ 5.442 | 3,14 | R$ 247 | 4,8% |

**Pedidos por dia subiram. A participação caiu porque a loja inteira acelerou**
(32,6 pedidos por dia em 90 dias, 45,1 em 30, 65,6 em 7), puxada pela Meta.
Ticket caiu 6% no período, o que é pequeno.

Para efeito de comparação, a busca de marca (`brandedexata`) foi de 5,2 para 10,7
pedidos por dia no mesmo intervalo. Marca colhe a demanda que a Meta cria.

### O que isso significa para a pergunta

Do lado da Shopify, o PMax **não** despencou. Se no Google Ads o ROAS está péssimo e
a taxa de conversão caiu, sobram duas explicações, e elas pedem ações opostas:

| Hipótese | O que se veria no Google Ads | O que se veria na Shopify | Ação |
|---|---|---|---|
| **A. Verba subiu, pedidos não acompanharam** | cliques e custo em alta, conversões estáveis, CVR e ROAS em queda | pedidos do PMax estáveis | ajustar lance ou verba, revisar sinais e ativos |
| **B. A conversão parou de ser medida** | conversões em queda brusca a partir de uma data, cliques normais | pedidos do PMax estáveis ou em alta | **consertar a tag antes de qualquer otimização** |

Os dados da Shopify são compatíveis com as duas. **A hipótese B é a perigosa**: o
lance inteligente aprende com a conversão medida, e se ela sumiu, o Google passa a
otimizar no escuro e a queda real vem em dias. Na análise de 2026-09-01 ficou
registrado exatamente esse risco, porque as conversões do Google podiam depender do
server side que estava saindo do ar.

**O teste que decide entre A e B leva dois minutos no Google Ads:** abrir a campanha
PMax, últimos 7 dias, coluna Conversões, e comparar com os **22 pedidos** que a
Shopify atribui a ela no mesmo período. O modelo do Google é mais generoso que último
clique, então o normal é o Google mostrar **igual ou mais**. Se mostrar bem menos, é
B. Segundo teste: olhar a série diária de conversões e procurar um degrau; se houver,
a data do degrau é a data em que a medição quebrou.

Sem a conexão, é isso que dá para dizer. Com ela, a resposta sai em uma sessão.

---

## 2. O que é preciso para conectar o Google Ads

Não há conector oficial no diretório. Há **três caminhos reais**, e a recomendação é
decidir pelo passo 0.

### Passo 0: descobrir se a agência já tem developer token aprovado (5 minutos)

No Google Ads, entrar na **conta de administrador (MCC) da agência** > Ferramentas e
configurações > Configuração > **Central de API**. Lá aparece o developer token e o
**nível de acesso**.

- Se estiver em **Explorer**, **Básico** ou superior: os caminhos A e A-MCP resolvem
  hoje. O README oficial do servidor MCP diz que **Explorer já basta** para consultar
  conta de produção, e que tokens novos podem subir para Explorer sozinhos.
- Se estiver em **Conta de teste** ou não existir: pedir o acesso ali mesmo (o Google
  revisa em alguns dias úteis) **e** começar o caminho B em paralelo, que não depende
  de token.

### Caminho A: Google Ads API direta (o que o repo já está preparado para usar)

É o caminho documentado no `CLAUDE.md`, com `scripts/setup.sh` e
`scripts/validate.sh` já prontos para ele.

**A1. Developer token** (passo 0). Copiar da Central de API do MCC.

**A2. App OAuth no Google Cloud.** Console do Google Cloud > um projeto (pode ser o
mesmo do BigQuery) > APIs e serviços > **Ativar a Google Ads API** > Tela de
consentimento OAuth (tipo Interno se for Workspace) > Credenciais > Criar credencial
> ID do cliente OAuth > tipo **App para computador**. Guardar `client_id` e
`client_secret`.

**A3. Refresh token.** Alguém com acesso à conta de Google Ads da Konjac (leitura
basta) roda **na própria máquina**, uma vez:

```bash
pip install google-auth-oauthlib
python scripts/gerar_refresh_token_google_ads.py --client-id "..." --client-secret "..."
```

O script abre o navegador, a pessoa autoriza, e ele imprime o refresh token.
**Não roda no container cloud**, que não tem navegador nem rede para o Google.

**A4. IDs de conta.** No canto superior direito do Google Ads: o ID do MCC
(`login_customer_id`) e o ID da conta da Konjac (`customer_id`), os dois **sem
hífens**, só dígitos.

**A5. Environment do Claude Code** (ícone de nuvem acima da caixa de mensagem):

| Variável | Valor |
|---|---|
| `GOOGLE_ADS_DEVELOPER_TOKEN` | do passo A1 |
| `GOOGLE_ADS_CLIENT_ID` | do passo A2 |
| `GOOGLE_ADS_CLIENT_SECRET` | do passo A2 |
| `GOOGLE_ADS_REFRESH_TOKEN` | do passo A3 |
| `GOOGLE_ADS_LOGIN_CUSTOMER_ID` | MCC, só dígitos |
| `GOOGLE_ADS_CUSTOMER_ID` | conta da Konjac, só dígitos |

Network access **Custom** liberando `googleads.googleapis.com`,
`oauth2.googleapis.com` e `accounts.google.com`. Setup script `bash scripts/setup.sh`.
**Abrir sessão nova**: environment só vale para sessão nova.

**A6. Prova.** Na sessão nova, `bash scripts/validate.sh`. O item 6 chama
`list_accessible_customers` de verdade e lista as contas. Sem isso não está
conectado, está configurado.

Nenhuma credencial passa pelo chat, em nenhum passo.

### Caminho A-MCP: o servidor MCP oficial do Google (`googleads/google-ads-mcp`)

Lido no código em 2026-09-08. É um servidor Python com três ferramentas (`search`
em GAQL, `get_resource_metadata`, `list_accessible_customers`) que autentica por
**Application Default Credentials** com escopo `adwords`, lê o developer token de
`GOOGLE_ADS_DEVELOPER_TOKEN` e o MCC de `GOOGLE_ADS_LOGIN_CUSTOMER_ID`. Por padrão
fala **stdio**; vira **HTTP com OAuth** se receber `GOOGLE_ADS_MCP_OAUTH_CLIENT_ID`
e `_SECRET`. **Instala, sobe e responde ao handshake MCP dentro deste container**
(testado). A credencial só é lida na primeira chamada de ferramenta.

**As credenciais são as mesmas do caminho A.** Nenhum segredo a mais. A diferença é
que as consultas passam a ser ferramentas na sessão, como o Meta Ads MCP hoje.

Há dois modos de ligar, e o repo já está preparado para o primeiro.

#### Modo 1: dentro do Claude Code na web, pelo `.mcp.json` do repo (pronto)

O que já está commitado:

- `.mcp.json` na raiz apontando para `.venv/bin/google-ads-mcp`, com o developer
  token e o MCC vindos do environment por `${VAR}` (nada de segredo no arquivo).
- `scripts/setup.sh` instala o servidor no venv e, a partir de `GOOGLE_ADS_CLIENT_ID`,
  `CLIENT_SECRET` e `REFRESH_TOKEN`, grava a credencial no formato que o servidor lê
  (`authorized_user`), no caminho padrão onde `google.auth.default` procura.
- `scripts/validate.sh` item 2c prova que o servidor sobe; o item 6 prova o acesso.
- `queries/gaql/` com as três primeiras consultas do diagnóstico do PMax.

O que falta, e é só isto:

| # | Passo | Quem |
|---|---|---|
| 1 | Developer token do MCC com nível **Explorer** ou superior (passo 0) | quem administra o MCC |
| 2 | App OAuth **tipo Desktop** no Google Cloud, com a Google Ads API ativada no projeto | quem tem o Cloud |
| 3 | Refresh token, rodando **na própria máquina** `python scripts/gerar_refresh_token_google_ads.py --client-id ... --client-secret ...` (ou `gcloud auth application-default login --scopes=https://www.googleapis.com/auth/adwords --client-id-file=<json do app>`) | quem tem acesso à conta da Konjac |
| 4 | Environment do Claude Code: as seis variáveis `GOOGLE_ADS_*` (tabela do caminho A) e rede Custom com `googleads.googleapis.com`, `oauth2.googleapis.com`, `accounts.google.com` | você |
| 5 | **Sessão nova.** Ao abrir, o Claude Code pede para aprovar o servidor do `.mcp.json`; aprovar. As ferramentas `search` e `list_accessible_customers` aparecem. | você |
| 6 | `bash scripts/validate.sh`: itens 2c e 6 têm que dar OK | eu, na sessão nova |

Ponto de atenção: o servidor faz uma chamada a `pypi.org` ao subir (checagem de
versão do FastMCP). Funciona aqui porque `pypi.org` está no `NO_PROXY`.

#### Modo 2: hospedado no Cloud Run, ligado como conector no claude.ai (para o time)

É o modo que faz o Google Ads aparecer para **qualquer pessoa da agência**, em
qualquer sessão, sem mexer no environment, com login individual. Igual ao Meta Ads
MCP. Custa um serviço no Cloud Run.

1. Projeto no Google Cloud com Google Ads API, Cloud Run, Cloud Build, Artifact
   Registry e **Firestore** ativados (o Firestore guarda os tokens OAuth dos usuários
   entre instâncias; sem ele, cada reinício derruba o login).
2. App OAuth **tipo Web** no mesmo projeto. O redirect URI é o do servidor: a URL do
   Cloud Run mais o caminho de callback do FastMCP (confira no log do primeiro deploy
   e cadastre no app OAuth).
3. Build e deploy conforme o README do repo (`gcloud builds submit`, depois
   `gcloud run deploy` com `GOOGLE_ADS_DEVELOPER_TOKEN`, `GOOGLE_ADS_MCP_OAUTH_CLIENT_ID`,
   `GOOGLE_ADS_MCP_OAUTH_CLIENT_SECRET`, `GOOGLE_ADS_MCP_BASE_URL`,
   `GOOGLE_ADS_MCP_JWT_SIGNING_KEY`, `GOOGLE_ADS_MCP_STORAGE_TYPE=firestore`,
   `FASTMCP_HOST=0.0.0.0` e, se o acesso for por MCC, `GOOGLE_ADS_LOGIN_CUSTOMER_ID`).
   O README pede `--allow-unauthenticated` no Cloud Run porque a autenticação é feita
   pelo próprio servidor, na camada OAuth.
4. Na primeira subida a URL ainda não existe; depois do deploy, atualizar
   `GOOGLE_ADS_MCP_BASE_URL` com a URL do Cloud Run e cadastrar o redirect no app OAuth.
5. No claude.ai: Configurações > Conectores > adicionar conector customizado com
   `https://<url-do-cloud-run>/mcp` > autorizar com a conta Google que tem acesso ao
   Google Ads > habilitar no chat.
6. A conta de serviço do Cloud Run precisa de `roles/datastore.user` para o Firestore.
   O README avisa que entradas expiradas não são apagadas sozinhas; prever limpeza.

**Segurança:** o developer token fica no servidor; cada usuário vê só as contas às
quais a própria conta Google tem acesso. Quem não tem acesso ao Google Ads da Konjac
não enxerga nada por esse conector.

### Caminho B: Google Ads para o BigQuery (durável, cobre GA4 também, sem developer token)

É o que a arquitetura da célula sempre previu: BigQuery como base consolidada.

**B1.** Projeto no Google Cloud com **BigQuery** e **BigQuery Data Transfer API**
ativados.

**B2.** BigQuery > Transferências de dados > Criar transferência > fonte
**Google Ads** > informar o ID da conta da Konjac (ou o MCC, para trazer todas) >
dataset de destino (por exemplo `google_ads`) > agenda diária > autorizar com uma
conta Google que tenha acesso ao Google Ads. Solicitar o **preenchimento retroativo**
para ter histórico. **Não precisa de developer token.**

**B3.** No GA4, Administrador > Vinculações do BigQuery > exportação diária, no
mesmo projeto. Com isso Google Ads e GA4 ficam lado a lado.

**B4.** Acesso da célula, uma de duas formas:
- **Conector BigQuery do diretório do claude.ai** (existe, conferido hoje: ferramentas
  `list_dataset_ids`, `get_table_info`, `execute_sql`). Instalar em Conectores,
  autorizar com uma conta que tenha `BigQuery Data Viewer` e `BigQuery Job User` no
  projeto, habilitar no chat. **Não exige mudar a rede do environment.**
- Ou o caminho de service account do `CLAUDE.md` (`GOOGLE_APPLICATION_CREDENTIALS_JSON`,
  `GCP_PROJECT_ID`, `BQ_DATASET`, `BQ_LOCATION` mais rede liberada).

**B5.** Latência: a transferência roda uma vez por dia, então o dado é sempre de D-1.
Para diagnóstico de "por que caiu" isso serve; para acompanhar o dia, não.

### Caminho C: agregador pago via conector

O diretório tem **Supermetrics** e **Windsor.ai**, que ligam Google Ads, Meta, GA4 e
Shopify por OAuth, sem engenharia. Custa assinatura e coloca um fornecedor no meio,
com o esquema de dados dele. É a saída se ninguém puder mexer em Cloud e em token.

### Recomendação

**Passo 0 hoje.** Com token em Explorer ou acima: **A-MCP Modo 1** agora, porque o
repo já está pronto e são as mesmas credenciais do caminho A; ele responde a
pergunta do PMax na primeira sessão nova. Depois, **A-MCP Modo 2** para o time e
**B** para o histórico consolidado com GA4. Sem token: pedir o acesso hoje e fazer
**B** enquanto espera. **C** só se a decisão for zero engenharia.

---

## 3. Achados laterais que vieram da Shopify

- **A Meta foi reestruturada de novo por volta de 01.09.** A campanha
  `🟣 28.08.26 | MAX Convs | CBO` tem 195 pedidos e R$ 51.529 em último clique, **todos
  nos últimos 7 dias**, e a versão sem CBO parou. Ela sozinha é 43% da receita da
  semana. Não tenho o gasto de Meta desta semana, então não há ROAS aqui; fica como
  observação para a próxima leitura.
- **UTM quebrada.** Sete pedidos em 90 dias chegaram com `utm_campaign` literal
  `{{campaign.name}}`: algum anúncio está com a macro digitada num campo que não a
  resolve. Um pedido chegou com o ID numérico da campanha no lugar do nome, e um com
  `googleads` sem campanha. E o `|` no nome da campanha vira `%7C` em parte dos
  cliques, o que divide a mesma campanha em duas linhas.
- **Nomear campanha com emoji e barra vertical é frágil para UTM.** Um `utm_campaign`
  limpo, sem emoji nem `|`, evita a fragmentação acima.

---

## Limitação

- **O `.mcp.json` foi testado até o handshake, não até a ferramenta.** Sem
  credencial e sem rede não dá para ir além. Duas coisas ficam para a sessão nova:
  se o Claude Code na web carrega servidor de projeto do `.mcp.json` sem ajuste, e
  se o processo sobe com o repo como diretório de trabalho (o caminho
  `.venv/bin/google-ads-mcp` é relativo a isso).
- **Não há número de Google Ads nesta análise.** Nada de custo, clique, impressão,
  CVR ou ROAS do Google. Tudo sobre o PMax aqui é o que a Shopify atribui por último
  clique, e último clique subestima campanhas de topo como o PMax.
- **A hipótese de medição quebrada é hipótese.** É a mais consistente com os dados
  disponíveis e com o risco registrado em 01.09, mas só o teste da seção 1 confirma.
- **As janelas de 7, 30 e 90 dias se sobrepõem** (a de 7 está dentro da de 30, que
  está dentro da de 90). A tendência por dia foi calculada a partir delas, então é um
  sinal, não uma série limpa. A ferramenta `origem_das_vendas` não aceita janela
  customizada; uma série diária exigiria paginar pedidos por `shopify_admin_query`.
- **48 dos 459 pedidos da janela de 7 dias tiveram a primeira visita antes dela**,
  segundo a própria ferramenta.
- **Meta e Shopify usam modelos de atribuição diferentes.** Os R$ 51.529 do MAX Convs
  CBO na Shopify não são o que a Meta vai reportar.
