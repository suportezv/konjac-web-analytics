# queries/

Toda consulta reutilizável da célula mora aqui. Duas regras:

1. **Nome descreve a pergunta que a query responde**, em kebab-case e em português.
   `receita-por-canal-por-semana.sql`, não `query3.sql`.
2. **Cabeçalho de comentário obrigatório**, com fonte, granularidade e janela.

## Cabeçalho obrigatório

```sql
-- Pergunta: <a pergunta de negócio, em uma frase>
-- Fonte: <BigQuery projeto.dataset.tabela | ShopifyQL dataset>
-- Granularidade: <uma linha por dia | por pedido | por campanha por dia | ...>
-- Janela: <como a janela é parametrizada>
-- Fuso: America/Sao_Paulo
-- Definições: <quais definições do FRAMEWORK.md esta query implementa>
-- Validada: <AAAA-MM-DD, por quem, contra qual fonte | NÃO VALIDADA>
```

O campo **Validada** é o que separa query confiável de rascunho. Query que nunca
rodou contra a fonte real fica marcada `NÃO VALIDADA` até alguém rodar e atualizar
a linha no mesmo commit.

## Reprodutibilidade

Query não se edita à mão para rodar de novo. Os parâmetros entram por variável de
ambiente, no formato `${VARIAVEL}`, e o runner resolve:

```bash
.venv/bin/python scripts/run_bq_query.py queries/bigquery/<arquivo>.sql
.venv/bin/python scripts/run_bq_query.py queries/bigquery/<arquivo>.sql --dry-run
```

`--dry-run` mostra o SQL já resolvido e o custo estimado sem executar nem cobrar.

As consultas ShopifyQL rodam pelo conector MCP da Shopify (`run-analytics-query`),
dentro da sessão do Claude. O arquivo aqui é a fonte da verdade do texto da query.
