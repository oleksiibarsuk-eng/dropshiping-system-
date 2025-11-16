# AI AGENTS SPECIFICATION

## Overview

All agents use OpenRouter as the single entry point to LLM models with unified App Attribution headers:

**Required Headers:**
```
HTTP-Referer: https://finder-pan-43124036.figma.site
X-Title: Dropshipping AI Control Center
```

## Model Strategy

### Primary Models

1. **GPT-4o (`openai/gpt-4o`)** - Core Reasoning & Generation
   - Complex decision making
   - Content generation (listings, descriptions)
   - Strategic planning
   - High-value tasks

2. **GPT-4.1-mini (`openai/gpt-4.1-mini`)** - Fast Checks & Classification
   - Quick validation
   - Sanity checks
   - Classification tasks
   - Price/margin verification
   - Cost-effective operations

3. **Claude 3.5 Sonnet (`anthropic/claude-3.5-sonnet`)** - Compliance & Deep Review
   - Policy compliance review
   - Risk analysis
   - Complex compliance cases
   - Deep content analysis

### Validation Pipeline

Standard 3-layer validation for critical operations:

1. **Layer 1 (GPT-4o)**: Generate initial decision/content
2. **Layer 2 (GPT-4.1-mini)**: Sanity check and basic validation
3. **Layer 3 (Claude)**: Compliance and risk review (triggered for high-risk items)

---

## Agent Specifications

### 1. Planner Agent

**Purpose**: Task orchestration and daily planning

**Models**: GPT-4o (primary) + GPT-4.1-mini (validation)

**Responsibilities**:
- Create daily task queue based on business priorities
- Coordinate execution across other agents
- Optimize task scheduling for efficiency
- Balance workload across agents
- Monitor overall system health

**Input**:
```json
{
  "date": "2025-11-16",
  "current_inventory": 156,
  "pending_orders": 12,
  "agent_statuses": {},
  "business_rules": {}
}
```

**Output**:
```json
{
  "daily_plan": [
    {
      "agent": "Multi-Sourcing Agent",
      "task": "Source 20 new Sony products",
      "priority": "HIGH",
      "estimated_time": "2 hours"
    }
  ],
  "priorities": ["orders", "sourcing", "repricing"],
  "alerts": []
}
```

**Make Scenario**: `Dropshipping / AI Agents / Planner Orchestration`

---

### 2. Multi-Sourcing Agent

**Purpose**: Product discovery and supplier comparison

**Models**: GPT-4o (analysis) + GPT-4.1-mini (quick checks) + Claude (supplier risk)

**Responsibilities**:
- Search eBay.de for profitable products
- Compare multiple suppliers for same product
- Calculate profitability with all fees
- Assess supplier reliability
- Flag high-risk suppliers

**Input**:
```json
{
  "search_query": "Sony A7 IV",
  "target_margin": 25,
  "max_results": 10
}
```

**Output**:
```json
{
  "products": [
    {
      "title": "Sony A7 IV Body",
      "supplier": "CameraStore Munich",
      "cost_price": 2299.00,
      "suggested_price": 2999.00,
      "margin_percent": 23.4,
      "supplier_reliability": 0.95,
      "risk_level": "LOW"
    }
  ],
  "recommendations": [],
  "risks": []
}
```

**Make Scenario**: `Dropshipping / AI Agents / Multi-Sourcing Orchestration`

---

### 3. Compliance Agent

**Purpose**: Pre-publication policy validation

**Models**: GPT-4.1-mini (initial scan) + Claude (deep review)

**Responsibilities**:
- Check listings against platform policies (eBay/Shopify/Meta)
- Detect prohibited keywords and content
- Verify trademark compliance
- Flag high-risk categories
- Suggest compliant alternatives

**Input**:
```json
{
  "platform": "eBay",
  "title": "Sony A7 IV Camera Body",
  "description": "Brand new camera...",
  "category": "Cameras & Photo",
  "price": 2999.00
}
```

**Output**:
```json
{
  "verdict": "ALLOW",
  "confidence": 0.95,
  "issues": [],
  "suggested_changes": [],
  "risk_level": "LOW",
  "compliance_rules_checked": 15
}
```

**Possible Verdicts**:
- `ALLOW`: Safe to publish
- `ALLOW_WITH_CHANGES`: Publish with suggested modifications
- `BLOCK`: Violates policies, cannot publish
- `NEEDS_MANUAL_REVIEW`: Complex case requiring human review

**Make Scenario**: `Dropshipping / AI Agents / Compliance Orchestration`

---

### 4. Listing Agent

**Purpose**: SEO-optimized listing creation

**Models**: GPT-4o (generation) + GPT-4.1-mini (validation)

**Responsibilities**:
- Generate compelling product titles
- Write detailed, SEO-optimized descriptions
- Create relevant tags and keywords
- Ensure platform-specific formatting
- Optimize for search visibility

**Input**:
```json
{
  "product": {
    "brand": "Sony",
    "model": "A7 IV",
    "category": "Mirrorless Camera",
    "features": ["45MP", "4K Video", "5-axis IBIS"]
  },
  "platform": "eBay",
  "target_audience": "Professional photographers"
}
```

**Output**:
```json
{
  "title": "Sony A7 IV 33MP Full Frame Mirrorless Camera Body - 4K Video, 5-Axis IBIS",
  "description": "<detailed HTML description>",
  "seo_tags": ["sony camera", "mirrorless", "full frame", "4k video"],
  "bullet_points": [
    "33MP Full-Frame Exmor R Sensor",
    "4K 60p Video Recording"
  ],
  "completeness_score": 0.92
}
```

