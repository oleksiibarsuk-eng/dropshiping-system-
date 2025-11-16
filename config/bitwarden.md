# Secrets Management with Bitwarden

## Overview

All API keys, tokens, and sensitive credentials are stored in Bitwarden and NEVER committed to the repository.

## Required Secrets

### 1. OpenRouter
- **Item Name**: `Dropshipping - OpenRouter`
- **Fields**:
  - `OPENROUTER_API_KEY`: Your OpenRouter API key from https://openrouter.ai/keys

### 2. Supabase
- **Item Name**: `Dropshipping - Supabase`
- **Fields**:
  - `SUPABASE_URL`: Your project URL (e.g., https://xxx.supabase.co)
  - `SUPABASE_ANON_KEY`: Public anon key (safe for frontend)
  - `SUPABASE_SERVICE_ROLE_KEY`: Service role key (NEVER expose to frontend)

### 3. eBay API
- **Item Name**: `Dropshipping - eBay`
- **Fields**:
  - `EBAY_APP_ID`: Application ID from eBay Developer
  - `EBAY_CLIENT_ID`: OAuth Client ID
  - `EBAY_CLIENT_SECRET`: OAuth Client Secret
  - `EBAY_REFRESH_TOKEN`: OAuth Refresh Token
- **Setup Guide**: https://developer.ebay.com/api-docs/static/oauth-tokens.html

### 4. Shopify
- **Item Name**: `Dropshipping - Shopify`
- **Fields**:
  - `SHOPIFY_STORE_URL`: Your store URL (e.g., mystore.myshopify.com)
  - `SHOPIFY_ACCESS_TOKEN`: Admin API access token
- **Setup Guide**: https://shopify.dev/docs/api/admin-rest#authentication

### 5. Meta Business API
- **Item Name**: `Dropshipping - Meta`
- **Fields**:
  - `META_ACCESS_TOKEN`: Facebook Marketing API access token
  - `META_PAGE_ID`: Facebook Page ID for Marketplace
- **Setup Guide**: https://developers.facebook.com/docs/marketing-apis/get-started

### 6. Telegram Bot
- **Item Name**: `Dropshipping - Telegram`
- **Fields**:
  - `TELEGRAM_BOT_TOKEN`: Bot token from @BotFather
  - `TELEGRAM_CHAT_ID`: Your personal or group chat ID
- **Setup Guide**: https://core.telegram.org/bots#6-botfather

### 7. Make.com (Optional)
- **Item Name**: `Dropshipping - Make`
- **Fields**:
  - `MAKE_API_TOKEN`: API token from Make.com settings
  - `MAKE_WEBHOOK_URL`: Webhook URL for triggering scenarios

## Setup Instructions

### Step 1: Install Bitwarden CLI (Optional)

```bash
# macOS
brew install bitwarden-cli

# Verify installation
bw --version
```

### Step 2: Create .env Files Locally

**Frontend (.env.local)**:
```bash
cd frontend
cp ../config/.env.example .env.local
# Edit .env.local with values from Bitwarden
```

**Make.com Connections**:
1. Go to Make.com → Connections
2. Add connections for each service
3. Use API keys from Bitwarden

### Step 3: Verify Secrets

Never expose these secrets:
- ❌ Don't commit `.env` or `.env.local` files
- ❌ Don't log secrets in console or files
- ❌ Don't share service role keys
- ❌ Don't use production keys in development

### Step 4: Rotation Schedule

Rotate secrets every 90 days:
- OpenRouter API key
- Supabase service role key
- Platform API tokens
- Telegram bot token

## Emergency Procedures

### If Secrets Are Exposed

1. **Immediately** revoke the exposed key/token
2. Generate new credentials
3. Update Bitwarden
4. Update all services (Make.com, frontend, etc.)
5. Review git history and remove exposed secrets
6. Notify team if applicable

### Revoking Keys

- **OpenRouter**: https://openrouter.ai/keys → Delete key
- **Supabase**: Dashboard → Settings → API → Reset key
- **eBay**: Developer Console → Revoke token
- **Shopify**: Admin → Apps → Revoke access
- **Meta**: Business Manager → Revoke token
- **Telegram**: @BotFather → `/revoke`

## Best Practices

1. **Never hardcode secrets** in any code file
2. **Use environment variables** for all sensitive data
3. **Separate dev/prod secrets** - use different keys for development and production
4. **Limit scope** - use minimum required permissions for each API key
5. **Monitor usage** - regularly check API usage for anomalies
6. **Document everything** - keep Bitwarden notes up to date with key purposes and renewal dates

## Quick Reference

| Service | Renewal Period | Scope Required |
|---------|---------------|----------------|
| OpenRouter | 90 days | API access |
| Supabase | Never (unless exposed) | Full access |
| eBay | 18 months | Sell, Inventory, Fulfillment |
| Shopify | Never | Admin API |
| Meta | 60 days | ads_management, pages_manage_posts |
| Telegram | Never | Bot API |
