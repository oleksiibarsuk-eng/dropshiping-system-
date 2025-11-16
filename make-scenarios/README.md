# Make.com Scenarios

## Overview

This directory contains templates and documentation for Make.com (formerly Integromat) scenarios that orchestrate the dropshipping automation.

## Scenario Structure

```
make-scenarios/
├── core/                    # Core infrastructure scenarios
│   ├── 01-infra-check.md
│   ├── 02-products-sync.md
│   ├── 03-listings-sync.md
│   ├── 04-orders-fulfillment.md
│   └── 05-notifications.md
└── agents/                  # AI agent orchestration
    ├── planner-agent.md
    ├── multi-sourcing-agent.md
    ├── compliance-agent.md
    ├── listing-agent.md
    ├── pricing-agent.md
    ├── ops-agent.md
    ├── reputation-agent.md
    └── analytics-agent.md
```

## Common Setup

### Required Connections

Create these connections in Make.com:

1. **Supabase** (HTTP)
   - Base URL: `https://your-project.supabase.co`
   - Headers:
     - `apikey`: Your Supabase anon key
     - `Authorization`: `Bearer {service_role_key}`

2. **OpenRouter** (HTTP)
   - Base URL: `https://openrouter.ai/api/v1`
   - Headers:
     - `Authorization`: `Bearer {api_key}`
     - `HTTP-Referer`: `https://finder-pan-43124036.figma.site`
     - `X-Title`: `Dropshipping AI Control Center`

3. **eBay API** (OAuth 2.0)
   - Follow eBay's OAuth flow
   - Required scopes: `https://api.ebay.com/oauth/api_scope/sell.inventory`

4. **Shopify** (HTTP)
   - Base URL: `https://your-store.myshopify.com/admin/api/2024-01`
   - Headers:
     - `X-Shopify-Access-Token`: Your access token

5. **Telegram** (Built-in)
   - Bot Token: From @BotFather

### Common Modules

#### OpenRouter Request Module

**HTTP Module Configuration**:
- Method: `POST`
- URL: `https://openrouter.ai/api/v1/chat/completions`
- Headers:
  ```json
  {
    "Authorization": "Bearer {{OPENROUTER_API_KEY}}",
    "HTTP-Referer": "https://finder-pan-43124036.figma.site",
    "X-Title": "Dropshipping AI Control Center",
    "Content-Type": "application/json"
  }
  ```
- Body:
  ```json
  {
    "model": "openai/gpt-4o",
    "messages": [
      {
        "role": "system",
        "content": "You are an AI agent for dropshipping automation."
      },
      {
        "role": "user",
        "content": "{{prompt}}"
      }
    ],
    "temperature": 0.7,
    "max_tokens": 2000
  }
  ```

#### Supabase Insert Module

**HTTP Module Configuration**:
- Method: `POST`
- URL: `https://your-project.supabase.co/rest/v1/{{table_name}}`
- Headers:
  ```json
  {
    "apikey": "{{SUPABASE_ANON_KEY}}",
    "Authorization": "Bearer {{SUPABASE_SERVICE_ROLE_KEY}}",
    "Content-Type": "application/json",
    "Prefer": "return=representation"
  }
  ```
- Body: `{{json_data}}`

#### Supabase Query Module

**HTTP Module Configuration**:
- Method: `GET`
- URL: `https://your-project.supabase.co/rest/v1/{{table_name}}?{{query_params}}`
- Headers: Same as Insert

## Scheduling

### Recommended Schedule

| Scenario | Frequency | Time (UTC) |
|----------|-----------|------------|
| Infra Check | Every 15 min | - |
| Products Sync | Every 2 hours | - |
| Listings Sync | Every 1 hour | - |
| Orders Fulfillment | Every 5 min | - |
| Planner Agent | Daily | 08:00 |
| Multi-Sourcing Agent | Every 4 hours | 00:00, 04:00, 08:00, 12:00, 16:00, 20:00 |
| Pricing Agent | Every 1 hour | - |
| Reputation Agent | Every 30 min | - |
| Analytics Agent | Daily | 23:00 |

## Error Handling

All scenarios should include error handling:

1. **Error Handler Module**:
   - Catch all errors
   - Log to Supabase `errors` table
   - Send critical alerts to Telegram

2. **Retry Logic**:
   - Max retries: 3
   - Delay: Exponential backoff (1s, 5s, 15s)

3. **Notifications**:
   - Critical errors: Immediate Telegram notification
   - Non-critical: Log to database, review daily

## Testing

### Test Each Scenario

1. **Run Once** - Verify basic functionality
2. **Check Logs** - Review Make.com execution logs
3. **Verify Database** - Check Supabase tables for correct data
4. **Test Error Cases** - Deliberately cause errors to test handling

### Test Data

Use test products with `TEST_` prefix in SKU:
```json
{
  "sku": "TEST_SONY_A7IV_001",
  "title": "TEST - Sony A7 IV Body",
  "cost_price": 2299.00
}
```

## Monitoring

### Scenario Health Check

Create a dashboard scenario that checks:
- Last execution time for each scenario
- Success/failure rate
- Average execution time
- Error trends

### Metrics to Track

1. **Execution Metrics**:
   - Total executions today
   - Success rate
   - Average duration
   - Error count

2. **Business Metrics**:
   - Products sourced
   - Listings created
   - Orders fulfilled
   - Compliance checks performed

3. **Cost Metrics**:
   - Make.com operations used
   - OpenRouter API cost
   - Total daily cost

## Deployment Checklist

Before going live:

- [ ] All connections configured and tested
- [ ] API keys from production (not development)
- [ ] All scenarios tested with real data
- [ ] Error handlers in place
- [ ] Telegram notifications working
- [ ] Schedules configured correctly
- [ ] Database tables exist and have proper indexes
- [ ] Backup/rollback plan documented
- [ ] Team trained on monitoring and intervention

## Troubleshooting

### Common Issues

1. **"Authentication failed"**
   - Check API keys in Bitwarden
   - Verify connection settings
   - Ensure tokens haven't expired

2. **"Rate limit exceeded"**
   - Reduce scenario frequency
   - Implement request queuing
   - Contact platform for limit increase

3. **"Database connection failed"**
   - Verify Supabase URL and keys
   - Check Supabase project status
   - Review database error logs

4. **"OpenRouter error"**
   - Check API key validity
   - Verify App Attribution headers
   - Review OpenRouter balance

### Support Resources

- Make.com Documentation: https://www.make.com/en/help
- Supabase Docs: https://supabase.com/docs
- OpenRouter Docs: https://openrouter.ai/docs
- eBay API Docs: https://developer.ebay.com/docs
- Shopify API Docs: https://shopify.dev/docs/api

## Example Scenario Files

See individual scenario markdown files in `core/` and `agents/` directories for detailed setup instructions.
