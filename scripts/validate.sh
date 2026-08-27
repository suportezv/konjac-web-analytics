#!/usr/bin/env bash
# ============================================================================
# Konjac Web Analytics: validação item a item do ambiente.
#
# Regra desta célula: nunca reportar sucesso sem ter testado de fato.
# Cada item aqui faz uma chamada real (import, DNS/CONNECT, ou API) e reporta
# OK, PENDENTE ou FALHOU com o motivo. Nada é presumido.
#
# Sai com 0 se nada FALHOU (PENDENTE não é falha: é dependência de autorização).
# Sai com 1 se algum item FALHOU.
#
# Itens de conector MCP (Shopify, Meta Ads) não são testáveis por shell:
# rodam dentro da sessão do Claude e estão listados no bloco final.
# ============================================================================
set -uo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
VENV="$REPO_ROOT/.venv"
PYBIN="$VENV/bin/python"
CRED_DIR="$REPO_ROOT/.credentials"
FAILED=0

ok()   { printf '  OK       %s\n' "$1"; }
pend() { printf '  PENDENTE %s\n' "$1"; }
fail() { printf '  FALHOU   %s\n' "$1"; FAILED=1; }

# Testa alcance real de um host: CONNECT pelo proxy do ambiente.
# 000 = tunnel recusado (política de rede) ou host inalcançável.
net_check() {
  local host="$1" label="$2"
  local code
  code=$(curl -s -o /dev/null -w '%{http_code}' --max-time 12 "https://$host/" 2>/dev/null)
  if [ "$code" = "000" ]; then
    pend "$label ($host): bloqueado pelo proxy do environment (CONNECT 403) ou inalcançável"
  else
    ok "$label ($host): responde HTTP $code"
  fi
}

echo "============================================================"
echo " Konjac Web Analytics: validação de ambiente"
echo " $(date -u '+%Y-%m-%d %H:%M UTC')"
echo "============================================================"

echo
echo "== 1. Runtime Python =="
if [ -x "$PYBIN" ]; then
  ok "venv presente ($("$PYBIN" --version 2>&1))"
else
  fail "venv ausente em $VENV. Rode: bash scripts/setup.sh"
  PYBIN=""
fi

echo
echo "== 2. Bibliotecas de dados (import real) =="
if [ -n "$PYBIN" ]; then
  "$PYBIN" - <<'PY'
import importlib
mods = [
    ("google.cloud.bigquery",        "BigQuery client"),
    ("google.oauth2.service_account","google-auth (service account)"),
    ("google.analytics.data_v1beta", "GA4 Data API"),
    ("google.analytics.admin_v1beta","GA4 Admin API"),
    ("google.ads.googleads.client",  "Google Ads client"),
    ("requests",                     "requests (Meta Graph / Shopify Admin)"),
    ("pandas",                       "pandas"),
    ("pyarrow",                      "pyarrow"),
]
for mod, label in mods:
    try:
        importlib.import_module(mod)
        print(f"  OK       {label}")
    except Exception as e:
        print(f"  FALHOU   {label}: {type(e).__name__}: {e}")
PY
  # Reexecuta só para capturar falha de import no código de saída.
  "$PYBIN" -c "
import importlib,sys
for m in ['google.cloud.bigquery','google.oauth2.service_account','google.analytics.data_v1beta','google.analytics.admin_v1beta','google.ads.googleads.client','requests','pandas','pyarrow']:
    importlib.import_module(m)
" >/dev/null 2>&1 || fail "pelo menos uma biblioteca não importa (ver linhas acima)"
else
  fail "sem venv: bibliotecas não testadas"
fi

echo
echo "== 2b. Runner de query (queries/ roda sem edição manual) =="
if [ -n "$PYBIN" ] && [ -f "$REPO_ROOT/scripts/run_bq_query.py" ]; then
  "$PYBIN" - "$REPO_ROOT" <<'PY'
import importlib.util, os, sys
root = sys.argv[1]
spec = importlib.util.spec_from_file_location("runner", os.path.join(root, "scripts/run_bq_query.py"))
mod = importlib.util.module_from_spec(spec)
spec.loader.exec_module(mod)

