# Dá para simplificar o tracking com os apps oficiais e só um GTM Web?

**Data:** 2026-09-01 | **Pediu:** suporte@zavi.ag
**Pergunta:** o server side atual está fora do ar ou vai sair. O plano era subir um
GTM novo, web e server, com estrutura de tracking pesada. Dá para simplificar usando
o app oficial do Google Ads e o oficial da Meta para Shopify, deixando só um GTM Web
básico?

---

## Achado

**Do lado da Meta, sim, e a evidência é que já está funcionando assim.** O app oficial
da Shopify está conectado (`integration_status: connected`, última sincronização hoje
às 10:38), o gateway próprio da Meta **não** está em uso (`NOT_ONBOARDED`), e mesmo
assim **47,9% dos eventos da última semana chegaram por servidor**, com o Purchase em
qualidade de correspondência **9,3 de 10** carregando nome, sobrenome, cidade, estado,
CEP e país em 100%. Esses campos vêm do objeto de pedido, não do navegador.

**Ou seja: a CAPI da Meta não depende do server side que vai cair.** O GTM server side
não é necessário para Meta.

**Do lado do Google, não consegui verificar nada**, porque esta célula não tem acesso
ao Google Ads. A recomendação de arquitetura vale, mas precisa ser conferida por
alguém com acesso antes de o server side atual sair do ar.

---

## Método

- **Fonte:** Meta Ads, conta `3051443881648697`, ferramentas de dataset e catálogo do
  conector MCP, em 01.09.2026.
- **Janela dos eventos:** 25.08 a 01.09.2026, 167 horas de dado horário.
- **Consultado:** `ads_get_datasets`, `ads_get_dataset_details`,
  `ads_get_dataset_quality`, `ads_get_dataset_stats` (por `event_source`),
  `ads_catalog_get_catalogs` e `ads_catalog_list_partner_integrations`.

---

## 1. A prova de que a CAPI da Meta não depende do server side

Quatro fatos, todos verificados na conta:

| Verificação | Resultado |
|---|---|
| App oficial da Shopify conectado ao catálogo | **Sim.** `platform: Shopify`, `integration_status: connected`, loja `konjac-massas-mf` |
| Última sincronização | **Hoje 10:38**, status `succeeded`, próxima às 12:51 |
| Token da integração | **Válido** (`is_token_persistently_invalid: false`) |
| Conversions API Gateway da Meta | **Não usado** (`gateway_status: NOT_ONBOARDED`) |
| Último evento de servidor no pixel | **Hoje 10:43** |

E o formato do que chega:

| | Eventos (7 dias) | Participação |
|---|---|---|
| Navegador (pixel) | 70.266 | 52,1% |
| **Servidor (CAPI)** | **64.511** | **47,9%** |

Razão servidor sobre navegador de **0,918**, praticamente um para um, com envio horário.

**O teste que fecha a questão, e que só você pode fazer:** se o server side atual já
está fora do ar, e o pixel recebeu evento de servidor hoje às 10:43, então a origem
não é ele. Confirme a data e a hora em que o server side caiu e compare com a série
horária de eventos de servidor. Se não houve queda, está provado.

## 2. Qualidade do que já chega

| Evento | EMQ | E-mail | Telefone | fbc |
|---|---|---|---|---|
| **Purchase** | **9,3** | 100% | 99,3% | 80,9% |
| AddPaymentInfo | 8,6 | 97,8% | 92,7% | 74,5% |
| InitiateCheckout | 7,5 | 61,3% | 40,8% | 74,3% |
| AddToCart | 7,0 | 33,8% | 30,7% | 73,9% |
| Search | 6,6 | 18,3% | 17,6% | 83,2% |
| ViewContent | 6,4 | 13,7% | 12,7% | 58,8% |
| PageView | 6,4 | 11,3% | 9,9% | 73,3% |

No Purchase entram ainda `zip`, `country`, `fn`, `ln`, `ct` e `st`, todos em 100%.
Um Purchase a 9,3 é o teto prático. **Não há ganho de matching a capturar com um
server side próprio.**

## 3. A arquitetura simplificada

