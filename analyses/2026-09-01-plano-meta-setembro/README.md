# Meta Ads: como dividir R$ 65.000 em setembro

**Data:** 2026-09-01 | **Pediu:** suporte@zavi.ag
**Pergunta:** como dividir os R$ 65.000 de setembro em Meta, considerando julho e
todo o histórico da conta, sem usar quatro criativos vetados?

---

## Achado

**R$ 65.000 não é escalar esta conta, é voltar ao patamar onde ela mais rodou.**
A conta operou entre R$ 50 mil e R$ 70 mil por mês durante 8 meses, com ROAS
agregado de 5,69, e passou de R$ 100 mil em três meses de 2026. O gargalo de
setembro não é verba nem público: é **CPM**, que triplicou de R$ 12 para R$ 36,37
em agosto, e é **teto de lance**, que impediu a melhor campanha de gastar 81% do
próprio orçamento.

---

## Método

- **Fonte:** Meta Ads, conta `3051443881648697`, via conector MCP, em 01.09.2026.
- **Janelas:** histórico mensal completo da conta (`maximum`, 18 meses tabulados),
  mais os 90 dias por campanha, conjunto e anúncio já levantados em
  `analyses/2026-08-31-meta-ads-o-que-religar/`.
- **Atribuição:** padrão da conta, ainda não confirmada no Ads Manager.
- **Definições:** `FRAMEWORK.md`. ROAS é de plataforma. CPA aqui é custo por compra.
- **Recorte:** `agregado_mensal_conta.csv`.
- **Painel:** fonte em `dashboards/2026-09-01-plano-meta-setembro/painel.html`,
  publicado em https://claude.ai/code/artifact/8173d587-3099-46d6-ac27-2fb905f75601

---

## 1. A conta já provou que absorve R$ 65 mil

| Faixa de investimento mensal | Meses | Investimento médio | ROAS | Custo/compra |
|---|---|---|---|---|
| Até R$ 50 mil | 6 | R$ 41.843 | 5,51 | R$ 33,93 |
| **R$ 50 mil a R$ 70 mil** | **8** | **R$ 58.031** | **5,69** | **R$ 31,14** |
| R$ 70 mil a R$ 100 mil | 1 | R$ 77.089 | 3,56 | R$ 67,44 |
| Acima de R$ 100 mil | 3 | R$ 113.996 | 5,72 | R$ 44,39 |

Agosto de 2026 fechou em R$ 30.494. Setembro a R$ 65.000 é **2,1x o ritmo de
agosto**, mas ainda assim é o patamar mais confortável do histórico.

## 2. O gargalo real é o CPM

| Período | CPM | Alcance no mês |
|---|---|---|
| Até fev/2026 | R$ 9 a R$ 15 | 1,0 a 2,0 milhões |
| mai a jul/2026 | R$ 21 a R$ 25 | 0,8 a 1,3 milhão |
| **ago/2026** | **R$ 36,37** | **276.801** |

Com R$ 65.000 em setembro:

- ao CPM de agosto: **1,79 milhão** de impressões
- ao CPM de julho: **3,10 milhões**
- ao CPM que era normal até fevereiro: **5,20 milhões**

O CPM subiu junto com o estreitamento do público. Agosto alcançou 277 mil contas
contra 1 a 2 milhões no histórico. **Para gastar R$ 65 mil sem estourar frequência,
o público precisa voltar a abrir.**

## 3. Teto de lance é o motivo de não ter escalado, e tem número

| Campanha | Estratégia | Orçamento/dia | Gasto real/dia | Uso do orçamento | ROAS |
|---|---|---|---|---|---|
| 🟠 23.07.26 GB BID CAP | Bid cap | R$ 1.800 | ~R$ 336 | **19%** | 12,10 |
| 🟠 21.04.26 OS BID | Bid cap | R$ 6.000 | R$ 6.300 no total | ~2% | 7,21 |

