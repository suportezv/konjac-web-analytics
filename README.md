# Konjac Web Analytics

Célula de análise de **web e mídia da Konjac Massa MF** dentro da agência. Cruza
cinco fontes (Shopify, GA4, Google Ads, Meta Ads e BigQuery) para responder
perguntas de negócio, e entrega análise versionada aqui mais dashboard publicado
como artifact.

Este repositório é a **memória compartilhada da célula**. Cada pessoa abre a própria
sessão do Claude Code, e um transcript não enxerga o outro. O que dá continuidade ao
time é o que está commitado aqui.

## Como começar

```bash
bash scripts/setup.sh      # prepara o container (venv, libs, credenciais por env var)
bash scripts/validate.sh   # valida item a item, com chamada real a cada fonte
```

`validate.sh` reporta **OK**, **PENDENTE** ou **FALHOU** por item e nunca dá sucesso
sem ter testado. `PENDENTE` é dependência de autorização ou de variável de ambiente;
`FALHOU` é problema a corrigir antes de analisar.

## Antes de qualquer análise

1. Leia o `FRAMEWORK.md` (definições de métrica, regras, fluxo por pergunta).
2. Leia o `CLAUDE.md` (contas, IDs, credenciais, gotchas já validados).
3. Leia o `LOG.md` e rode `git log --oneline -20`. Se um colega já respondeu a
   pergunta, parta do trabalho dele em vez de refazer.

## Mapa dos diretórios

| Caminho | O que guarda |
|---|---|
| `CLAUDE.md` | memória persistente: contas, IDs, credenciais por env var, gotchas |
| `FRAMEWORK.md` | metodologia: definições de métrica, regras de análise, fluxo |
| `LOG.md` | histórico da célula, em ordem cronológica inversa |
| `scripts/` | `setup.sh`, `validate.sh` e as dependências fixadas |
| `queries/` | SQL do BigQuery e ShopifyQL reutilizáveis, com cabeçalho obrigatório |
| `analyses/` | uma pasta por análise entregue: `<AAAA-MM-DD>-<assunto>/` |
| `dashboards/` | fontes dos canvas do Claude Design (`.dc.html` e `canvas.json`) |
| `assets/brand/` | paleta e tipografia da marca para os dashboards |
| `exports/` | dado bruto, **ignorado pelo git** |

## As duas regras que não se negociam

1. **Toda sessão termina com commit.** Análise que não virou arquivo commitado não
   existe para o resto da equipe.
2. **Número sem fonte não sai.** Toda métrica carrega fonte, janela de datas e fuso
   (`America/Sao_Paulo`). Dado que não foi consultado não é estimado: é declarado
   como ausente.

Credencial, token, chave JSON e export com dado pessoal de cliente **nunca** entram
no repo. O `.gitignore` barra desde o primeiro commit e o `validate.sh` confere a
cada rodada.
