# dashboards/

Fontes dos canvas do Claude Design que viram os dashboards publicados como artifact:
os artboards em `.dc.html` e o `canvas.json` de cada painel.

Um subdiretório por painel, com o mesmo nome do painel. O painel de acompanhamento
padrão da célula está especificado no `FRAMEWORK.md`, seção 3.

## Regras do painel

- **Todo bloco carrega fonte, janela e fuso** no rodapé do card. Sem isso o número
  não sai (regra 1 do `FRAMEWORK.md`).
- **Bloco cuja fonte não respondeu aparece como "sem dado"**, nunca vazio e nunca
  estimado.
- Métrica de fontes cruzadas (por exemplo, pedidos da Shopify sobre sessões do GA4)
  vai marcada como tal no próprio card.
- Leitura de mídia declara o modelo e a janela de atribuição no card.
- Identidade visual em `assets/brand/`. Enquanto a paleta estiver **PENDENTE**, o
  painel não é publicado para o cliente.

Publicado o artifact, o link entra na entrada do `LOG.md` daquela análise.