As duas campanhas de teto de lance da conta entregam ROAS alto e **não conseguem
gastar**. Isso confirma o motivo do corte de 28.08. A correção não é abandonar a
estrutura, é trocar o mecanismo de lance.

## 4. A conta ganha dinheiro em frio, não em remarketing

Nível de campanha, 90 dias:

| Bloco | Campanhas | Investido | % da verba | Compras | ROAS |
|---|---|---|---|---|---|
| Frio / aberto | 102 | R$ 110.887 | **83,3%** | 2.362 | 5,28 |
| Quente / remarketing | 31 | R$ 9.222 | 6,9% | 180 | 4,20 |
| Topo (tráfego/engajamento) | 18 | R$ 7.844 | 5,9% | **2** | **0,05** |
| Lookalike | 4 | R$ 1.800 | 1,4% | 34 | 3,90 |

## 5. O plano de mídia diverge do histórico em dois pontos

O plano prevê para Meta: R$ 25.000 prospecção (ROAS meta 1,1x), R$ 20.000
consideração/retarget (3,0x) e R$ 20.000 remarketing (3,0x). Combinado, **ROAS meta
2,27x, receita R$ 147.500**.

**Ponto 1, a meta está abaixo do histórico.** Na faixa de R$ 50 mil a R$ 80 mil a
conta entregou ROAS 5,39. Se setembro repetir o histórico, R$ 65.000 fazem cerca de
R$ 350.000, não R$ 147.500. A meta do plano é 42% do que a conta já entrega. Ou o
plano usa outra definição de receita, ou está deliberadamente conservador, ou o
número de Meta no plano geral está subdimensionado em cerca de R$ 200 mil.

**Ponto 2, o funil está invertido para esta conta.** O plano põe 62% da verba
(R$ 40.000) em meio e fundo. O bloco quente da conta absorveu R$ 9.222 em 90 dias,
ou seja cerca de R$ 3.000 por mês. Pedir R$ 20.000 num mês é **6,5x** o que esse
público já demonstrou absorver. A campanha histórica de remarketing
(`19.02.26 VENDAS REMARKETING`) alcançou 138.209 contas com frequência 4,51.
Ao CPM de R$ 28,90 dela, R$ 20.000 comprariam 692 mil impressões sobre esse pool,
o que joga a frequência para perto de 5 em um único mês.

---

## A divisão proposta

R$ 65.000, o que dá R$ 2.167 por dia de média.

| # | Bloco | Verba | % | Por dia | Estrutura | ROAS esperado |
|---|---|---|---|---|---|---|
| 1 | **Frio e aberto de escala** | R$ 40.000 | 61,5% | R$ 1.333 | Highest volume, público amplo ou Advantage+, orçamento na campanha, 2 a 3 campanhas | 4,5 a 5,5 |
| 2 | **Cost cap, herdeiro da BID CAP** | R$ 12.000 | 18,5% | R$ 400 | Mesma estrutura da BID CAP, trocando teto de lance por **custo por resultado** em R$ 35 a R$ 40 | 6 a 9 |
| 3 | **Quente e recuperação** | R$ 8.000 | 12,3% | R$ 267 | Carrinho e checkout abandonados. Já é 2,6x o ritmo recente do bloco | 4 a 8 |
| 4 | **Teste de criativo novo** | R$ 5.000 | 7,7% | R$ 167 | Campanha isolada, orçamento por conjunto, para o teste não contaminar a escala | é teste |

**Por que o bloco 2 existe separado do 1.** O problema que motivou o corte de 28.08
foi escala, e teto de lance é exatamente o que impede escala. Custo por resultado
resolve o mesmo objetivo (proteger o CPA) sem travar a entrega: o Meta gasta o
orçamento buscando manter a média no teto, em vez de recusar leilões acima dele.
**O ROAS vai cair em relação aos 12,10**, e isso é o esperado: afrouxar o teto é
trocar eficiência por volume de propósito. Se sair acima de 6, a troca valeu.