sql = "SELECT 1 FROM `${GCP_PROJECT_ID}.${BQ_DATASET}.__TABLES__`"

# 1) Sem as env vars, tem que falhar alto: nunca rodar query com placeholder cru.
os.environ.pop("GCP_PROJECT_ID", None); os.environ.pop("BQ_DATASET", None)
try:
    mod.resolver_parametros(sql)
    print("  FALHOU   runner aceitou placeholder não resolvido")
except SystemExit:
    print("  OK       runner recusa placeholder sem env var")

# 2) Com as env vars, tem que substituir tudo.
os.environ["GCP_PROJECT_ID"] = "p"; os.environ["BQ_DATASET"] = "d"
out = mod.resolver_parametros(sql)
print("  OK       runner resolve parâmetros" if "${" not in out
      else "  FALHOU   runner deixou placeholder no SQL")
PY
else
  pend "scripts/run_bq_query.py não testado (falta venv ou arquivo)"
fi

echo
echo "== 3. Rede: cada fonte de dados responde? =="
net_check bigquery.googleapis.com       "BigQuery API"
net_check analyticsdata.googleapis.com  "GA4 Data API"
net_check analyticsadmin.googleapis.com "GA4 Admin API"
net_check googleads.googleapis.com      "Google Ads API"
net_check oauth2.googleapis.com         "OAuth2 (troca de token Google)"
net_check accounts.google.com           "Accounts Google"
net_check storage.googleapis.com        "Cloud Storage (export de BQ)"
net_check graph.facebook.com            "Meta Graph API"
net_check "${SHOPIFY_STORE_DOMAIN:-konjacmassamf.com.br}" "Loja Shopify"

echo
echo "== 4. Credenciais presentes no environment =="
# Reporta presença da env var SEM nunca imprimir o valor: só o tamanho.
check_env() {
  local var="$1" label="$2" val
  val="${!var:-}"
  if [ -n "$val" ]; then
    ok "$var definida (${#val} chars) $label"
  else
    pend "$var não definida $label"
  fi
}
check_env GCP_PROJECT_ID                    "(projeto do BigQuery)"
check_env BQ_DATASET                        "(dataset consolidado)"
check_env GOOGLE_APPLICATION_CREDENTIALS_JSON "(chave JSON da service account)"
check_env GA4_PROPERTY_ID                   "(propriedade GA4, só dígitos)"
check_env GOOGLE_ADS_DEVELOPER_TOKEN        "(Google Ads)"
check_env GOOGLE_ADS_CLIENT_ID              "(Google Ads OAuth2)"
check_env GOOGLE_ADS_CLIENT_SECRET          "(Google Ads OAuth2)"
check_env GOOGLE_ADS_REFRESH_TOKEN          "(Google Ads OAuth2)"
check_env GOOGLE_ADS_LOGIN_CUSTOMER_ID      "(MCC, sem hífens)"
check_env GOOGLE_ADS_CUSTOMER_ID            "(conta do cliente, sem hífens)"
check_env META_ADS_ACCESS_TOKEN             "(fallback se o MCP não autorizar)"
check_env META_ADS_ACCOUNT_ID               "(act_<id>)"
check_env SHOPIFY_STORE_DOMAIN              "(fallback Admin API)"
check_env SHOPIFY_ADMIN_TOKEN               "(fallback Admin API)"

echo
echo "== 5. Chave de service account utilizável? =="
SA_PATH="${GOOGLE_APPLICATION_CREDENTIALS:-$CRED_DIR/gcp-service-account.json}"
if [ -n "$PYBIN" ] && [ -f "$SA_PATH" ]; then
  "$PYBIN" - "$SA_PATH" <<'PY'
import sys, json
path = sys.argv[1]
try:
    from google.oauth2 import service_account
    info = json.load(open(path))
    creds = service_account.Credentials.from_service_account_info(
        info, scopes=["https://www.googleapis.com/auth/cloud-platform"])
    print(f"  OK       chave carrega. Conta: {info.get('client_email')} | projeto: {info.get('project_id')}")
    print( "           (assinatura válida; o acesso real a BQ/GA4 só é provado no item 6)")
