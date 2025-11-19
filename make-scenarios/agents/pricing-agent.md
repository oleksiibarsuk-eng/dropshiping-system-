# Pricing Agent - Make.com Scenario

## Purpose

Dynamic pricing optimization with margin protection, competitor monitoring, and market-responsive adjustments.

## Trigger

**Schedule**: Every 1 hour  
**Or**: Webhook on significant market changes

## Scenario Flow

### 1. Fetch Active Listings

**SQL**: Get all active listings with cost data
```sql
SELECT l.*, p.cost_price, p.minimal_margin_percent
FROM listings l
JOIN products p ON l.product_id = p.id
WHERE l.status = 'ACTIVE'
AND l.updated_at < NOW() - INTERVAL '1 hour'
```

### 2. Check Competitor Prices (eBay)

**HTTP - eBay API**: Search for same product
```
GET /buy/browse/v1/item_summary/search?q={{title}}&limit=10
```

### 3. Calculate Optimal Price with GPT-4o

**Prompt**:
```
Pricing strategy for:
Title: {{title}}
Current Price: ${{current_price}}
Cost: ${{cost_price}}
Min Margin: {{min_margin}}%
Competitor Prices: {{competitor_prices}}

Recommend new price considering:
- Margin protection (minimum {{min_margin}}%)
- Competitive positioning
- Market demand
- Price elasticity

Output: { "recommended_price": 0, "reasoning": "", "confidence": 0-1 }
```

### 4. Validate with GPT-4.1-mini

Quick sanity check:
- Price change < 30%
- Margin >= min_margin
- Within market range

### 5. Apply Price Update

**If approved**: Update listing price in database and marketplace

## Monitoring

- Track margin % across all listings
- Alert if any listing drops below threshold
- Monitor competitor price changes
- Track conversion rate by price point

## Cost: ~$0.02/listing/day
