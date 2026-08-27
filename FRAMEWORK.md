# Konjac Web Analytics: FRAMEWORK

Metodologia da célula de análise de web e mídia da **Konjac Massa MF**. Aqui ficam
as definições de métrica, as regras de análise e o fluxo por pergunta de negócio.
Contas, IDs, credenciais e gotchas ficam no `CLAUDE.md`.

> **Status: v0.1, proposta, aguardando aprovação.** As definições abaixo foram
> escritas a partir do padrão de mercado e das convenções de cada plataforma, e
> **ainda não foram confrontadas com os dados reais** (nenhuma fonte respondeu na
> sessão de abertura). Cada bloco marcado **A CONFIRMAR** depende de olhar a fonte.
> Aprovado o texto, ele vira lei da célula: uma métrica, uma definição.

---

## 1. Regras inegociáveis de análise

1. **Número sem fonte não sai.** Toda métrica entregue carrega fonte, janela de
   datas e fuso (`America/Sao_Paulo`).
2. **Nunca inventar nem estimar dado que não foi consultado.** Se a fonte não
   respondeu, a entrega diz que ela não respondeu. Lacuna se declara, não se
   preenche.
3. **Uma métrica, uma definição.** Receita, pedido, conversão, sessão e CAC são
   definidos aqui uma vez e usados iguais em todo lugar. **Quando GA4 e Shopify
   divergirem, mostre os dois números com a explicação da diferença**, nunca só o
   mais bonito.
4. **Atribuição é declarada, não implícita.** Toda leitura de mídia diz o modelo e a
   janela que está usando.
5. **Correlação não vira causa em texto de entrega.** Ou tem teste, ou vai rotulado
   como hipótese.
6. **Toda query entregue é reprodutível**: fica em `queries/`, com cabeçalho de
   fonte, granularidade e janela, e roda de novo sem edição manual.
7. **Em texto entregue ao cliente valem as regras da casa**: nunca usar travessão
   (reescreva a frase) e claim de produto sempre exato.

---

## 2. Definições de métrica (v0.1, para aprovar)

### Convenções que valem para todas

- **Fuso**: `America/Sao_Paulo`. Todo agrupamento por dia, semana ou mês usa a data
  local, não UTC.
- **Semana**: segunda a domingo.
- **Moeda**: BRL. Se alguma conta de mídia estiver em outra moeda, a conversão é
  declarada na entrega, com a taxa e a data usadas. **A CONFIRMAR** por conta.
- **Janela padrão de leitura**: últimos 28 dias completos, comparados com os 28
  anteriores. Dia corrente nunca entra (dado incompleto).

### Receita

| Nome | Definição | Fonte canônica |
|---|---|---|
| **Receita bruta** | Soma de `totalPriceSet` dos pedidos, incluindo frete e impostos, excluindo pedidos de teste e cancelados. | Shopify |
| **Receita líquida** | Receita bruta menos descontos, menos devoluções e reembolsos, menos frete. | Shopify |
| **Receita de produto** | Receita líquida sem frete e sem impostos. É a base para leitura de mix e de coleção. | Shopify |

**A Shopify é a fonte canônica de receita.** GA4 e as plataformas de mídia entram
como leitura de origem e de tendência, nunca como número de faturamento.

### Pedido

- **Pedido**: pedido criado na Shopify, excluindo pedidos de teste e cancelados.
- **Pedido pago**: pedido com `displayFinancialStatus` em `PAID` ou
  `PARTIALLY_PAID`. **Toda leitura diz qual dos dois está usando.**
- **Ticket médio (AOV)**: receita líquida dividida por número de pedidos, no mesmo
  recorte e na mesma janela.
- Boleto e Pix mudam o intervalo entre pedido criado e pedido pago. Isso distorce
  leitura diária. **A CONFIRMAR**: quanto pesa cada meio de pagamento na loja.

### Sessão e conversão

- **Sessão**: sessão do GA4 (`sessions`). GA4 encerra sessão por 30 minutos de
  inatividade e reinicia à meia-noite do fuso da propriedade.
- **Taxa de conversão de sessão**: `pedidos Shopify / sessões GA4`, na mesma janela
  e no mesmo fuso. **Sempre marcada como métrica de fontes cruzadas**, porque
  numerador e denominador vêm de sistemas diferentes.
- **Taxa de conversão do GA4**: `purchase / sessions`, só dentro do GA4. Serve para
  comparar canais entre si, não para dizer quanto a loja vendeu.
- **Funil de checkout**: `view_item` > `add_to_cart` > `begin_checkout` >
  `add_payment_info` > `purchase`. Cada etapa reportada com a fonte GA4.

**Por que Shopify e GA4 divergem** (explicação padrão nas entregas): a Shopify conta
o pedido no servidor; o GA4 conta o evento no navegador e perde o que for bloqueado
por consentimento, bloqueador de anúncio ou falha de carregamento. Pedido por
telefone, manual ou por outro canal entra na Shopify e não no GA4. Divergência de
5% a 15% é o esperado no mercado; acima disso, investigar a instrumentação.
**A CONFIRMAR**: a divergência real desta loja.

### Custo e eficiência de mídia

- **Investimento**: custo da plataforma, na moeda da conta, sem taxa de agência e
  sem imposto, salvo declaração em contrário.
