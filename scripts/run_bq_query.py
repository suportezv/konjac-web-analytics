#!/usr/bin/env python
"""
Runner de query do BigQuery para a célula Konjac Web Analytics.

Existe para cumprir a regra 6 do FRAMEWORK.md: toda query entregue é reprodutível
e roda de novo sem edição manual. Os parâmetros da query entram por variável de
ambiente, no formato ${VARIAVEL}, e este runner resolve antes de executar.

Uso:
    .venv/bin/python scripts/run_bq_query.py queries/bigquery/<arquivo>.sql
    .venv/bin/python scripts/run_bq_query.py <arquivo>.sql --dry-run
    .venv/bin/python scripts/run_bq_query.py <arquivo>.sql --csv exports/saida.csv

--dry-run resolve o SQL, mostra o texto final e pede ao BigQuery a estimativa de
bytes lidos, sem executar e sem cobrar.

Saída de CSV vai por padrão para exports/, que o .gitignore barra. Recorte que for
para analyses/ tem que ser agregado, nunca linha identificável de cliente.
"""
import argparse
import os
import re
import sys
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parent.parent
CRED_DEFAULT = REPO_ROOT / ".credentials" / "gcp-service-account.json"
PLACEHOLDER = re.compile(r"\$\{([A-Z0-9_]+)\}")


def resolver_parametros(sql: str) -> str:
    """Troca ${VAR} pelo valor da env var. Falha alto se faltar alguma."""
    faltando = sorted({m for m in PLACEHOLDER.findall(sql) if not os.environ.get(m)})
    if faltando:
        sys.exit(
            "FALHOU: variáveis de ambiente não definidas: "
            + ", ".join(faltando)
            + "\n  Defina no environment do Claude Code (ver CLAUDE.md, seção"
            " 'Credenciais: contrato de variáveis de ambiente')."
        )
    return PLACEHOLDER.sub(lambda m: os.environ[m.group(1)], sql)


def cabecalho(sql: str) -> str:
    """Devolve o cabeçalho de comentário da query, que documenta fonte e janela."""
    linhas = []
    for linha in sql.splitlines():
        if linha.startswith("--"):
            linhas.append(linha)
        elif linhas:
            break
    return "\n".join(linhas)


def main() -> int:
    ap = argparse.ArgumentParser(description="Roda uma query .sql de queries/bigquery/.")
    ap.add_argument("arquivo", help="caminho do .sql")
    ap.add_argument("--dry-run", action="store_true",
                    help="resolve e estima o custo sem executar")
    ap.add_argument("--csv", metavar="CAMINHO",
                    help="grava o resultado em CSV (use exports/, que o git ignora)")
    ap.add_argument("--max-linhas", type=int, default=50,
                    help="quantas linhas imprimir no terminal (padrão 50)")
    args = ap.parse_args()

    caminho = Path(args.arquivo)
    if not caminho.is_file():
        sys.exit(f"FALHOU: arquivo não encontrado: {caminho}")

    sql_bruto = caminho.read_text(encoding="utf-8")
    sql = resolver_parametros(sql_bruto)

    projeto = os.environ.get("GCP_PROJECT_ID")
    if not projeto:
        sys.exit("FALHOU: GCP_PROJECT_ID não definida.")

    cred_path = os.environ.get("GOOGLE_APPLICATION_CREDENTIALS") or str(CRED_DEFAULT)
    if not Path(cred_path).is_file():
        sys.exit(
            f"FALHOU: chave de service account não encontrada em {cred_path}.\n"
            "  Defina GOOGLE_APPLICATION_CREDENTIALS_JSON no environment e rode"
            " bash scripts/setup.sh."
        )

    from google.cloud import bigquery
    from google.oauth2 import service_account

    creds = service_account.Credentials.from_service_account_file(cred_path)
    client = bigquery.Client(project=projeto, credentials=creds)
    local = os.environ.get("BQ_LOCATION") or None

    print(cabecalho(sql_bruto))
    print()

    if args.dry_run:
        cfg = bigquery.QueryJobConfig(dry_run=True, use_query_cache=False)
        job = client.query(sql, job_config=cfg, location=local)
        gb = job.total_bytes_processed / (1024 ** 3)
        print("--- SQL resolvido ---")
        print(sql)
        print("--- fim do SQL ---\n")
        print(f"DRY RUN: leria {gb:.3f} GB. Nada foi executado e nada foi cobrado.")
        return 0

    df = client.query(sql, location=local).result().to_dataframe()
    print(f"{len(df)} linha(s). Fonte: BigQuery, projeto {projeto}.")
    if len(df):
        try:
            print(df.head(args.max_linhas).to_markdown(index=False))
        except Exception:
            print(df.head(args.max_linhas).to_string(index=False))
        if len(df) > args.max_linhas:
            print(f"... (+{len(df) - args.max_linhas} linhas não impressas)")

    if args.csv:
        destino = Path(args.csv)
        destino.parent.mkdir(parents=True, exist_ok=True)
        df.to_csv(destino, index=False)
        print(f"\nCSV gravado em {destino}")
        if "exports/" not in str(destino) and "analyses/" in str(destino):
            print("ATENÇÃO: recorte em analyses/ tem que ser agregado."
                  " Confira que não há linha identificável de cliente antes de commitar.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
