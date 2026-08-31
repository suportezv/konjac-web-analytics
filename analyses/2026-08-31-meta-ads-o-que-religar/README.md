# Meta Ads: o que vale religar e o que mudar

**Data:** 2026-08-31 | **Pediu:** suporte@zavi.ag
**Pergunta:** quais campanhas, conjuntos e anúncios vale ligar de novo, e quais
otimizações devemos fazer?

---

## Achado

**Em 28.08 a conta foi reestruturada: tudo foi pausado e subiu uma campanha nova.
As duas campanhas desligadas naquele dia eram as melhores da conta, rodando a ROAS
11,20 e 9,70, e a que ficou no ar roda a ROAS 2,81 com CPA três vezes maior.** A
série diária mostra que nenhuma das duas estava em queda quando foi desligada.

---

## Método

- **Fonte:** Meta Ads, conta `3051443881648697` (Konjac Massa MF - Performance -
  Agências), via conector MCP. Moeda BRL.
- **Janela:** últimos 90 dias e últimos 30 dias, mais série diária de agosto.
- **Atribuição:** a API devolveu `attribution_windows: ["default"]`, ou seja, o
  padrão configurado na conta. **Não confirmei qual é esse padrão no Ads Manager.**
  Todo ROAS e todo CPA aqui são atribuição de plataforma, não receita da Shopify.
- **Definições:** `FRAMEWORK.md`. Compra é `omni_purchase` (compras atribuídas pelo
  Meta). ROAS é `purchase_roas` (ROAS de plataforma). CPA aqui é **custo por compra**
  (gasto dividido por compras), não CAC, porque não separa cliente novo de recorrente.
- **Cobertura:** as 200 campanhas somam exatamente os R$ 133.065,14 da conta (100%).
  Os 120 conjuntos somam R$ 132.438 (99,5%) e os 150 anúncios somam R$ 112.724
  (84,7%); o resto está em anúncios de gasto pequeno, que não mudam a conclusão.
- **Recortes:** `agregado_campanhas_90d.csv`, `agregado_conjuntos_90d.csv`,
  `agregado_anuncios_90d.csv`.

### A conta em 90 dias

| Métrica | Valor |
|---|---|
| Investimento | R$ 133.065,14 |
| Compras | 2.632 |
| Receita atribuída pelo Meta | R$ 646.123,61 |
| ROAS de plataforma | 4,86 |
| Custo por compra | R$ 50,56 |
| Campanhas com gasto | 123 de 200 |
| Campanhas ativas hoje | 1 |

---

## 1. O corte de 28.08 desligou o que estava funcionando

| Campanha | Status | Gasto 30d | Compras | ROAS | Custo/compra |
|---|---|---|---|---|---|
| 🟠 23.07.26 GB BID CAP | pausada 28.08 | R$ 7.920 | 323 | **11,20** | R$ 24,52 |
| 🟠 23.07.26 GB LOW CARB FRIO ABERTO | pausada 28.08 | R$ 4.736 | 175 | **9,70** | R$ 27,06 |
| 🟠 24.07.26 GB CUP FRIO INTERESSES | pausada 08.08 | R$ 1.622 | 74 | **11,83** | R$ 21,92 |
| 🟣 28.08.26 MAX Convs | **ativa** | R$ 3.812 | 45 | **2,81** | R$ 84,72 |

A série diária da BID CAP em agosto, dia a dia, ficou entre ROAS 7 e 20 quase o mês
inteiro, com um único dia fraco em 27.08 (4,41). O gasto diário caiu de cerca de
R$ 450 no meio do mês para R$ 180 no fim, o que é o teto de lance limitando entrega,
não colapso de performance. **Ela foi desligada em boa fase.**

**Ressalva honesta:** a campanha ativa tem 3 dias de vida e está em aprendizado. Os
2,81 dela vão melhorar. A comparação direta com campanhas maduras não é justa, e não
estou dizendo que a nova é ruim. O que os dados dizem é que a conta está gastando
cerca de R$ 1.270 por dia em algo ainda não provado enquanto ativos com centenas de
conversões de evidência estão desligados.

## 2. Dentro da campanha ativa, o orçamento está no conjunto errado

