# Compliance Agent - Make.com Scenario

## Purpose

Pre-publication validation of listings against eBay, Shopify, and Meta policies to prevent policy violations, account suspensions, and legal issues.

## Trigger

**Webhook**: Triggered when new listing is created or updated  
**Or**: Manual trigger for batch compliance check

## Scenario Flow

### 1. Receive Listing Data

**Module**: Webhook Receiver
- **URL**: `https://hook.eu1.make.com/xxx`
- **Expected Payload**:
```json
{
  "listing_id": "uuid",
  "product_id": "uuid",
  "platform": "eBay|Shopify|Meta",
  "title": "Sony Alpha 7 IV Camera Body",
  "description": "Full product description...",
  "category": "Cameras & Photo",
  "price": 2999.00,
  "images": ["url1", "url2"]
}
```

### 2. Fetch Compliance Rules

**Module**: HTTP - Supabase Query
- **URL**: `GET /rest/v1/compliance_rules?platform=eq.{{platform}}&is_active=eq.true`
- **Purpose**: Get all active compliance rules for the platform

**Response**:
```json
[
  {
    "rule_type": "PROHIBITED_KEYWORD",
    "keyword": "replica",
    "severity": "HIGH",
    "action": "BLOCK"
  },
  {
    "rule_type": "HIGH_RISK_KEYWORD",
    "keyword": "gray market",
    "severity": "MEDIUM",
    "action": "REVIEW"
  }
]
```

### 3. Quick Scan with GPT-4.1-mini

**Module**: HTTP - OpenRouter
- **Model**: `openai/gpt-4.1-mini`
- **Purpose**: Fast initial scan for obvious violations

**Prompt**:
```
Quick compliance scan for {{platform}} listing:

Title: {{title}}
Description: {{description}}
Category: {{category}}
Price: ${{price}}

Check against these rules:
{{#each compliance_rules}}
- {{this.rule_type}}: "{{this.keyword}}" ({{this.action}})
{{/each}}

Platform-specific checks:
{{#if platform == 'eBay'}}
- VeRO violations (trademarks, copyright)
- Prohibited items policy
- Authenticity guarantees required
{{/if}}
{{#if platform == 'Shopify'}}
- Prohibited products
- Payment policy compliance
- GDPR/privacy compliance
{{/if}}
{{#if platform == 'Meta'}}
- Commerce policies
- Community standards
- Restricted content
{{/if}}

Output JSON:
{
  "quick_scan_result": "PASS|FLAG|BLOCK",
  "violations_found": [],
  "risk_score": 0-100,
  "needs_deep_review": boolean,
  "issues": [
    {
      "type": "PROHIBITED_KEYWORD",
      "keyword": "replica",
      "location": "description",
      "severity": "HIGH"
    }
  ]
}
```

### 4. Deep Review with Claude (if flagged)

**Module**: Router → only if `needs_deep_review: true`

**HTTP - OpenRouter**:
- **Model**: `anthropic/claude-3.5-sonnet`
- **Purpose**: Comprehensive compliance analysis

