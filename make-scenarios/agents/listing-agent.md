# Listing Agent - Make.com Scenario

## Purpose

Generate SEO-optimized, compelling product listings with titles, descriptions, and tags tailored for each platform (eBay, Shopify, Meta).

## Trigger

**Webhook**: Triggered when product status changes to `APPROVED`  
**Or**: Scheduled batch processing every 2 hours

## Scenario Flow

### 1. Fetch Products Ready for Listing

**Module**: HTTP - Supabase Query
- **URL**: `GET /rest/v1/products?status=eq.APPROVED&select=*,product_suppliers(supplier_id,suppliers(*))`
- **Purpose**: Get all approved products without listings

### 2. For Each Product - Generate Platform-Specific Listings

**Module**: Iterator (for each product)

### 3. Generate Listing with GPT-4o

**Module**: HTTP - OpenRouter
- **Model**: `openai/gpt-4o`

**System Prompt**:
```
You are an expert e-commerce copywriter specializing in camera equipment. Create compelling, SEO-optimized product listings that:
- Attract professional photographers
- Highlight key technical specifications
- Build trust and credibility
- Comply with platform policies
- Maximize search visibility
- Drive conversions

Always be accurate - never invent specifications or features.
```

**User Prompt**:
```
Create a listing for {{platform}} marketplace:

=== PRODUCT DATA ===
Brand: {{brand}}
Model: {{title}}
Category: {{category}}
Cost: ${{cost_price}}
Selling Price: ${{selling_price}}
Source Description: {{description}}

=== PLATFORM REQUIREMENTS ===

{{#if platform == 'eBay'}}
**eBay Listing Requirements:**
- Title: Max 80 characters, front-load keywords
- Description: HTML allowed, use structured format
- Item Specifics: Brand, Model, Type, Features
- SEO: Include "Free Shipping", "Fast Shipping" if applicable
- Format: Bullet points + detailed sections
{{/if}}

{{#if platform == 'Shopify'}}
**Shopify Product Requirements:**
- Title: Clear and descriptive, 60-70 characters optimal
- Description: Rich text, storytelling approach
- Tags: 10-15 relevant tags for collections
- SEO: Meta description (155 characters)
- Format: Narrative + specifications table
{{/if}}

{{#if platform == 'Meta'}}
**Facebook Marketplace Requirements:**
- Title: 100 characters, casual but clear
- Description: Conversational, 500-1000 characters
- Focus: Local appeal, fast shipping, reliability
- Format: Short paragraphs, easy to scan
{{/if}}

=== OUTPUT FORMAT ===

Generate complete listing in JSON:
{
  "title": "SEO-optimized title",
  "description_html": "<p>HTML description</p>",
  "description_plain": "Plain text version",
  "bullet_points": [
    "Key feature 1",
    "Key feature 2",
    "Key feature 3",
    "Key feature 4",
    "Key feature 5"
  ],
  "seo_tags": ["keyword1", "keyword2", ...],
  "meta_description": "155-char SEO description",
  "item_specifics": {
    "Brand": "Sony",
    "Model": "A7 IV",
    "Type": "Mirrorless Camera",
    "Megapixels": "33MP"
  },
  "shipping_info": "Fast shipping from US warehouse",
  "return_policy": "30-day money-back guarantee",
  "completeness_score": 0-100,
  "quality_score": 0-100
}
```

### 4. Validate with GPT-4.1-mini

**Module**: HTTP - OpenRouter
- **Model**: `openai/gpt-4.1-mini`