| Conjunto | Gasto | Compras | ROAS | Custo/compra |
|---|---|---|---|---|
| 02 - [FEED/STORIES] QUENTE - Gracyanne | R$ 3.236 (85%) | 32 | **2,05** | R$ 101,12 |
| 01 - Campeões | R$ 576 (15%) | 13 | **7,09** | R$ 44,34 |

O conjunto que converte 3,5 vezes melhor recebe um sexto do dinheiro. Essa é a
correção mais barata e mais rápida da conta inteira.

## 3. A recomendação automática do Meta não bate com os dados desta conta

O painel de oportunidades do Meta (score 51/100) sugere, em 30 e tantas campanhas,
trocar a meta para **Maximizar valor de conversões** prometendo "7% de ROAS a mais".
Os números da própria conta dizem o contrário:

| Meta de otimização | Conjuntos | Gasto | Compras | ROAS | Custo/compra |
|---|---|---|---|---|---|
| Conversões (`OFFSITE_CONVERSIONS`) | 87 | R$ 106.947 | 2.395 | **5,45** | R$ 44,65 |
| Maximizar valor (`VALUE`) | 24 | R$ 17.624 | 227 | **3,47** | R$ 77,64 |
| Visitas ao perfil | 7 | R$ 6.057 | **0** | 0,00 | n/a |
| Engajamento de página | 2 | R$ 1.810 | 2 | 0,22 | R$ 904,87 |

Com R$ 124 mil de evidência, Conversões entrega 57% mais ROAS e custo por compra 42%
menor que Maximizar valor nesta conta. **Não seguir a recomendação genérica.** Se
quiser testar, teste com orçamento controlado e contra um espelho, não em massa.

## 4. Dinheiro que não volta

- **R$ 7.867** (5,9% da verba) em conjuntos com meta de visita ao perfil e
  engajamento de página, dentro de uma conta de **performance**. Zero compras nos de
  visita ao perfil.
- **R$ 4.747** em 4 anúncios "ATRAÇÃO" com **zero compras**, apesar de CTR de 5% a
  6%. CTR alto e venda zero é o retrato de criativo que atrai clique curioso e não
  comprador. Um deles está no ar desde 17.11.2025.

## 5. Criativos que já provaram que vendem (todos pausados)

| Anúncio | Gasto | Compras | ROAS | Custo/compra |
|---|---|---|---|---|
| AD06 - CARROSSEL | R$ 605 | 38 | **19,93** | R$ 15,91 |
| AD03_Collection | R$ 367 | 26 | **19,83** | R$ 14,13 |
| AD03 - CARROSSEL 3 | R$ 1.668 | 74 | **12,66** | R$ 22,54 |
| AD04 - BANNER 2 | R$ 1.074 | 49 | **12,64** | R$ 21,92 |
| AD06 - CARROSSEL | R$ 2.169 | 98 | **12,44** | R$ 22,13 |
| AD02 | R$ 3.034 | 148 | **11,92** | R$ 20,50 |
| AD01 - VÍDEO 1 | R$ 2.319 | 106 | **11,90** | R$ 21,88 |

Contra os 4 anúncios que estão no ar hoje:

| Anúncio ativo | Gasto | Compras | ROAS | Custo/compra |
|---|---|---|---|---|
| AD06 - LOW CARB | R$ 1.091 | 14 | 3,28 | R$ 77,92 |
| AD01 - VÍDEO 2 | R$ 1.141 | 12 | 1,86 | R$ 95,05 |
| AD07 - LOW CARB | R$ 177 | 2 | 1,88 | R$ 88,74 |
| AD01 - VÍDEO 1 | R$ 520 | 3 | **0,83** | R$ 173,43 |

Carrossel e collection ocupam o topo da lista de ROAS. Formato estático e carrossel
estão sendo subusados na estrutura nova, que é só vídeo e imagem única.

## 6. Catálogo quebrado

`ads_get_errors` acusa **"Product Catalog Is Deleted"** e **"Restore Product Tags"**
em 11 campanhas mais antigas (R$ 7.558 de gasto nos 90 dias). Os produtos marcados
nesses anúncios foram apagados do catálogo.