except Exception as e:
    print(f"  FALHOU   chave em {path} não carrega: {type(e).__name__}: {e}")
PY
else
  pend "nenhuma chave em $SA_PATH (rode setup.sh depois de definir GOOGLE_APPLICATION_CREDENTIALS_JSON)"
fi

echo
echo "== 6. Chamada real a cada API (prova de acesso, não só de credencial) =="

# --- BigQuery: lista datasets do projeto ---
if [ -n "$PYBIN" ] && [ -f "$SA_PATH" ] && [ -n "${GCP_PROJECT_ID:-}" ]; then
  "$PYBIN" - "$SA_PATH" "$GCP_PROJECT_ID" <<'PY'
import sys
try:
    from google.cloud import bigquery
    from google.oauth2 import service_account
    creds = service_account.Credentials.from_service_account_file(sys.argv[1])
    client = bigquery.Client(project=sys.argv[2], credentials=creds)
    ds = [d.dataset_id for d in client.list_datasets()]
    print(f"  OK       BigQuery respondeu: {len(ds)} dataset(s) em {sys.argv[2]}: {', '.join(ds[:10]) or '(nenhum)'}")
except Exception as e:
    print(f"  FALHOU   BigQuery não respondeu: {type(e).__name__}: {str(e)[:200]}")
PY
else
  pend "BigQuery não testado (falta chave ou GCP_PROJECT_ID)"
fi

# --- GA4: metadados da propriedade ---
if [ -n "$PYBIN" ] && [ -f "$SA_PATH" ] && [ -n "${GA4_PROPERTY_ID:-}" ]; then
  "$PYBIN" - "$SA_PATH" "$GA4_PROPERTY_ID" <<'PY'
import sys
try:
    from google.analytics.data_v1beta import BetaAnalyticsDataClient
    from google.analytics.data_v1beta.types import GetMetadataRequest
    from google.oauth2 import service_account
    creds = service_account.Credentials.from_service_account_file(sys.argv[1])
    client = BetaAnalyticsDataClient(credentials=creds)
    md = client.get_metadata(GetMetadataRequest(name=f"properties/{sys.argv[2]}/metadata"))
    print(f"  OK       GA4 respondeu: propriedade {sys.argv[2]}, "
          f"{len(md.dimensions)} dimensões e {len(md.metrics)} métricas disponíveis")
except Exception as e:
    print(f"  FALHOU   GA4 não respondeu: {type(e).__name__}: {str(e)[:200]}")
PY
else
  pend "GA4 não testado (falta chave ou GA4_PROPERTY_ID)"
fi

# --- Google Ads: lista contas acessíveis ---
if [ -n "$PYBIN" ] && [ -f "$CRED_DIR/google-ads.yaml" ]; then
  "$PYBIN" - "$CRED_DIR/google-ads.yaml" <<'PY'
import sys
try:
    from google.ads.googleads.client import GoogleAdsClient
    client = GoogleAdsClient.load_from_storage(sys.argv[1])
    svc = client.get_service("CustomerService")
    res = svc.list_accessible_customers()
    print(f"  OK       Google Ads respondeu: {len(res.resource_names)} conta(s) acessível(is): "
          f"{', '.join(r.split('/')[-1] for r in res.resource_names[:10])}")
except Exception as e:
    print(f"  FALHOU   Google Ads não respondeu: {type(e).__name__}: {str(e)[:200]}")
PY
else
  pend "Google Ads não testado (falta .credentials/google-ads.yaml; rode setup.sh com as env vars)"
fi

# --- Meta Ads: conta via Graph API (fallback ao MCP) ---
if [ -n "$PYBIN" ] && [ -n "${META_ADS_ACCESS_TOKEN:-}" ] && [ -n "${META_ADS_ACCOUNT_ID:-}" ]; then
  "$PYBIN" - <<'PY'