**Prompt**:
```
Validate this product listing:

{{gpt4o_output}}

Check for:
1. **Title Quality**:
   - Length within platform limits
   - Keywords front-loaded
   - Clear and descriptive
   - No prohibited words

2. **Description Quality**:
   - Accurate information
   - No exaggerated claims
   - Clear formatting
   - Call-to-action present

3. **SEO Optimization**:
   - Relevant keywords included
   - Natural language (not keyword stuffing)
   - Meta description optimized

4. **Completeness**:
   - All required fields present
   - Item specifics filled
   - Shipping info clear
   - Return policy stated

5. **Compliance**:
   - No prohibited language
   - No misleading claims
   - Trademark usage correct

Output JSON:
{
  "validation_passed": true/false,
  "issues": [
    {
      "field": "title",
      "issue": "Too long (85 chars, max 80)",
      "severity": "HIGH"
    }
  ],
  "suggestions": [
    {
      "field": "description",
      "suggestion": "Add battery life information",
      "priority": "MEDIUM"
    }
  ],
  "scores": {
    "seo_score": 0-100,
    "completeness_score": 0-100,
    "compliance_score": 0-100,
    "overall_score": 0-100
  },
  "recommendation": "APPROVE|REVISE|REJECT"
}
```

### 5. Route Based on Validation

**Module**: Router

**A. APPROVE (score >= 85)**
- Proceed to compliance check

**B. REVISE (score 70-84)**
- Apply suggested changes automatically
- Re-validate
- Then proceed to compliance

**C. REJECT (score < 70)**
- Flag for manual review
- Log detailed issues
- Alert via Telegram

### 6. Compliance Check

**Module**: Webhook to Compliance Agent
- **URL**: `{{COMPLIANCE_AGENT_WEBHOOK}}`
- **Payload**:
```json
{
  "listing_data": "{{generated_listing}}",
  "product_id": "{{product_id}}",
  "platform": "{{platform}}"
}
```

- **Wait for Response**: Continue on ALLOW verdict

### 7. Create Listing in Database

**Module**: HTTP - Supabase Insert to `listings`

```json
{
  "product_id": "{{product_id}}",
  "platform": "{{platform}}",
  "title": "{{validated_title}}",
  "description": "{{description_html}}",
  "price": "{{selling_price}}",
  "quantity": 1,
  "status": "DRAFT",
  "seo_tags": "{{seo_tags}}",
  "created_at": "{{now()}}"
}
```

### 8. Generate Platform-Specific Variants

**Module**: Iterator (for each target platform: eBay, Shopify, Meta)

Repeat steps 3-7 for each platform with platform-specific optimizations.

### 9. Log Agent Task

**Module**: HTTP - Supabase Insert to `agents_tasks`

```json
{
  "agent_name": "Listing Agent",
  "task_type": "LISTING_CREATION",
  "entity_type": "product",
  "entity_id": "{{product_id}}",
  "status": "SUCCESS",
  "priority": "MEDIUM",
  "input_data": {
    "product": "{{product_data}}",
    "platforms": ["eBay", "Shopify", "Meta"]
  },
  "output_data": {
    "listings_created": "{{listings_count}}",
    "platforms": "{{platforms_array}}",
    "avg_quality_score": "{{avg_score}}"
  },
  "llm_model": "gpt-4o + gpt-4.1-mini",
  "llm_tokens_used": "{{total_tokens}}",
  "llm_cost": "{{total_cost}}",
  "completed_at": "{{now()}}"
}
```

### 10. Send Notification

**Module**: Telegram - Send Message

```
📝 Listing Created

Product: {{title}}
Platforms: {{platforms_list}}

Quality Scores:
• eBay: {{ebay_score}}/100
• Shopify: {{shopify_score}}/100
• Meta: {{meta_score}}/100

Status: {{compliance_status}}
Next: {{next_action}}
```

### 11. Error Handler

**Module**: Error Handler
- Log to `errors` table
- Retry once
- Alert if still fails

## Advanced Features

### Multi-Language Support

For international markets:
```
Generate listing in multiple languages:
- English (primary)
- German (for eBay.de)
- Spanish (for LatAm markets)
```

### Competitive Analysis

Check competitor listings:
- Analyze top 5 similar products
- Extract winning keywords
- Identify pricing strategies
- Learn from high-performing descriptions

### A/B Testing Titles

Generate 3 title variations:
```json
{
  "title_variations": [
    {
      "version": "A",
      "title": "Sony Alpha 7 IV 33MP Full Frame Mirrorless Camera Body",
      "style": "technical"
    },
    {
      "version": "B",
      "title": "Sony A7 IV Professional Mirrorless Camera - 4K Video & 33MP",
      "style": "benefit-focused"
    },
    {
      "version": "C",
      "title": "Sony A7 IV Body Only - Latest Model Full Frame Mirrorless",
      "style": "availability-focused"
    }
  ]
}
```