**Prompt**:
```
Perform deep compliance review for this {{platform}} listing:

=== LISTING DATA ===
Title: {{title}}
Description: {{description}}
Category: {{category}}
Price: ${{price}}
Images: {{images}}

=== INITIAL SCAN RESULTS ===
{{quick_scan_output}}

=== COMPLIANCE REQUIREMENTS ===

**eBay Policies:**
1. Authenticity Guarantee: Camera equipment >$500 may require
2. VeRO Program: Check trademark usage
3. Prohibited Items: Counterfeit, replica, gray market must be clearly disclosed
4. Item Specifics: Must include brand, model, condition
5. Returns: Must offer 30-day returns for most electronics

**Shopify Policies:**
1. Prohibited Products: No counterfeit items
2. Product Descriptions: Must be accurate, not misleading
3. Pricing: No false discount claims
4. Intellectual Property: No unauthorized brand usage

**Meta Commerce Policies:**
1. Restricted Content: Authentic products only
2. Clear Descriptions: Accurate condition statements
3. Realistic Pricing: No inflated original prices
4. Prohibited Content: No misleading claims

=== YOUR TASK ===

Analyze this listing thoroughly:

1. **Keyword Analysis**: Check every word for policy violations
2. **Image Review**: Describe what's shown, check for watermarks
3. **Pricing Analysis**: Is price realistic? Any discount claims?
4. **Claims Validation**: Any warranty, authenticity, or performance claims?
5. **Legal Risks**: Trademark issues, copyright, gray market
6. **Category Fit**: Is category correct per platform rules?

Output detailed JSON:
{
  "verdict": "ALLOW|ALLOW_WITH_CHANGES|BLOCK|NEEDS_MANUAL_REVIEW",
  "confidence": 0.0-1.0,
  "risk_level": "LOW|MEDIUM|HIGH|CRITICAL",
  "violations": [
    {
      "rule": "Prohibited keyword: replica",
      "severity": "HIGH",
      "location": "description, paragraph 2",
      "platform_rule": "eBay Policy #1234",
      "action_required": "BLOCK"
    }
  ],
  "warnings": [
    {
      "issue": "No return policy stated",
      "severity": "MEDIUM",
      "recommendation": "Add 30-day return policy"
    }
  ],
  "suggested_changes": [
    {
      "field": "title",
      "current": "Replica Sony A7 IV",
      "suggested": "Sony A7 IV Compatible Accessories",
      "reason": "Remove prohibited word 'replica'"
    }
  ],
  "legal_concerns": [],
  "requires_manual_review": boolean,
  "review_reason": "High-value item requires human verification",
  "estimated_resolution_time": "5-10 minutes"
}
```

### 5. Determine Final Verdict

**Module**: Switch/Router based on verdict

**Outcomes**:

**A. ALLOW (Green Light)**
- Update listing status to `APPROVED`
- No further action needed
- Log to database

**B. ALLOW_WITH_CHANGES (Yellow Light)**
- Create task for Listing Agent to apply changes
- Update listing with suggested changes automatically
- Flag for quick review
- Log changes made

**C. BLOCK (Red Light)**
- Update listing status to `BLOCKED`
- Create `NEEDS_REVIEW` task for human
- Send immediate Telegram alert
- Log detailed violation

**D. NEEDS_MANUAL_REVIEW (Orange Light)**
- Update listing status to `NEEDS_REVIEW`
- Assign to review queue
- Send Telegram notification
- Log reason for review

### 6. Update Database

**Module**: HTTP - Supabase Insert/Update

**Update `listings` table**:
```json
{
  "id": "{{listing_id}}",
  "status": "{{verdict_status}}",
  "updated_at": "{{now()}}"
}
```

**Insert to `compliance_issues` table**:
```json
{
  "entity_type": "listing",
  "entity_id": "{{listing_id}}",
  "rule_id": "{{matched_rule_id}}",
  "verdict": "{{verdict}}",
  "issues": "{{violations}}",
  "suggested_changes": "{{suggested_changes}}",
  "is_resolved": false
}
```

**Insert to `agents_tasks` table**:
```json
{
  "agent_name": "Compliance Agent",
  "task_type": "COMPLIANCE_CHECK",
  "entity_type": "listing",
  "entity_id": "{{listing_id}}",
  "status": "{{verdict == 'ALLOW' ? 'SUCCESS' : 'NEEDS_REVIEW'}}",
  "priority": "{{severity == 'HIGH' ? 'HIGH' : 'MEDIUM'}}",
  "input_data": {
    "listing": "{{listing_data}}",
    "platform": "{{platform}}"
  },
  "output_data": {
    "verdict": "{{verdict}}",
    "violations": "{{violations}}",
    "risk_level": "{{risk_level}}"
  },
  "llm_model": "gpt-4.1-mini + claude-3.5-sonnet",
  "llm_tokens_used": "{{total_tokens}}",
  "llm_cost": "{{total_cost}}",
  "needs_review": "{{verdict != 'ALLOW'}}",
  "review_reason": "{{review_reason}}",
  "completed_at": "{{now()}}"
}
```

### 7. Send Notifications

**Module**: Switch based on severity

**HIGH Severity (BLOCK)**:
```
🚨 COMPLIANCE ALERT

Listing BLOCKED: {{title}}
Platform: {{platform}}
Reason: {{primary_violation}}

Violations:
{{#each violations}}
• {{this.rule}} ({{this.severity}})
{{/each}}

Action Required: Manual review
```

**MEDIUM Severity (NEEDS_REVIEW)**:
```
⚠️ Compliance Review Required

Listing: {{title}}
Platform: {{platform}}
Status: Needs Manual Review

Concerns:
{{#each warnings}}
• {{this.issue}}
{{/each}}

Review at: https://dashboard/tasks/{{task_id}}
```

