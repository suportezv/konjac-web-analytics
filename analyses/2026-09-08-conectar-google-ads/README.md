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

- **Fontes:** Elos Link (`shopify_admin_query` e `origem_das_vendas`, janelas 7, 30
  e 90 dias até 2026-09-08). Diretório de conectores do claude.ai
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

- Se estiver em **Acesso básico** ou superior: caminho A resolve hoje.
- Se estiver em **Conta de teste** ou não existir: pedir o acesso básico ali mesmo
  (o Google revisa em alguns dias úteis) **e** começar o caminho B em paralelo, que
  não depende de token.

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

### Caminho D: perguntar à Elos Link

As instruções do conector deles mencionam uma função `connect_google_ads` que não
está exposta aqui. Se eles puderem entregar o custo por campanha do Google pelo mesmo
conector, fecha com a atribuição da Shopify que já vem por ali. Vale uma pergunta.

### Recomendação

**Passo 0 hoje.** Com token aprovado: **A** agora, e **B** em seguida porque a célula
vai precisar do BigQuery de qualquer jeito. Sem token aprovado: pedir o acesso hoje
e fazer **B** como caminho principal. **C** só se a decisão for zero engenharia.

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