| Camada | Quem resolve | Estado |
|---|---|---|
| Conversões Meta, servidor | **App oficial Meta na Shopify** | **funcionando, verificado** |
| Catálogo Meta | mesmo app | **funcionando, verificado** |
| Conversões Google Ads, servidor | **App oficial Google e YouTube na Shopify** | **não verificado** |
| Feed do Merchant Center | mesmo app | **não verificado** |
| GA4, e-commerce | GTM Web ou integração nativa | **a definir** |
| Demais pixels, eventos custom, consentimento | **GTM Web** | **a subir** |

**GTM server side deixa de ser necessário** para o que a Konjac faz hoje.

## 4. O que se perde ao simplificar

Vale entrar de olhos abertos. A estrutura pesada compraria:

- **Evento nascendo fora da Shopify.** Landing em outro domínio, quiz, funil externo.
  Os apps só enxergam a loja.
- **Fluxo único normalizado** para vários destinos. Com apps, cada destino tem a
  própria implementação e as próprias regras.
- **Controle do valor enviado.** Líquido de desconto e frete, por exemplo. Com os apps
  o valor é o que a Shopify manda.
- **Esquema de evento custom** além do padrão de e-commerce.
- **Independência de fornecedor.** Você passa a depender da implementação da Shopify,
  da Meta e do Google.
- **GA4 por servidor**, se a resistência a bloqueador de anúncio for requisito.

Nada disso é problema hoje. Se um virar, o server side volta para a mesa **sem
desfazer** o que os apps fazem: as duas coisas convivem.

## 5. O ponto cego que é urgente

**O Google.** Se as conversões do Google Ads hoje passam pelo server side que vai
cair, elas param quando ele sair, e ninguém vai perceber pelo painel de mídia antes de
o Performance Max começar a otimizar no escuro. O plano de mídia põe **R$ 51.000 em
Performance Max e R$ 24.000 em Search**, ou seja metade da verba do mês depende dessa
medição.

Antes de desligar o server side, alguém com acesso ao Google Ads precisa conferir:

1. Qual conversão está marcada como principal e de onde ela vem.
2. Se o app oficial Google e YouTube está instalado na loja e ligado à **mesma** conta
   de Google Ads que roda a mídia (e não a outra do MCC).
3. Se Enhanced Conversions está ativo.
4. Se a conversão de compra do app duplica com alguma tag do GTM atual.

---

## 6. Achados laterais

- **Domínio `.myshopify` sai de PENDENTE.** A integração devolve `store_id:
  konjac-massas-mf`, então o domínio é `konjac-massas-mf.myshopify.com`. Registrado no
  `CLAUDE.md`.
- **Pixel morto ainda ativo.** `914833979004725`, último disparo em 02.09.2020, sem
  nenhum evento de servidor. O vivo é o `233969141719482`. Arquivar o antigo.
- **Webhooks do catálogo não registrados** (`has_webhooks_registered: false`). A
  sincronização é por agendamento, a cada duas horas mais ou menos. Para preço e
  estoque isso significa até duas horas de defasagem no anúncio.
- **O catálogo em si está saudável.** Os erros de "Product Catalog Is Deleted" que
  apareceram na análise de 31.08 são de **conjuntos de produto** apagados em campanhas
  antigas, não do catálogo. O catálogo `319564296740282` sincroniza normalmente, com
  só 3 itens bloqueados por estarem fora de estoque.

---

## Limitação

- **A origem dos eventos de servidor é inferência forte, não prova direta.** A API diz
  que existem eventos de servidor e diz que a integração Shopify está conectada, mas
  não carimba qual integração enviou cada evento. O que sustenta a conclusão é o
  conjunto: gateway da Meta desligado, app da Shopify conectado e sincronizando, e um
  Purchase com campos de endereço em 100%, que só o objeto de pedido produz. A prova
  final está no Events Manager, na origem por evento, ou no teste da seção 1.
- **Nada do lado do Google foi verificado.** Sem conector e sem credencial de Google
  Ads nesta célula.
- **Deduplicação não verificada.** Se navegador e servidor não deduplicam por
  `event_id`, as compras contam duas vezes e todo ROAS das análises anteriores estaria
  inflado. A razão de 0,918 é consistente com deduplicação correta, mas não prova.
  O cruzamento com pedidos da Shopify segue bloqueado pelo token expirado do conector.
- **O nível de compartilhamento de dados no app da Shopify não foi lido**, só inferido
  pela assinatura dos campos.
