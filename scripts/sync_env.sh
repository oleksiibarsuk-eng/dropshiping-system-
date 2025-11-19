#!/usr/bin/env bash
set -euo pipefail

# This script generates a .env file from Bitwarden CLI.
# Prerequisites:
# - bitwarden-cli (bw)
# - jq
# - BW_SESSION exported in the environment:
#   export BW_SESSION=$(bw unlock --raw)

check_cmd() {
  if ! command -v "$1" >/dev/null 2>&1; then
    echo "Error: Required command '$1' is not installed."
    exit 1
  fi
}

check_cmd bw
check_cmd jq

if [ -z "${BW_SESSION:-}" ]; then
  echo "Error: BW_SESSION is not set."
  echo "Run: export BW_SESSION=\$(bw unlock --raw)"
  echo "Or, if using passwordless: export BW_SESSION=\$(bw unlock --raw --passwordless)"
  exit 1
fi

OUT_FILE=".env"

echo "# Generated from Bitwarden on $(date)" > "$OUT_FILE"

get_field() {
  local ITEM_NAME="$1"
  local FIELD_NAME="$2"
  bw get item "$ITEM_NAME" | jq -r ".fields[] | select(.name==\"$FIELD_NAME\").value"
}

add_env() {
  local ENV_NAME="$1"
  local ITEM_NAME="$2"
  local FIELD_NAME="$3"

  echo -n "Syncing ${ENV_NAME}..."
  if VALUE=$(get_field "$ITEM_NAME" "$FIELD_NAME"); then
    echo "${ENV_NAME}=${VALUE}" >> "$OUT_FILE"
    echo " OK"
  else
    echo " FAILED (Item '$ITEM_NAME' or field '$FIELD_NAME' not found)"
    # Continue for now; user can fix Bitwarden item names later.
  fi
}

echo "Starting sync to $OUT_FILE..."

# --- MAPPINGS (EDIT THESE TO MATCH YOUR BITWARDEN ITEMS) ---
add_env "OPENAI_API_KEY"      "OpenAI API"          "API_KEY"
add_env "ANTHROPIC_API_KEY"   "Claude API"          "API_KEY"
add_env "OPENROUTER_API_KEY"  "OpenRouter API"      "API_KEY"
add_env "EBAY_APP_ID"         "eBay PROD"           "APP_ID"
add_env "EBAY_CERT_ID"        "eBay PROD"           "CERT_ID"
add_env "EBAY_DEV_ID"         "eBay PROD"           "DEV_ID"
add_env "SHOPIFY_API_KEY"     "Shopify Main Store"  "API_KEY"
add_env "SHOPIFY_PASSWORD"    "Shopify Main Store"  "API_PASSWORD"
add_env "SUPABASE_URL"        "Supabase Main"       "URL"
add_env "SUPABASE_ANON_KEY"   "Supabase Main"       "ANON_KEY"
add_env "BINANCE_API_KEY"     "Binance"             "API_KEY"
add_env "BINANCE_API_SECRET"  "Binance"             "API_SECRET"

echo "Done. Wrote env vars to $OUT_FILE"