**LOW Severity (ALLOW_WITH_CHANGES)**:
```
✅ Compliance Check: Auto-Fixed

Listing: {{title}}
Changes Applied:
{{#each suggested_changes}}
• {{this.field}}: {{this.suggested}}
{{/each}}
```

### 8. Error Handler

**Module**: Error Handler
- Log error to `errors` table
- Default to BLOCK (fail-safe)
- Alert admin immediately
- Retry once after 30 seconds

## Advanced Features

### Image Compliance Check

**Module**: HTTP - OpenRouter with Vision
- **Model**: `openai/gpt-4o` (with vision)
- Check images for:
  - Watermarks from other sellers
  - Stock photos (reverse image search)
  - Misleading representations
  - NSFW content

### Trademark Verification

**Module**: HTTP - External API
- Check USPTO database
- Verify brand authorization
- Flag potential VeRO violations

### Historical Violation Tracking

```sql
SELECT COUNT(*), rule_type 
FROM compliance_issues 
WHERE entity_type = 'listing' 
AND created_at > NOW() - INTERVAL '30 days'
GROUP BY rule_type
ORDER BY COUNT(*) DESC
```

## Testing

### Test Cases

1. **Clean Listing** (should ALLOW)
   - Title: "Sony A7 IV Camera Body - Brand New"
   - Description: Accurate, no prohibited words
   - Result: ALLOW

2. **Prohibited Keyword** (should BLOCK)
   - Title: "Replica Sony Camera"
   - Description: Contains "counterfeit"
   - Result: BLOCK

3. **Gray Market** (should NEEDS_REVIEW)
   - Title: "Sony A7 IV Gray Market Import"
   - Description: "No US warranty"
   - Result: NEEDS_REVIEW

4. **Missing Information** (should ALLOW_WITH_CHANGES)
   - Title: "Camera"
   - Description: Vague
   - Result: ALLOW_WITH_CHANGES (add specifics)

5. **High-Value Item** (should NEEDS_REVIEW)
   - Price: $8,999
   - Result: NEEDS_REVIEW (manual verification)

## Monitoring

### KPIs

- **Approval Rate**: 70-80% ALLOW
- **Block Rate**: < 5%
- **Review Rate**: 15-25%
- **False Positive Rate**: < 3%
- **Processing Time**: < 30 seconds

### Quality Metrics

Track accuracy:
```sql
SELECT 
  verdict,
  COUNT(*) as total,
  AVG(CASE WHEN reviewed_by IS NOT NULL THEN 
    CASE WHEN verdict = manual_verdict THEN 1 ELSE 0 END
  END) as accuracy
FROM compliance_issues
WHERE created_at > NOW() - INTERVAL '7 days'
GROUP BY verdict
```

## Cost Estimate

**Per Listing**:
- GPT-4.1-mini: 300 tokens × $0.0002/1k = $0.0001
- Claude (20% need deep review): 1500 tokens × $0.015/1k × 0.2 = $0.0045
- **Average**: ~$0.005/listing

**Daily** (50 listings): $0.25  
**Monthly** (1500 listings): $7.50

## Compliance Rules Management

### Adding New Rules

Insert via Supabase:
```sql
INSERT INTO compliance_rules (platform, rule_type, keyword, severity, action, description)
VALUES 
('eBay', 'PROHIBITED_KEYWORD', 'fake', 'HIGH', 'BLOCK', 'Fake items violate authenticity policy'),
('Shopify', 'HIGH_RISK_KEYWORD', 'limited warranty', 'MEDIUM', 'REVIEW', 'Warranty claims need verification');
```

### Updating Rules

```sql
UPDATE compliance_rules
SET is_active = false
WHERE keyword = 'outdated-term';
```

## Best Practices

1. **Conservative by Default**: When in doubt, flag for review
2. **Learn from Reviews**: Update rules based on manual review outcomes
3. **Platform-Specific**: Different rules for different platforms
4. **Regular Updates**: Review compliance rules monthly
5. **Documentation**: Log every decision for audit trail

## Notes

- Compliance is critical - one violation can suspend entire account
- Better to over-flag than under-flag
- Keep up with platform policy changes
- Claude is excellent at nuanced policy interpretation
- Always provide clear reasoning for decisions
