# analyses/

Uma pasta por análise entregue, no formato `<AAAA-MM-DD>-<assunto>/`. Exemplo:
`2026-09-03-queda-conversao-checkout/`.

Cada pasta carrega:

- **`README.md`** com três seções obrigatórias:
  - **Achado**: a resposta à pergunta de negócio, em uma frase.
  - **Método**: fontes consultadas, janela de datas, fuso (`America/Sao_Paulo`),
    definições do `FRAMEWORK.md` usadas e o modelo de atribuição declarado.
  - **Limitação**: o que este dado **não** prova. Seção obrigatória, nunca vazia.
- O **recorte agregado** dos dados que sustentam o achado.
- O **script ou notebook** que gerou o recorte.
- **Link para as queries** em `queries/` que foram usadas.

## O que não entra aqui

Dado pessoal de cliente: nome, e-mail, telefone, endereço, CPF. O recorte commitado
é **agregado**. Linha por cliente identificável fica em `exports/`, que o git ignora.
O `.gitignore` barra CSV, TSV, Parquet, JSONL e XLSX dentro de `analyses/`, exceto
arquivos com o prefixo `agregado_`, justamente para forçar a decisão consciente.

Toda análise entra também no `LOG.md`, no topo. Sem exceção.