import os, sys
try:
    import requests
    acct = os.environ["META_ADS_ACCOUNT_ID"]
    if not acct.startswith("act_"):
        acct = "act_" + acct
    r = requests.get(
        f"https://graph.facebook.com/v21.0/{acct}",
        params={"fields": "name,account_status,currency,timezone_name",
                "access_token": os.environ["META_ADS_ACCESS_TOKEN"]},
        timeout=20)
    if r.status_code == 200:
        d = r.json()
        print(f"  OK       Meta Ads respondeu: {d.get('name')} | moeda {d.get('currency')} | tz {d.get('timezone_name')}")
    else:
        print(f"  FALHOU   Meta Ads HTTP {r.status_code}: {r.text[:200]}")
except Exception as e:
    print(f"  FALHOU   Meta Ads não respondeu: {type(e).__name__}: {str(e)[:200]}")
PY
else
  pend "Meta Ads não testado por HTTP (falta META_ADS_ACCESS_TOKEN/META_ADS_ACCOUNT_ID; caminho principal é o conector MCP)"
fi

# --- Shopify Admin API: identidade da loja (fallback ao MCP) ---
if [ -n "$PYBIN" ] && [ -n "${SHOPIFY_ADMIN_TOKEN:-}" ] && [ -n "${SHOPIFY_STORE_DOMAIN:-}" ]; then
  "$PYBIN" - <<'PY'
import os
try:
    import requests
    dom = os.environ["SHOPIFY_STORE_DOMAIN"]
    r = requests.post(
        f"https://{dom}/admin/api/2025-07/graphql.json",
        headers={"X-Shopify-Access-Token": os.environ["SHOPIFY_ADMIN_TOKEN"],
                 "Content-Type": "application/json"},
        json={"query": "{ shop { name myshopifyDomain ianaTimezone currencyCode } }"},
        timeout=20)
    if r.status_code == 200 and "data" in r.json():
        s = r.json()["data"]["shop"]
        print(f"  OK       Shopify respondeu: {s['name']} ({s['myshopifyDomain']}) | tz {s['ianaTimezone']} | {s['currencyCode']}")
    else:
        print(f"  FALHOU   Shopify HTTP {r.status_code}: {r.text[:200]}")
except Exception as e:
    print(f"  FALHOU   Shopify não respondeu: {type(e).__name__}: {str(e)[:200]}")
PY
else
  pend "Shopify não testado por HTTP (falta SHOPIFY_ADMIN_TOKEN/SHOPIFY_STORE_DOMAIN; caminho principal é o conector MCP)"
fi

echo
echo "== 7. Higiene do repo: credencial nunca versionada =="
cd "$REPO_ROOT"
LEAK=$(git ls-files 2>/dev/null | grep -iE '(^|/)(\.env$|.*credential.*\.json$|.*service-account.*\.json$|client_secret.*\.json$|google-ads\.ya?ml$|.*\.pem$|.*\.p12$)' || true)
if [ -z "$LEAK" ]; then
  ok "nenhum arquivo de credencial rastreado pelo git"
else
  fail "ARQUIVO DE CREDENCIAL RASTREADO PELO GIT: $LEAK"
fi
for p in .credentials/ exports/ .env; do
  if git check-ignore -q "$p" 2>/dev/null; then ok ".gitignore barra $p"; else fail ".gitignore NÃO barra $p"; fi
done

echo
echo "== 8. A validar dentro da sessão do Claude (não dá por shell) =="
echo "  - Shopify MCP: get-shop-info deve devolver a loja da Konjac Massa MF."
echo "    Se voltar outra loja da agência, use switch-shop antes de qualquer consulta."
echo "  - Meta Ads MCP: precisa aparecer como autorizado e habilitado neste chat."
echo "  - Ambos vencem token: 'requires re-authorization' significa reautorizar em"
echo "    claude.ai > Configurações > Conectores. Não é falha deste script."

echo
echo "============================================================"
if [ "$FAILED" -eq 0 ]; then
  echo " RESULTADO: nenhum item FALHOU."
  echo " Itens PENDENTE dependem de autorização ou de env var, não de código."
else
  echo " RESULTADO: há item(ns) FALHOU acima. Corrija antes de analisar."
fi
echo "============================================================"
exit "$FAILED"
