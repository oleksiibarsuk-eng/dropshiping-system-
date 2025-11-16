# API Integrations Guide

Complete guide for integrating with eBay, Shopify, Meta, and other platforms.

## OpenRouter Integration

### Setup

```javascript
// Example HTTP request structure
const makeOpenRouterRequest = async (model, messages) => {
  const response = await fetch('https://openrouter.ai/api/v1/chat/completions', {
    method: 'POST',
    headers: {
      'Authorization': `Bearer ${OPENROUTER_API_KEY}`,
      'HTTP-Referer': 'https://finder-pan-43124036.figma.site',
      'X-Title': 'Dropshipping AI Control Center',
      'Content-Type': 'application/json'
    },
    body: JSON.stringify({
      model: model,
      messages: messages,
      temperature: 0.7,
      max_tokens: 2000
    })
  });
  
  return await response.json();
};
```

### Model Selection

```javascript
const getModelForTask = (taskType) => {
  const modelMap = {
    'COMPLEX_REASONING': 'openai/gpt-4o',
    'CONTENT_GENERATION': 'openai/gpt-4o',
    'QUICK_CHECK': 'openai/gpt-4.1-mini',
    'CLASSIFICATION': 'openai/gpt-4.1-mini',
    'COMPLIANCE': 'anthropic/claude-3.5-sonnet',
    'RISK_ANALYSIS': 'anthropic/claude-3.5-sonnet'
  };
  
  return modelMap[taskType] || 'openai/gpt-4.1-mini';
};
```

### Cost Tracking

```javascript
const calculateCost = (model, tokens) => {
  const pricing = {
    'openai/gpt-4o': { input: 0.005, output: 0.015 },
    'openai/gpt-4.1-mini': { input: 0.0001, output: 0.0004 },
    'anthropic/claude-3.5-sonnet': { input: 0.003, output: 0.015 }
  };
  
  const rate = pricing[model];
  // Simplified calculation (assumes 50/50 input/output)
  return ((tokens / 2) * rate.input + (tokens / 2) * rate.output) / 1000;
};
```

---

## eBay API Integration

### Authentication

eBay uses OAuth 2.0 with access tokens that expire every 2 hours.

**Initial Setup**:
1. Get authorization code: `https://auth.ebay.com/oauth2/authorize?client_id={CLIENT_ID}&response_type=code&redirect_uri={REDIRECT_URI}&scope=https://api.ebay.com/oauth/api_scope/sell.inventory`
2. Exchange for tokens:

```bash
curl -X POST 'https://api.ebay.com/identity/v1/oauth2/token' \
  -H 'Content-Type: application/x-www-form-urlencoded' \
  -H 'Authorization: Basic {BASE64(CLIENT_ID:CLIENT_SECRET)}' \
  -d 'grant_type=authorization_code&code={AUTH_CODE}&redirect_uri={REDIRECT_URI}'
```

**Refresh Token** (use in Make.com):
```bash
curl -X POST 'https://api.ebay.com/identity/v1/oauth2/token' \
  -H 'Content-Type: application/x-www-form-urlencoded' \
  -H 'Authorization: Basic {BASE64(CLIENT_ID:CLIENT_SECRET)}' \
  -d 'grant_type=refresh_token&refresh_token={REFRESH_TOKEN}'
```

### Search Products (eBay.de)

```bash
curl 'https://api.ebay.com/buy/browse/v1/item_summary/search?q=Sony+A7+IV&limit=50&filter=buyingOptions:{FIXED_PRICE}' \
  -H 'Authorization: Bearer {ACCESS_TOKEN}' \
  -H 'X-EBAY-C-MARKETPLACE-ID: EBAY_DE'
```

**Response**:
```json
{
  "itemSummaries": [
    {
      "itemId": "123456789",
      "title": "Sony Alpha 7 IV Body",
      "price": {
        "value": "2299.00",
        "currency": "EUR"
      },
      "seller": {
        "username": "camerastore-munich",
        "feedbackPercentage": "99.5"
      },
      "itemWebUrl": "https://www.ebay.de/itm/123456789"
    }
  ]
}
```

### Create Listing (eBay.com)

```bash
curl -X POST 'https://api.ebay.com/sell/inventory/v1/inventory_item/{SKU}' \
  -H 'Authorization: Bearer {ACCESS_TOKEN}' \
  -H 'Content-Type: application/json' \
  -d '{
    "product": {
      "title": "Sony Alpha 7 IV 33MP Mirrorless Camera Body",
      "description": "<p>Professional mirrorless camera...</p>",
      "imageUrls": ["https://..."],
      "aspects": {
        "Brand": ["Sony"],
        "Model": ["A7 IV"],
        "Type": ["Mirrorless"]
      }
    },
    "condition": "NEW",
    "availability": {
      "shipToLocationAvailability": {
        "quantity": 1
      }
    }
  }'
```

### Fulfill Order

```bash
# Get order details
curl 'https://api.ebay.com/sell/fulfillment/v1/order/{ORDER_ID}' \
  -H 'Authorization: Bearer {ACCESS_TOKEN}'

# Update tracking
curl -X POST 'https://api.ebay.com/sell/fulfillment/v1/order/{ORDER_ID}/shipping_fulfillment' \
  -H 'Authorization: Bearer {ACCESS_TOKEN}' \
  -H 'Content-Type: application/json' \
  -d '{
    "lineItems": [
      {
        "lineItemId": "{LINE_ITEM_ID}",
        "quantity": 1
      }
    ],
    "shippedDate": "2025-11-16T10:00:00.000Z",
    "shippingCarrierCode": "DHL",
    "trackingNumber": "1234567890"
  }'
```

---

## Shopify API Integration

### Authentication