Test and track performance of each variant.

### Image Optimization

**Module**: HTTP - Image API
- Resize images for platform requirements
- Add watermark (optional)
- Compress for fast loading
- Generate thumbnails

### Rich Media Content

Generate:
- Feature comparison tables
- Size/compatibility charts
- Shipping information graphics
- Trust badges

## Testing

### Test Cases

1. **Standard Product**
   - Brand: Sony, Model: A7 IV
   - Expected: High-quality listing, score > 90

2. **Complex Product**
   - Many features, technical specs
   - Expected: Well-organized, clear sections

3. **Budget Product**
   - Lower price point
   - Expected: Value-focused messaging

4. **Bundle**
   - Camera + accessories
   - Expected: Clear item list, bundle savings highlighted

5. **Used/Refurbished**
   - Condition description critical
   - Expected: Honest condition statement, warranty info

## Quality Benchmarks

### Excellent Listing (90-100)
- ✅ Perfect SEO title
- ✅ Comprehensive description
- ✅ All item specifics filled
- ✅ Professional formatting
- ✅ Clear shipping/returns
- ✅ No compliance issues

### Good Listing (75-89)
- ✅ Good SEO title
- ✅ Decent description
- ✅ Most specifics filled
- ⚠️ Minor formatting improvements needed
- ✅ Shipping/returns present

### Needs Work (< 75)
- ⚠️ Title needs optimization
- ⚠️ Description incomplete
- ❌ Missing item specifics
- ❌ Poor formatting
- ⚠️ Vague shipping info

## Monitoring

### KPIs

- **Creation Rate**: 90%+ success
- **Quality Score**: Average 85+
- **Compliance Pass**: 95%+
- **Time per Listing**: < 45 seconds
- **Revision Rate**: < 15%

### Performance Tracking

```sql
SELECT 
  platform,
  AVG(quality_score) as avg_quality,
  COUNT(*) as total_listings,
  SUM(CASE WHEN status = 'APPROVED' THEN 1 ELSE 0 END) as approved
FROM listings
WHERE created_at > NOW() - INTERVAL '7 days'
GROUP BY platform
```

## Cost Estimate

**Per Listing** (3 platforms):
- GPT-4o: 3 × 1000 tokens × $0.03/1k = $0.09
- GPT-4.1-mini: 3 × 400 tokens × $0.0002/1k = $0.0002
- **Total**: ~$0.09/product

**Daily** (20 products): $1.80  
**Monthly** (600 products): $54

## Best Practices

1. **Know Your Audience**: Professional photographers vs hobbyists
2. **Use Power Words**: Professional, authentic, genuine, guaranteed
3. **Feature + Benefit**: "33MP sensor = stunning detail in every shot"
4. **Social Proof**: "Trusted by professionals worldwide"
5. **Urgency**: "Limited stock" (if true)
6. **Clear CTAs**: "Buy Now", "Add to Cart"
7. **Mobile-Friendly**: Short paragraphs, scannable format
8. **Seasonal**: Adjust messaging for holidays/events

## Platform-Specific Tips

### eBay
- Front-load keywords in title
- Use HTML for rich descriptions
- Include compatibility information
- Highlight "Free Shipping" in title if offered
- Add "Brand New" or "Sealed" for new items

### Shopify
- Tell a story in description
- Use lifestyle language
- Emphasize brand values
- Include size/compatibility charts
- Add customer review quotes (if available)

### Meta/Facebook Marketplace
- Conversational tone
- Emphasize local pickup or fast shipping
- Use simple language
- Include "Available now"
- Respond to common questions in description

## Notes

- Quality listings = higher conversion rates
- Invest time in first-time setup, then reuse templates
- Learn from high-performing listings
- Update seasonal keywords (holiday gifts, etc.)
- A/B test different approaches
- Keep descriptions honest - builds long-term trust
