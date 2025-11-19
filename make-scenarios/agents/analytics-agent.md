# Analytics Agent - Make.com Scenario

## Purpose

Generate daily/weekly/monthly business intelligence reports with insights and recommendations.

## Trigger

**Schedule**: Daily at 23:00 UTC

## Scenario Flow

### 1. Collect Metrics

**SQL Queries**:
```sql
-- Daily metrics
SELECT 
  COUNT(*) as orders_count,
  SUM(total_amount) as revenue,
  SUM(profit_amount) as profit,
  AVG(profit_amount / total_amount * 100) as avg_margin
FROM orders
WHERE DATE(created_at) = CURRENT_DATE;

-- LLM usage
SELECT 
  llm_model,
  SUM(llm_tokens_used) as total_tokens,
  SUM(llm_cost) as total_cost,
  COUNT(*) as call_count
FROM agents_tasks
WHERE DATE(created_at) = CURRENT_DATE
GROUP BY llm_model;

-- Top products
SELECT p.title, COUNT(o.id) as sales, SUM(o.profit_amount) as profit
FROM orders o
JOIN listings l ON o.listing_id = l.id
JOIN products p ON l.product_id = p.id
WHERE DATE(o.created_at) = CURRENT_DATE
GROUP BY p.id
ORDER BY profit DESC
LIMIT 10;
```

### 2. Generate Insights with GPT-4o

**Prompt**:
```
Analyze today's business metrics:

=== SALES ===
Orders: {{orders_count}}
Revenue: ${{revenue}}
Profit: ${{profit}}
Margin: {{avg_margin}}%

=== LLM COSTS ===
{{llm_usage_table}}

=== TOP PRODUCTS ===
{{top_products_table}}

=== AGENT PERFORMANCE ===
{{agent_stats}}

Generate insights:
1. Performance summary
2. Trends vs yesterday/last week
3. Opportunities identified
4. Risks/concerns
5. Actionable recommendations

Output JSON with summary, insights, recommendations, alerts.
```

### 3. Validate Calculations with GPT-4.1-mini

Quick math check on all calculations

### 4. Store Analytics Snapshot

**Insert to `analytics_snapshots` table**

### 5. Generate Report

**Format**:
- PDF report (optional)
- Telegram message (daily)
- Email digest (weekly)
- Dashboard update

### 6. Send Daily Summary

**Telegram**:
```
📊 Daily Report - {{date}}

💰 REVENUE: ${{revenue}} ({{vs_yesterday}})
📈 PROFIT: ${{profit}} ({{margin}}% margin)
📦 ORDERS: {{orders_count}}

🤖 AI COSTS: ${{llm_total_cost}}
• GPT-4o: ${{gpt4o_cost}}
• Mini: ${{mini_cost}}
• Claude: ${{claude_cost}}

⭐ TOP SELLER: {{top_product}} (${{top_profit}})

{{#if alerts}}
⚠️ ALERTS:
{{#each alerts}}
• {{this}}
{{/each}}
{{/if}}

💡 RECOMMENDATION: {{main_recommendation}}
```

## Advanced Features

### Trend Analysis

Compare metrics week-over-week:
- Revenue growth rate
- Margin trends
- Product performance
- Cost efficiency

### Forecasting

Predict next month:
- Expected revenue
- Inventory needs
- Budget requirements

### Cost Optimization

Identify:
- High-cost, low-value agents
- Expensive LLM calls
- Optimization opportunities

## Monitoring

- Report generation success rate
- Data accuracy
- Insight relevance
- Action taken on recommendations

## Cost: ~$0.15/day