**Make Scenario**: `Dropshipping / AI Agents / Listing Orchestration`

---

### 5. Pricing Agent

**Purpose**: Dynamic pricing with margin protection

**Models**: GPT-4o (strategy) + GPT-4.1-mini (quick checks)

**Responsibilities**:
- Calculate optimal prices for maximum margin
- Monitor competitor prices
- Adjust prices based on market conditions
- Protect minimum margin thresholds
- Flag unusual price changes for review

**Input**:
```json
{
  "product_id": "uuid",
  "current_price": 2999.00,
  "cost_price": 2299.00,
  "minimal_margin": 20,
  "competitor_prices": [2899, 3099, 2950],
  "market_conditions": "stable"
}
```

**Output**:
```json
{
  "recommended_price": 2949.00,
  "expected_margin": 22.0,
  "reasoning": "Competitive positioning below average",
  "price_change_percent": -1.67,
  "needs_review": false,
  "confidence": 0.88
}
```

**Price Change Rules**:
- Change > 30% → `NEEDS_REVIEW`
- Price < 50% market avg → `NEEDS_REVIEW`
- Price > 200% market avg → `NEEDS_REVIEW`
- Margin < minimal_margin → BLOCK

**Make Scenario**: `Dropshipping / AI Agents / Pricing Orchestration`

---

### 6. Ops Agent

**Purpose**: Order fulfillment and error handling

**Models**: GPT-4.1-mini (primary) + GPT-4o (complex cases)

**Responsibilities**:
- Process order notifications
- Auto-purchase from suppliers
- Update tracking information
- Handle fulfillment errors
- Monitor integration health

**Input**:
```json
{
  "order_id": "uuid",
  "platform": "eBay",
  "product_id": "uuid",
  "customer_email": "customer@example.com"
}
```

**Output**:
```json
{
  "action": "FULFILL",
  "supplier_order_id": "ebay-12345",
  "tracking_number": "1Z999AA10123456784",
  "estimated_delivery": "2025-11-23",
  "status": "SUCCESS"
}
```

**Make Scenario**: `Dropshipping / Core / 04. Orders Fulfillment`

---

### 7. Reputation Agent

**Purpose**: Customer service and review monitoring

**Models**: GPT-4o (responses) + GPT-4.1-mini (sentiment)

**Responsibilities**:
- Monitor customer reviews
- Analyze sentiment and feedback
- Draft professional responses
- Identify reputation risks
- Suggest proactive actions

**Input**:
```json
{
  "platform": "eBay",
  "review": {
    "rating": 4,
    "comment": "Good camera but shipping was slow",
    "reviewer": "john_doe"
  }
}
```

**Output**:
```json
{
  "sentiment": "MIXED",
  "sentiment_score": 0.65,
  "issues": ["shipping_delay"],
  "suggested_response": "Thank you for your feedback...",
  "action_items": ["Review shipping times with supplier"],
  "reputation_impact": "LOW"
}
```

**Make Scenario**: `Dropshipping / AI Agents / Reputation Orchestration`

---

### 8. Analytics Agent

**Purpose**: Business intelligence and reporting

**Models**: GPT-4o (insights) + GPT-4.1-mini (calculations)

**Responsibilities**:
- Generate daily/weekly/monthly reports
- Analyze sales trends
- Monitor LLM usage and costs
- Identify optimization opportunities
- Create actionable insights

**Input**:
```json
{
  "period": "daily",
  "date": "2025-11-16",
  "metrics": {
    "revenue": 2845.50,
    "orders": 18,
    "margin": 25.4
  }
}
```

**Output**:
```json
{
  "summary": "Strong day with 18 orders...",
  "insights": [
    "Sony products performing 23% above average",
    "Margin trending 2.1% above target"
  ],
  "recommendations": [
    "Increase inventory for Sony A7 series",
    "Review pricing for Canon products"
  ],
  "alerts": []
}
```

**Make Scenario**: `Dropshipping / AI Agents / Analytics Orchestration`

---

## Task Status Flow

All agent tasks follow this status flow:

```
PENDING → IN_PROGRESS → SUCCESS
                      → NEEDS_REVIEW → APPROVED → SUCCESS
                                    → REJECTED → FAILED
                      → FAILED
```

**Status Definitions**:
- `PENDING`: Task queued, not started
- `IN_PROGRESS`: Agent is processing
- `SUCCESS`: Completed successfully
- `NEEDS_REVIEW`: Requires human approval
- `FAILED`: Error occurred
- `APPROVED`: Human approved the task
- `REJECTED`: Human rejected the task

## Logging and Monitoring

All agent tasks are logged to `agents_tasks` table with:
- Input/output data
- LLM model used
- Token usage and cost
- Execution time
- Success/failure status
- Review requirements

## Cost Optimization

**Model Selection Strategy**:
1. Try GPT-4.1-mini first for simple tasks
2. Escalate to GPT-4o for complex reasoning
3. Use Claude only for compliance deep-review
4. Cache common prompts when possible
5. Monitor costs via Analytics Agent

**Expected Cost per Task**:
- Mini: $0.001 - $0.01
- GPT-4o: $0.02 - $0.10
- Claude: $0.03 - $0.15

**Daily Cost Budget**: ~$50-100 for 200-500 tasks