**Por que 61,5% em frio.** Porque é onde 83% da verba já roda e onde estão os
ROAS 5,28 do bloco. O plano de mídia sugere 38,5%, e não há nada no histórico desta
conta que sustente tirar verba de frio para colocar em remarketing.

**Por que só R$ 8.000 em quente.** É o teto do que o pool aguenta sem estourar
frequência, e ainda assim é 2,6x o ritmo dos últimos 90 dias. Se o objetivo for
chegar aos R$ 20.000 do plano, o caminho é primeiro crescer o topo do funil por
dois meses e deixar o pool de site encher.

### Projeção

| Cenário | ROAS | Receita atribuída pelo Meta | Compras aproximadas |
|---|---|---|---|
| Conservador (piso da faixa histórica) | 4,0 | R$ 260.000 | ~1.550 |
| Central (agregado da faixa R$ 50 a 80 mil) | 5,39 | R$ 350.000 | ~1.930 |
| Otimista (repete jul e ago de 2026) | 6,0 | R$ 390.000 | ~2.100 |

Os três cenários ficam acima dos R$ 147.500 do plano.

---

## O que fazer antes de ligar a verba

1. **Cortar o ritmo da campanha ativa.** A `🟣 28.08.26 MAX Convs` acumulou
   R$ 15.834 desde 28.08, o que dá cerca de R$ 3.170 por dia. Nesse ritmo ela
   sozinha consome R$ 95.000 em setembro, R$ 30.000 acima de toda a verba de Meta.
   Ela roda a ROAS 2,52.
2. **Não simplesmente despausar as campanhas de julho.** Quatro criativos foram
   vetados e alguns deles rodavam dentro dessas campanhas. Despausar no nível de
   campanha traz os criativos vetados junto. Subir estrutura nova, ou despausar
   anúncio a anúncio.
3. **Abrir o público.** O CPM de R$ 36,37 é consequência de alcançar 277 mil contas.
   Sem reabrir, R$ 65.000 compram um terço das impressões que compravam em fevereiro.
4. **Consertar o catálogo** antes de subir carrossel e collection, que são os
   formatos de maior ROAS da conta (ver a análise de 2026-08-31).
5. **Produzir criativo novo.** Com quatro peças vetadas e CPM em máxima histórica,
   os dois problemas têm a mesma resposta.

---

## Limitação

- **Não consegui mapear os quatro criativos vetados para IDs de anúncio.** A
  ferramenta `ads_get_creatives` respondeu HTTP 502 em três tentativas seguidas. O
  que sei vem dos prints: as quatro peças são estáticas de oferta (Super Kit 5 por
  R$ 89, Kit 3 embalagens por R$ 49, receita de arroz de forno por R$ 19,90 e frete
  grátis do CUP), usadas em campanhas de 14.07, 15.07, 21.07 e 24.07. **Por
  dedução, e não por verificação**, os vencedores em vídeo (`AD01 - VÍDEO 1`,
  `AD02 - VIDEO 2`) não estão entre elas, porque as quatro peças são imagens
  estáticas. Confirmar no Ads Manager antes de subir.
- **ROAS é atribuição do Meta, não faturamento da Shopify.** O conector Shopify
  segue com token expirado, então a projeção de receita é a que o Meta se atribui.
- **A janela de atribuição continua não confirmada.**
- **A faixa histórica não é garantia.** O CPM de hoje é o dobro do que era na maior
  parte dos meses que sustentam o ROAS 5,39. A projeção central assume que abrir o
  público derruba o CPM de volta para a faixa de R$ 20 a R$ 25. Se o CPM ficar em
  R$ 36, o cenário conservador vira o provável.
- **A conta de Awareness (`2345619189520897`) segue fora**, por
  `is_ads_mcp_enabled: false`.