Isso **não** afeta a BID CAP nem a LOW CARB (conferi campanha a campanha, nenhuma das
duas está na lista). Mas afeta diretamente o item 5: **carrossel e collection são os
formatos de maior ROAS da conta e dependem do catálogo.** Consertar o catálogo é
pré-requisito para escalar esses formatos.

---

## O que fazer, em ordem

Nada abaixo foi executado. É recomendação para aprovação.

**Agora (reversível, alto impacto)**

1. **Religar `🟠 23.07.26 | GB | BID CAP`** (campanha `120254843735670102`, conjunto
   `120254843736100102`). 535 compras de evidência a ROAS 12. **Com uma condição:** a
   frequência dela chegou a 5,45 em 90 dias. Religar sem criativo novo acelera a
   fadiga. Religar já e trocar o criativo dentro de 7 a 10 dias.
2. **Religar `🟠 23.07.26 | GB | LOW CARB | FRIO —ABERTO`** (campanha
   `120254853922410102`). ROAS 9,70, frequência 3,83, ainda com folga de público.
3. **Rebalancear a campanha ativa:** tirar orçamento do conjunto
   `02 - QUENTE - Gracyanne` (ROAS 2,05) e passar para `01 - Campeões` (ROAS 7,09).
   Se estiver em CBO, separar em campanhas distintas para o orçamento não fugir de
   novo para o conjunto pior.
4. **Desligar o anúncio ativo `AD01 - VÍDEO 1`** (ROAS 0,83). Está perdendo dinheiro
   a R$ 173 por compra.

**Esta semana**

5. **Religar `🟠 24.07.26 | GB | CUP | FRIO - INTERESSES`** (ROAS 11,83, frequência
   2,26). Foi pausada em 08.08 e tem público menos desgastado que a BID CAP.
6. **Repor os criativos campeões** (AD02, AD01-VÍDEO 1, AD06-CARROSSEL,
   AD03-CARROSSEL 3, AD04-BANNER 2) nos conjuntos que voltarem ao ar.
7. **Consertar o catálogo** antes de subir carrossel e collection. Repor os produtos
   apagados com o mesmo retailer ID.
8. **Cortar as metas que não vendem:** mover visita ao perfil e engajamento de página
   para a conta de Awareness, ou desligar. São R$ 7.867 dos 90 dias.
9. **Arquivar os 4 anúncios "ATRAÇÃO"** (R$ 4.747, zero compras).

**Testar, não aplicar em massa**

10. Maximizar valor de conversões: os dados desta conta dizem que é pior. Se for
    testar, um conjunto espelho contra um de Conversões, mesmo público e mesmo
    criativo, e decidir por dado desta conta e não pela recomendação do painel.

---

## Limitação

**O que este dado não prova:**

- **ROAS e compras são atribuição do Meta, não faturamento da Shopify.** A receita
  real da loja não foi consultada nesta análise (conector Shopify com token
  expirado). O ROAS de 4,86 da conta é o que o Meta se atribui, e tipicamente
  superestima. Só o cruzamento com a Shopify diz o ROAS consolidado de verdade.
- **A janela de atribuição não foi confirmada** no Ads Manager. Se a conta usa uma
  janela mais larga que o padrão, os ROAS ficam inflados na mesma proporção para
  todos, o que preserva o ranking mas muda o nível.
- **A campanha ativa tem 3 dias.** O ROAS de 2,81 vai mudar, provavelmente para
  melhor. O argumento aqui não é que ela é ruim, é que o dinheiro provado está parado.
- **Performance passada não garante retorno igual.** Público desgasta, leilão muda e
  a BID CAP já estava com frequência 5,45. O que os dados sustentam é que essas
  campanhas merecem voltar e ser medidas de novo, não que vão repetir ROAS 12.
- **A conta `Konjac Massa MF - Awareness` (`2345619189520897`) não entrou.** O
  conector marca `is_ads_mcp_enabled: false` para ela. Se houver verba relevante lá,
  a leitura da marca está incompleta.
- **Correlação, não causa.** A queda de ROAS após 28.08 coincide com a
  reestruturação, mas coincide também com criativo novo, público novo e fase de
  aprendizado ao mesmo tempo. Não dá para isolar qual dos três pesa mais sem teste.