- **CPM, CPC, CTR**: definições padrão de cada plataforma, sempre com a plataforma
  nomeada.
- **Conversão de plataforma**: conversão como a própria plataforma conta, dentro da
  janela de atribuição dela. **Nunca somar conversão do Google Ads com a do Meta
  Ads**: as janelas se sobrepõem e o mesmo pedido é contado duas vezes.
- **ROAS de plataforma**: receita atribuída pela plataforma dividida pelo
  investimento na plataforma. Vale para comparar campanhas **dentro** da mesma
  plataforma.
- **ROAS consolidado**: receita líquida da Shopify dividida pelo investimento total
  (Google Ads mais Meta Ads). Não é atribuído por canal: é eficiência agregada.
- **CAC**: investimento total de mídia dividido por **número de clientes novos** da
  Shopify na janela. Cliente novo é quem faz o primeiro pedido na janela, pela
  contagem de pedidos do cliente na Shopify, não por cookie.
  Se a leitura usar todos os pedidos e não só os de clientes novos, o nome muda para
  **custo por pedido**, nunca CAC.

### Atribuição

Toda leitura de mídia declara modelo e janela. Padrões desta célula:

- **Google Ads**: modelo e janela como configurados na conta. **A CONFIRMAR**.
- **Meta Ads**: janela declarada em toda entrega, no formato `7d clique / 1d
  visualização` ou o que estiver configurado. **A CONFIRMAR**.
- **GA4**: modelo da propriedade (data-driven por padrão desde 2023) sobre a
  dimensão de aquisição da sessão. **A CONFIRMAR** o que a propriedade usa.
- **Leitura consolidada**: quando o objetivo é decidir orçamento, a referência é
  receita Shopify contra investimento total, com as atribuições de plataforma ao
  lado, declaradas como estimativas de plataforma.

---

## 3. Painel de acompanhamento (v0.1, para aprovar)

Publicado como artifact, seguindo a identidade da marca (paleta e tipografia em
`assets/brand/`, hoje **PENDENTE**). Fonte em `dashboards/`.

**Regra do painel**: todo bloco carrega fonte, janela e fuso no rodapé do card. Bloco
cuja fonte não respondeu aparece como "sem dado", nunca vazio nem estimado.

**Bloco 1, Resultado (fonte Shopify)**
Receita líquida, pedidos, ticket médio, clientes novos contra recorrentes.
Janela de 28 dias contra os 28 anteriores.

**Bloco 2, Eficiência (Shopify mais plataformas)**
Investimento total, ROAS consolidado, CAC, custo por pedido. Cada plataforma
detalhada ao lado com o ROAS dela e a janela de atribuição declarada.

**Bloco 3, Aquisição (fonte GA4)**
Sessões por origem/mídia, taxa de conversão por canal, participação de cada canal na
receita segundo o GA4. Com o aviso de divergência contra a Shopify.

**Bloco 4, Funil (fonte GA4)**
`view_item` até `purchase`, com a queda percentual entre etapas e a etapa de maior
perda destacada.

**Bloco 5, Produto e mix (fonte Shopify)**
Receita por produto e por coleção, itens por pedido, produtos sem venda na janela,
alerta de estoque para os itens de maior giro.

**Bloco 6, Série histórica (fonte BigQuery)**
Receita, investimento e pedidos por semana, na janela mais longa que a base
consolidada cobrir. Só aparece depois do inventário do BigQuery.

---

## 4. Fluxo por pergunta de negócio

1. **Ler antes de consultar.** `LOG.md`, `git log --oneline -20` e `queries/`. Se um
   colega já respondeu, parta do trabalho dele.
2. **Escrever a pergunta em uma frase** e definir o recorte: métrica, janela, fuso,
   segmento.
3. **Declarar a fonte canônica** de cada número antes de consultar, e a atribuição
   que vai usar.
4. **Consultar.** Query nova vai para `queries/`, com cabeçalho de fonte,
   granularidade e janela, e nome que descreve a pergunta que responde.
5. **Conferir contra uma segunda fonte** quando existir. Divergiu, mostra as duas e
   explica.
6. **Escrever o achado** em `analyses/<AAAA-MM-DD>-<assunto>/README.md`, com achado,
   método e **limitação**. A limitação é obrigatória: o que este dado não prova.
7. **Publicar o painel** como artifact quando a entrega pedir visual.
8. **Registrar no `LOG.md`** e **commitar**. Sessão sem commit não aconteceu.

### O que fazer quando a fonte não responde

Diga que não respondeu, com o erro, e entregue o que as outras fontes deram. Não
preencha o buraco com estimativa, com média histórica nem com número de outra
plataforma que "dá quase na mesma".

---

## 5. Formato da entrega

Cada análise em `analyses/<AAAA-MM-DD>-<assunto>/`:

- `README.md`: **achado** (a resposta em uma frase), **método** (fontes, janela,
  fuso, definições usadas, atribuição declarada) e **limitação** (o que não prova).
- O recorte agregado dos dados (CSV agregado, nunca linha identificável de cliente).
- O script ou notebook que gerou o recorte.
- Link para as queries em `queries/` que foram usadas.

Uma entrada por análise no `LOG.md`, sem exceção.
