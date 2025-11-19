# Multi-Sourcing Agent - Make.com Scenario

## Purpose

Search and compare products from multiple suppliers (eBay.de, AliExpress, etc.) to find profitable arbitrage opportunities with optimal margins.

## Trigger

**Schedule**: Every 4 hours (00:00, 04:00, 08:00, 12:00, 16:00, 20:00 UTC)  
**Or**: Manual trigger via webhook

## Scenario Flow

### 1. Get Search Parameters

**Module**: HTTP - Supabase Query
- **URL**: `GET /rest/v1/rpc/get_sourcing_parameters`
- **Purpose**: Get current inventory needs, target categories, margin requirements

**SQL Function** (create in Supabase):
```sql
CREATE OR REPLACE FUNCTION get_sourcing_parameters()
RETURNS JSON AS $$
DECLARE
  result JSON;
BEGIN
  SELECT json_build_object(
    'target_brands', ARRAY['Sony', 'Canon', 'Fuji', 'Panasonic', 'Ricoh'],
    'min_margin_percent', 25,
    'max_products_per_run', 20,
    'current_product_count', (SELECT COUNT(*) FROM products),
    'low_stock_categories', (
      SELECT ARRAY_AGG(DISTINCT category) 
      FROM listings 
      WHERE quantity < 5 AND status = 'ACTIVE'
    )
  ) INTO result;
  RETURN result;
END;
$$ LANGUAGE plpgsql;
```

### 2. Search eBay.de for Products

**Module**: HTTP - eBay API Request
- **URL**: `GET https://api.ebay.com/buy/browse/v1/item_summary/search`
- **Headers**:
  - `Authorization`: Bearer {{EBAY_ACCESS_TOKEN}}
  - `X-EBAY-C-MARKETPLACE-ID`: EBAY_DE
- **Query Parameters**:
  ```
  q={{brand}} camera
  limit=50
  filter=buyingOptions:{FIXED_PRICE},price:[500..5000],priceCurrency:EUR
  ```

**Expected Response**:
```json
{
  "itemSummaries": [
    {
      "itemId": "123456",
      "title": "Sony Alpha 7 IV Gehäuse",
      "price": {"value": "2299.00", "currency": "EUR"},
      "seller": {
        "username": "camerastore-munich",
        "feedbackPercentage": "99.5"
      },
      "condition": "NEW",
      "itemWebUrl": "https://ebay.de/itm/123456"
    }
  ]
}
```

### 3. Analyze Each Product with GPT-4o

**Module**: Iterator (for each product) + HTTP - OpenRouter

**OpenRouter Request**:
- **Model**: `openai/gpt-4o`
- **Prompt**:
```
Analyze this product for dropshipping profitability:

Title: {{title}}
Cost Price: €{{price}}
Seller Rating: {{seller.feedbackPercentage}}%
Condition: {{condition}}
Category: Cameras & Photo

Calculate:
1. USD price conversion (use current rate ~1.10)
2. Recommended US selling price (25-30% margin)
3. Total fees estimate (eBay 13%, payment 3%, shipping $25)
4. Expected profit
5. Risk assessment (competition, demand, seasonality)

Output JSON:
{
  "cost_usd": 0,
  "suggested_price": 0,
  "total_fees": 0,
  "expected_profit": 0,
  "margin_percent": 0,
  "risk_level": "LOW|MEDIUM|HIGH",
  "recommendation": "ACCEPT|REVIEW|REJECT",
  "reasoning": "..."
}
```

### 4. Validate with GPT-4.1-mini

**Module**: HTTP - OpenRouter
- **Model**: `openai/gpt-4.1-mini`
- **Prompt**:
```
Quick validation of this product analysis:
{{gpt4o_output}}

Check for:
- Math errors in calculations
- Margin below 20% (flag as REJECT)
- Unrealistic pricing
- Missing critical data

Output: { "valid": true/false, "issues": [], "corrected_margin": 0 }
```

### 5. Supplier Risk Check with Claude

**Module**: HTTP - OpenRouter (only for products with recommendation: ACCEPT)
- **Model**: `anthropic/claude-3.5-sonnet`
- **Prompt**:
```
Assess supplier risk for this dropshipping product:

Seller: {{seller.username}}
Rating: {{seller.feedbackPercentage}}%
Feedback Score: {{seller.feedbackScore}}
Location: Germany (eBay.de)
Product: {{title}}

Evaluate:
1. Seller reliability (rating, feedback, account age)
2. Shipping risks (international, customs)
3. Product authenticity risks
4. Return/warranty complications
5. Long-term availability

Output JSON:
{
  "supplier_risk_level": "LOW|MEDIUM|HIGH",
  "reliability_score": 0.0-1.0,
  "concerns": [],
  "recommendations": [],
  "verdict": "APPROVED|NEEDS_REVIEW|REJECTED"
}
```

### 6. Insert Approved Products to Database

**Module**: Iterator + HTTP - Supabase Insert

**Filter**: Only products with:
- `recommendation`: ACCEPT
- `verdict`: APPROVED or NEEDS_REVIEW
- `margin_percent` >= 20

