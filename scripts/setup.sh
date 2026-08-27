#!/usr/bin/env bash
# ============================================================================
# Konjac Web Analytics: setup do container (Linux/cloud).
#
# Idempotente: pode rodar quantas vezes for preciso, sempre com o mesmo fim.
# Não usa apt (o proxy do ambiente cloud responde 403 em archive.ubuntu.com).
# Tudo por pip (pypi.org está no NO_PROXY e responde direto) ou binário HTTPS.
#
# Não instala credencial nenhuma: só materializa, em arquivo local e ignorado
# pelo git, o que já vier por variável de ambiente do environment.
#
# Uso:  bash scripts/setup.sh
# Depois: bash scripts/validate.sh
# ============================================================================
set -uo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
VENV="$REPO_ROOT/.venv"
CRED_DIR="$REPO_ROOT/.credentials"
PY="${PYTHON_BIN:-python3}"

ok()   { printf '  OK       %s\n' "$1"; }
pend() { printf '  PENDENTE %s\n' "$1"; }
fail() { printf '  FALHOU   %s\n' "$1"; }

echo "== 1/5 Python =="
if ! command -v "$PY" >/dev/null 2>&1; then
  fail "python3 não encontrado. Instale um Python 3.10+ antes de seguir."
  exit 1
fi
ok "$("$PY" --version 2>&1)"

echo "== 2/5 venv em .venv =="
if [ ! -x "$VENV/bin/python" ]; then
  "$PY" -m venv "$VENV" || { fail "não consegui criar o venv em $VENV"; exit 1; }
  ok "venv criado"
else
  ok "venv já existe (reaproveitado)"
fi
"$VENV/bin/pip" install -q --disable-pip-version-check --upgrade pip >/dev/null 2>&1

echo "== 3/5 bibliotecas Python =="
# --upgrade mantém o venv alinhado com os pins do requirements a cada rodada.
if "$VENV/bin/pip" install -q --disable-pip-version-check --upgrade \
     -r "$REPO_ROOT/scripts/requirements.txt"; then
  ok "requirements.txt instalado"
else
  fail "pip install falhou. Rode sem -q para ver o erro:"
  echo "         $VENV/bin/pip install -r $REPO_ROOT/scripts/requirements.txt"
fi

echo "== 4/5 credencial de service account (se vier por env var) =="
mkdir -p "$CRED_DIR"
chmod 700 "$CRED_DIR"
SA_FILE="$CRED_DIR/gcp-service-account.json"

if [ -n "${GOOGLE_APPLICATION_CREDENTIALS:-}" ] && [ -f "${GOOGLE_APPLICATION_CREDENTIALS}" ]; then
  ok "GOOGLE_APPLICATION_CREDENTIALS já aponta para um arquivo existente"
elif [ -n "${GOOGLE_APPLICATION_CREDENTIALS_JSON:-}" ]; then
  # A env var carrega o JSON inteiro da chave. Gravamos em arquivo porque as
  # bibliotecas do Google leem caminho, não conteúdo. O arquivo fica em
  # .credentials/, que o .gitignore barra.
  printf '%s' "${GOOGLE_APPLICATION_CREDENTIALS_JSON}" > "$SA_FILE"
  chmod 600 "$SA_FILE"
  if "$VENV/bin/python" -c "import json,sys; d=json.load(open(sys.argv[1])); sys.exit(0 if d.get('type')=='service_account' and d.get('client_email') else 1)" "$SA_FILE" 2>/dev/null; then
    ok "chave de service account gravada em .credentials/gcp-service-account.json"
    echo "           conta: $("$VENV/bin/python" -c "import json;print(json.load(open('$SA_FILE'))['client_email'])" 2>/dev/null)"
    echo "           exporte:  export GOOGLE_APPLICATION_CREDENTIALS=$SA_FILE"
  else
    rm -f "$SA_FILE"
    fail "GOOGLE_APPLICATION_CREDENTIALS_JSON existe mas não é um JSON de service account válido"
  fi
else
  pend "GOOGLE_APPLICATION_CREDENTIALS_JSON não definida (BigQuery e GA4 ficam sem credencial)"
fi

# google-ads.yaml a partir das env vars, se todas estiverem presentes.
# O Google Ads API não aceita service account simples: exige refresh token OAuth2
# (ou delegação de domínio no Workspace). Ver CLAUDE.md, seção Gotchas.
ADS_YAML="$CRED_DIR/google-ads.yaml"
if [ -n "${GOOGLE_ADS_DEVELOPER_TOKEN:-}" ] && [ -n "${GOOGLE_ADS_CLIENT_ID:-}" ] \
   && [ -n "${GOOGLE_ADS_CLIENT_SECRET:-}" ] && [ -n "${GOOGLE_ADS_REFRESH_TOKEN:-}" ]; then
  {
    echo "developer_token: \"${GOOGLE_ADS_DEVELOPER_TOKEN}\""
    echo "client_id: \"${GOOGLE_ADS_CLIENT_ID}\""
    echo "client_secret: \"${GOOGLE_ADS_CLIENT_SECRET}\""
    echo "refresh_token: \"${GOOGLE_ADS_REFRESH_TOKEN}\""
    [ -n "${GOOGLE_ADS_LOGIN_CUSTOMER_ID:-}" ] && echo "login_customer_id: \"${GOOGLE_ADS_LOGIN_CUSTOMER_ID}\""
    echo "use_proto_plus: True"
  } > "$ADS_YAML"
  chmod 600 "$ADS_YAML"
  ok "google-ads.yaml gerado em .credentials/ (a partir das env vars)"
else
  pend "credenciais do Google Ads incompletas (precisa de DEVELOPER_TOKEN, CLIENT_ID, CLIENT_SECRET e REFRESH_TOKEN)"
fi

echo "== 5/5 diretórios de trabalho =="
mkdir -p "$REPO_ROOT/analyses" "$REPO_ROOT/queries/bigquery" \
         "$REPO_ROOT/queries/shopifyql" "$REPO_ROOT/dashboards" \
         "$REPO_ROOT/assets/brand" "$REPO_ROOT/exports"
ok "analyses/ queries/ dashboards/ assets/brand/ exports/"
echo "           exports/ é ignorado pelo git: dado bruto e PII nunca sobem"

echo
echo "Setup concluído. Próximo passo obrigatório:"
echo "  bash $REPO_ROOT/scripts/validate.sh"
