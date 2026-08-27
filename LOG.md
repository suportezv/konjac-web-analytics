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