**Insert to `products` table**:
```json
{
  "sku": "EBAY_{{itemId}}",
  "title": "{{title}}",
  "description": "{{description}}",
  "category": "Cameras & Photo",
  "brand": "{{extracted_brand}}",
  "cost_price": "{{cost_usd}}",
  "selling_price": "{{suggested_price}}",
  "minimal_margin_percent": 20,
  "current_margin_percent": "{{margin_percent}}",
  "status": "{{verdict == 'APPROVED' ? 'DRAFT' : 'NEEDS_REVIEW'}}",
  "source_platform": "eBay.de",
  "source_url": "{{itemWebUrl}}",
  "image_urls": "{{images}}"
}
```

**Insert to `product_suppliers` table**:
```json
{
  "product_id": "{{product.id}}",
  "supplier_id": "{{get_or_create_supplier(seller)}}",
  "supplier_sku": "{{itemId}}",
  "supplier_price": "{{price.value}}",
  "is_primary": true
}
```

### 7. Log Agent Task

**Module**: HTTP - Supabase Insert to `agents_tasks`
```json
{
  "agent_name": "Multi-Sourcing Agent",
  "task_type": "PRODUCT_SOURCING",
  "status": "SUCCESS",
  "priority": "HIGH",
  "input_data": {
    "search_params": "{{sourcing_parameters}}",
    "products_searched": "{{total_products}}"
  },
  "output_data": {
    "products_found": "{{found_count}}",
    "products_approved": "{{approved_count}}",
    "products_needs_review": "{{review_count}}",
    "products_rejected": "{{rejected_count}}"
  },
  "llm_model": "gpt-4o + gpt-4.1-mini + claude-3.5-sonnet",
  "llm_tokens_used": "{{total_tokens}}",
  "llm_cost": "{{total_cost}}",
  "completed_at": "{{now()}}"
}
```

### 8. Send Telegram Notification

**Module**: Telegram - Send Message
```
🔍 Multi-Sourcing Complete

Found: {{found_count}} products
✅ Approved: {{approved_count}}
⚠️ Needs Review: {{review_count}}
❌ Rejected: {{rejected_count}}

Top opportunities:
{{#each top_3_products}}
• {{this.title}}
  Price: ${{this.suggested_price}}
  Margin: {{this.margin_percent}}%
{{/each}}
```

### 9. Error Handler

**Module**: Error Handler
- Log to `errors` table
- Send alert to Telegram
- Set task status to FAILED

## Advanced Features

### Competitive Price Check

After finding products, check US eBay for competition:

**Module**: HTTP - eBay US API
- Search for same product on eBay.com
- Compare prices
- Adjust suggested price if needed

### Historical Performance

Query past sales data:
```sql
SELECT AVG(profit_amount), COUNT(*) 
FROM orders 
WHERE listing_id IN (
  SELECT id FROM listings WHERE title ILIKE '%{{brand}} {{model}}%'
)
AND created_at > NOW() - INTERVAL '90 days'
```

## Testing

### Test Scenario

1. **Manual Run**: Execute once
2. **Check Database**: Verify products in `products` table
3. **Review Margins**: All products should have margin >= 20%
4. **Check Flags**: High-risk products should be `NEEDS_REVIEW`

### Test Cases

- ✅ Normal products (good margin, reliable seller)
- ✅ Low margin products (should be rejected)
- ✅ High-risk seller (should flag for review)
- ✅ High-value items >$3000 (should flag for review)
- ✅ API errors (eBay, OpenRouter)

## Monitoring

### Success Criteria

- Completes in < 10 minutes
- Finds 20+ products per run
- Approval rate 30-50%
- Average margin 25-30%
- < 10% error rate

### Common Issues

1. **"No products found"**
   - Check eBay search parameters
   - Verify marketplace ID is EBAY_DE
   - Try different keywords

2. **"All products rejected"**
   - Review margin thresholds
   - Check currency conversion rate
   - Verify fee calculations

3. **"API rate limit"**
   - Reduce search frequency
   - Batch requests
   - Use pagination

## Cost Estimate

**Per Execution** (50 products):
- GPT-4o: 50 × 500 tokens × $0.03/1k = $0.75
- GPT-4.1-mini: 50 × 200 tokens × $0.0002/1k = $0.002
- Claude: 20 × 800 tokens × $0.015/1k = $0.24
- **Total**: ~$1.00/run

**Daily** (6 runs): ~$6.00  
**Monthly**: ~$180

## Optimization Tips

1. **Cache Supplier Data**: Don't re-analyze same seller
2. **Batch Processing**: Group similar products
3. **Smart Filtering**: Pre-filter before LLM analysis
4. **Price Caching**: Store conversion rates for 1 hour
5. **Incremental Updates**: Only new products since last run

## Notes

- This is the most critical agent for business growth
- Quality over quantity - better to source 10 great products than 50 mediocre ones
- Always verify supplier before first order
- Monitor competitor prices weekly
- Adjust search parameters based on what sells
