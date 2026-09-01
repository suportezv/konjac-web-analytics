# LOG da célula

Histórico em **ordem cronológica inversa**: entrada nova entra no topo. Uma entrada
por análise, sem exceção. Antes de começar qualquer análise, leia este arquivo e
rode `git log --oneline -20`.

Formato de cada entrada:

```
## AAAA-MM-DD  Assunto
- **Quem pediu**:
- **Pergunta de negócio**:
- **Consultado**: fontes, janela de datas, fuso
- **Resposta em uma frase**:
- **Entrega**: analyses/<pasta>/ | commit <sha> | artifact <url>
```

---

## 2026-09-01  Divisão dos R$ 65 mil de Meta em setembro

- **Quem pediu**: suporte@zavi.ag
- **Pergunta de negócio**: como dividir os R$ 65.000 de setembro em Meta,
  considerando julho e todo o histórico da conta, sem usar quatro criativos vetados?
- **Consultado**: Meta Ads, conta `3051443881648697`. Histórico mensal completo
  (`maximum`, 18 meses tabulados) mais os cortes de 90 dias por campanha, conjunto e
  anúncio. Atribuição padrão da conta, ainda não confirmada.
- **Contexto novo do cliente**: as duas campanhas foram pausadas em 28.08 por não
  estarem escalando, não por ineficiência. O dado sustenta: a BID CAP usava teto de
  lance e gastava 19% do próprio orçamento diário.
- **Resposta em uma frase**: R$ 65.000 é o patamar mais confortável do histórico
  (8 meses na faixa R$ 50 a 70 mil a ROAS 5,69), então a divisão proposta é
  R$ 40.000 em frio de escala, R$ 12.000 na estrutura da BID CAP com custo por
  resultado no lugar do teto de lance, R$ 8.000 em quente e R$ 5.000 em teste de
  criativo, com dois alertas: o CPM triplicou para R$ 36,37 e o plano de mídia
  subdimensiona o Meta em cerca de R$ 200 mil.
- **Entrega**: `analyses/2026-09-01-plano-meta-setembro/` com achado, método,
  divisão, projeção em três cenários, cinco pré-requisitos e limitações.

## 2026-08-31  Meta Ads: o que vale religar

- **Quem pediu**: suporte@zavi.ag
- **Pergunta de negócio**: quais campanhas, conjuntos e anúncios vale ligar de novo,
  e quais otimizações devemos fazer?
- **Consultado**: Meta Ads, conta `3051443881648697` (Konjac Massa MF - Performance -
  Agências), via conector MCP, agora autorizado. Janelas de 90 e 30 dias mais série
  diária de agosto, nos níveis de campanha (200), conjunto (120) e anúncio (150).
  Atribuição: padrão da conta (`attribution_windows: ["default"]`, valor não
  confirmado no Ads Manager). Fuso da conta a confirmar, ver CLAUDE.md.
- **Resposta em uma frase**: a reestruturação de 28.08 desligou as duas melhores
  campanhas da conta (ROAS 11,20 e 9,70, com 498 compras de evidência nos últimos 30
  dias) e deixou no ar uma campanha a ROAS 2,81 cujo orçamento ainda está 85%
  concentrado no pior dos dois conjuntos dela.
- **Entrega**: `analyses/2026-08-31-meta-ads-o-que-religar/` com achado, método,
  10 recomendações priorizadas, limitações e três recortes agregados em CSV.
  Painel em `dashboards/2026-08-31-meta-ads-o-que-religar/painel.html`, publicado
  como artifact: https://claude.ai/code/artifact/96991d15-a6d3-4fdf-a7ea-b9029a9b935f
  Nenhuma alteração foi executada na conta: tudo é recomendação para aprovação.

## 2026-08-27  Montagem da célula e diagnóstico de acesso

- **Quem pediu**: suporte@zavi.ag
- **Pergunta de negócio**: nenhuma ainda. Sessão de abertura: montar a estrutura da
  célula, validar o ambiente e levantar o inventário das cinco fontes.
- **Consultado**: nada. **Nenhuma das cinco fontes respondeu.** O proxy do
  environment recusa CONNECT (403) para `bigquery.googleapis.com`,
  `analyticsdata.googleapis.com`, `analyticsadmin.googleapis.com`,
  `googleads.googleapis.com`, `oauth2.googleapis.com`, `accounts.google.com`,
  `storage.googleapis.com`, `graph.facebook.com` e `konjacmassamf.com.br`. O
  conector MCP da Shopify respondeu `requires re-authorization (token expired)` em
  duas tentativas. O conector Meta Ads está instalado mas não autorizado e não
  habilitado neste chat. Não existe conector de GA4, Google Ads ou BigQuery na conta.
- **Resposta em uma frase**: a estrutura da célula está montada e os scripts rodam,
  mas **o inventário das fontes não foi levantado porque nenhuma fonte respondeu**;
  depende de liberar a rede no environment, entregar as credenciais por variável de
  ambiente e reautorizar os dois conectores.
- **Entrega**: `CLAUDE.md`, `FRAMEWORK.md` (v0.1 das definições de métrica e do
  painel, **aguardando aprovação**), `README.md`, `scripts/setup.sh`,
  `scripts/validate.sh`, `queries/`, `dashboards/`, `assets/brand/`.
  Commit `54b3523` na branch `claude/konjac-analytics-setup-slcvfg`:
  https://github.com/suportezv/konjac-web-analytics/commit/54b3523
  Sem artifact: o painel não é publicado enquanto a paleta da marca estiver
  PENDENTE e enquanto não houver dado real para exibir.