Shopify uses access tokens (no expiration).

**Setup**:
1. Create private app in Shopify admin
2. Get Admin API access token
3. Use token in all requests

### Create Product

```bash
curl -X POST 'https://{STORE}.myshopify.com/admin/api/2024-01/products.json' \
  -H 'X-Shopify-Access-Token: {ACCESS_TOKEN}' \
  -H 'Content-Type: application/json' \
  -d '{
    "product": {
      "title": "Sony Alpha 7 IV Camera Body",
      "body_html": "<p>Professional mirrorless camera...</p>",
      "vendor": "Sony",
      "product_type": "Camera",
      "tags": ["camera", "mirrorless", "sony"],
      "variants": [
        {
          "price": "2999.00",
          "sku": "SONY-A7IV-BODY",
          "inventory_quantity": 1,
          "inventory_management": "shopify"
        }
      ],
      "images": [
        {
          "src": "https://..."
        }
      ]
    }
  }'
```

### Get Orders

```bash
curl 'https://{STORE}.myshopify.com/admin/api/2024-01/orders.json?status=open&limit=50' \
  -H 'X-Shopify-Access-Token: {ACCESS_TOKEN}'
```

### Fulfill Order

```bash
curl -X POST 'https://{STORE}.myshopify.com/admin/api/2024-01/orders/{ORDER_ID}/fulfillments.json' \
  -H 'X-Shopify-Access-Token: {ACCESS_TOKEN}' \
  -H 'Content-Type: application/json' \
  -d '{
    "fulfillment": {
      "location_id": {LOCATION_ID},
      "tracking_number": "1234567890",
      "tracking_company": "DHL",
      "notify_customer": true
    }
  }'
```

---

## Meta Business API Integration

### Authentication

Meta uses long-lived access tokens (60 days).

**Get Token**:
1. Go to https://developers.facebook.com/tools/explorer
2. Select your app
3. Generate token with permissions: `ads_management`, `pages_manage_posts`
4. Exchange for long-lived token:

```bash
curl 'https://graph.facebook.com/v18.0/oauth/access_token?grant_type=fb_exchange_token&client_id={APP_ID}&client_secret={APP_SECRET}&fb_exchange_token={SHORT_TOKEN}'
```

### Create Marketplace Listing

```bash
curl -X POST 'https://graph.facebook.com/v18.0/{PAGE_ID}/marketplace_listings' \
  -H 'Authorization: Bearer {ACCESS_TOKEN}' \
  -d 'title=Sony Alpha 7 IV Camera Body' \
  -d 'description=Professional mirrorless camera...' \
  -d 'price=2999.00' \
  -d 'currency=USD' \
  -d 'availability=IN_STOCK' \
  -d 'condition=NEW' \
  -d 'images[0][url]=https://...'
```

---

## Telegram Bot Integration

### Send Message

```bash
curl -X POST 'https://api.telegram.org/bot{BOT_TOKEN}/sendMessage' \
  -H 'Content-Type: application/json' \
  -d '{
    "chat_id": "{CHAT_ID}",
    "text": "🤖 New order received!\n\nProduct: Sony A7 IV\nAmount: $2999.00",
    "parse_mode": "Markdown"
  }'
```

### Send Photo with Caption

```bash
curl -X POST 'https://api.telegram.org/bot{BOT_TOKEN}/sendPhoto' \
  -F 'chat_id={CHAT_ID}' \
  -F 'photo=@/path/to/image.jpg' \
  -F 'caption=New listing created: Sony A7 IV'
```

---

## Rate Limits

| API | Rate Limit | Recommended Strategy |
|-----|-----------|---------------------|
| eBay | 5000/day | Cache results, batch operations |
| Shopify | 2/second | Queue requests, use bulk APIs |
| Meta | 200/hour | Implement backoff, monitor usage |
| OpenRouter | Varies by model | Track tokens, set budgets |
| Telegram | 30 msgs/second | Batch notifications |

---

## Error Handling

### Common Error Codes

**eBay**:
- `1001`: Invalid token → Refresh OAuth token
- `21916717`: Rate limit → Wait and retry
- `25002`: Invalid parameter → Check request format

**Shopify**:
- `429`: Too many requests → Implement throttling
- `402`: Payment required → Check Shopify plan
- `404`: Resource not found → Verify product/order IDs

**OpenRouter**:
- `401`: Invalid API key → Check Bitwarden
- `429`: Rate limit → Reduce frequency
- `402`: Insufficient credits → Add credits

### Retry Logic

```javascript
const retryWithBackoff = async (fn, maxRetries = 3) => {
  for (let i = 0; i < maxRetries; i++) {
    try {
      return await fn();
    } catch (error) {
      if (i === maxRetries - 1) throw error;
      const delay = Math.pow(2, i) * 1000; // Exponential backoff
      await new Promise(resolve => setTimeout(resolve, delay));
    }
  }
};
```

---

## Testing

### Sandbox Environments

- **eBay**: Use sandbox at `api.sandbox.ebay.com`
- **Shopify**: Create development store (free)
- **Meta**: Use test pages and test users
- **OpenRouter**: Start with mini models to reduce costs

### Test Checklist

- [ ] Authentication works
- [ ] Search/list products
- [ ] Create listings
- [ ] Process orders
- [ ] Error handling works
- [ ] Rate limits respected
- [ ] Costs within budget

---

## Monitoring

### Health Check Endpoints

Create Make.com scenario to check:
- eBay token validity (call `/user` endpoint)
- Shopify connection (call `/shop.json`)
- Meta token (call `/me`)
- OpenRouter balance (check dashboard)

Run every 15 minutes, alert on failures.

---

This covers all major integrations. For detailed API docs, see platform documentation links in each section.
