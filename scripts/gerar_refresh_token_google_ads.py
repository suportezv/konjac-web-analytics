#!/usr/bin/env python
"""
Gera o refresh token OAuth2 do Google Ads para a célula Konjac Web Analytics.

RODA NA SUA MÁQUINA, não no container cloud: o fluxo abre o navegador para você
autorizar com uma conta Google que tenha acesso (leitura basta) à conta de Google
Ads da Konjac. O container cloud não tem navegador e tem a rede fechada.

Pré-requisito local (uma vez):
    pip install google-auth-oauthlib

Uso:
    python scripts/gerar_refresh_token_google_ads.py \
        --client-id  "<client_id do app OAuth tipo Desktop>" \
        --client-secret "<client_secret>"

Saída: o refresh token. Cole em GOOGLE_ADS_REFRESH_TOKEN no environment do Claude
Code (ícone de nuvem > Environment variables). NUNCA cole no chat, NUNCA commite.

Por que este caminho e não service account: a Google Ads API não aceita service
account simples, só OAuth2 de usuário ou delegação de domínio no Workspace.
Ver CLAUDE.md, seção "Autenticação Google".
"""
import argparse
import sys

SCOPES = ["https://www.googleapis.com/auth/adwords"]


def main() -> int:
    ap = argparse.ArgumentParser(description="Gera o refresh token OAuth2 do Google Ads.")
    ap.add_argument("--client-id", required=True, help="client_id do app OAuth (tipo Desktop)")
    ap.add_argument("--client-secret", required=True, help="client_secret do mesmo app")
    args = ap.parse_args()

    try:
        from google_auth_oauthlib.flow import InstalledAppFlow
    except ImportError:
        sys.exit("FALHOU: instale antes com  pip install google-auth-oauthlib")

    client_config = {
        "installed": {
            "client_id": args.client_id,
            "client_secret": args.client_secret,
            "auth_uri": "https://accounts.google.com/o/oauth2/auth",
            "token_uri": "https://oauth2.googleapis.com/token",
            "redirect_uris": ["http://localhost"],
        }
    }
    flow = InstalledAppFlow.from_client_config(client_config, scopes=SCOPES)
    # prompt=consent + access_type=offline garantem que o Google devolva refresh token
    # mesmo que a conta já tenha autorizado este app antes.
    creds = flow.run_local_server(port=0, prompt="consent", access_type="offline")

    if not creds.refresh_token:
        sys.exit("FALHOU: o Google não devolveu refresh token. Revogue o acesso do app em "
                 "myaccount.google.com/permissions e rode de novo.")

    print("\nGOOGLE_ADS_REFRESH_TOKEN (cole no environment do Claude Code, nunca no chat):\n")
    print(creds.refresh_token)
    print("\nPronto. Agora defina também DEVELOPER_TOKEN, CLIENT_ID, CLIENT_SECRET,"
          " LOGIN_CUSTOMER_ID e CUSTOMER_ID no environment e abra uma sessão nova.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
