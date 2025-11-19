# 01. Infrastructure Health Check - Make.com Scenario

## Purpose
Monitor all integrations and services to ensure system health and alert on failures.

## Trigger
**Schedule**: Every 15 minutes

## Checks

### 1. Supabase Connection
```
GET {{SUPABASE_URL}}/rest/v1/
Expected: 200 OK
```

### 2. OpenRouter API
```
GET https://openrouter.ai/api/v1/models
Expected: 200 OK, models list
```

### 3. eBay API (US & DE)
```
GET /sell/account/v1/privilege
Expected: 200 OK
```

### 4. Shopify API
```
GET /admin/api/2024-01/shop.json
Expected: 200 OK, shop data
```

### 5. Telegram Bot
```
GET /bot{{TOKEN}}/getMe
Expected: 200 OK
```

## Actions

**All Healthy**: Log success, no alert

**Any Failure**:
- Log to `errors` table
- Send Telegram alert
- Retry after 5 minutes
- If still failing, escalate

## Alert Format
```
🚨 INFRASTRUCTURE ALERT

Service: {{service_name}}
Status: {{status_code}}
Error: {{error_message}}
Last Success: {{last_success_time}}

Action Required: Check service status
```
