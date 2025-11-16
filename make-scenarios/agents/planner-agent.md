# Planner Agent - Make.com Scenario

## Purpose

Daily task orchestration and planning. Creates optimized task queue for all other agents based on business priorities and current state.

## Trigger

**Schedule**: Daily at 08:00 UTC

## Scenario Flow

### 1. Fetch Current State

**Module**: HTTP - Supabase Query
- **URL**: `GET /rest/v1/rpc/get_system_state`
- **Purpose**: Get current inventory, pending orders, agent statuses

**SQL Function** (create in Supabase):
```sql
CREATE OR REPLACE FUNCTION get_system_state()
RETURNS JSON AS $$
DECLARE
  result JSON;
BEGIN
  SELECT json_build_object(
    'active_listings', (SELECT COUNT(*) FROM listings WHERE status = 'ACTIVE'),
    'pending_orders', (SELECT COUNT(*) FROM orders WHERE status = 'PENDING'),
    'products_count', (SELECT COUNT(*) FROM products),
    'low_stock_count', (SELECT COUNT(*) FROM listings WHERE quantity < 5),
    'pending_tasks', (SELECT COUNT(*) FROM agents_tasks WHERE status = 'PENDING'),
    'needs_review', (SELECT COUNT(*) FROM agents_tasks WHERE needs_review = TRUE)
  ) INTO result;
  RETURN result;
END;
$$ LANGUAGE plpgsql;
```

### 2. Call GPT-4o for Planning

**Module**: HTTP - OpenRouter Request
- **Model**: `openai/gpt-4o`
- **System Prompt**:
```
You are the Planner Agent for a dropshipping business. Your job is to create an optimized daily task plan.

Consider:
- Business priorities (orders > sourcing > optimization)
- Current system state
- Agent availability
- Time constraints

Output a structured JSON plan with tasks prioritized by urgency and impact.
```

- **User Prompt**:
```
Create today's task plan based on:
- Active listings: {{active_listings}}
- Pending orders: {{pending_orders}}
- Products in catalog: {{products_count}}
- Low stock items: {{low_stock_count}}
- Pending tasks: {{pending_tasks}}
- Tasks needing review: {{needs_review}}

Target for today:
- Source 20 new profitable products
- Repricecompetitive listings
- Ensure all orders are fulfilled
- Review all flagged tasks
```

### 3. Parse GPT-4o Response

**Module**: JSON Parse
- Extract `daily_plan` array

**Expected Response**:
```json
{
  "daily_plan": [
    {
      "agent": "Ops Agent",
      "task_type": "ORDER_FULFILLMENT",
      "priority": "HIGH",
      "estimated_time": "30 min",
      "reason": "12 pending orders require immediate fulfillment"
    },
    {
      "agent": "Multi-Sourcing Agent",
      "task_type": "PRODUCT_SOURCING",
      "priority": "HIGH",
      "target_count": 20,
      "estimated_time": "2 hours",
      "reason": "Inventory needs refresh"
    },
    {
      "agent": "Pricing Agent",
      "task_type": "PRICE_OPTIMIZATION",
      "priority": "MEDIUM",
      "target_listings": "all_active",
      "estimated_time": "1 hour",
      "reason": "Daily competitive price check"
    }
  ],
  "alerts": [
    "High number of pending orders - prioritize fulfillment"
  ]
}
```

### 4. Validate with GPT-4.1-mini

**Module**: HTTP - OpenRouter Request
- **Model**: `openai/gpt-4.1-mini`
- **Prompt**:
```
Validate this daily plan for sanity:
{{daily_plan_json}}

Check for:
- Logical task ordering
- Realistic time estimates
- No conflicting priorities
- All critical tasks included

Output: { "valid": true/false, "issues": [], "suggestions": [] }
```

### 5. Create Agent Tasks in Database

**Module**: Iterator + HTTP Insert (for each task in plan)
- **URL**: `POST /rest/v1/agents_tasks`
- **Body**:
```json
{
  "agent_name": "{{agent}}",
  "task_type": "{{task_type}}",
  "status": "PENDING",
  "priority": "{{priority}}",
  "input_data": {
    "plan": "{{task_details}}"
  },
  "created_at": "{{now()}}"
}
```

### 6. Log Planning Task

**Module**: HTTP - Supabase Insert
- **Table**: `agents_tasks`
- **Body**:
```json
{
  "agent_name": "Planner Agent",
  "task_type": "DAILY_PLANNING",
  "status": "SUCCESS",
  "priority": "HIGH",
  "input_data": {
    "system_state": "{{system_state}}"
  },
  "output_data": {
    "daily_plan": "{{daily_plan}}"
  },
  "llm_model": "openai/gpt-4o",
  "llm_tokens_used": "{{usage.total_tokens}}",
  "llm_cost": "{{calculated_cost}}",
  "completed_at": "{{now()}}"
}
```

### 7. Send Notification

**Module**: Telegram - Send Message
- **Chat ID**: `{{TELEGRAM_CHAT_ID}}`
- **Message**:
```
📋 Daily Plan Created

Priority tasks:
{{#each daily_plan}}
• {{this.agent}}: {{this.task_type}} ({{this.priority}})
{{/each}}

Alerts: {{alerts}}
```

### 8. Error Handler

**Module**: Error Handler
- Log to `errors` table
- Send Telegram alert
- Set task status to FAILED

## Testing

### Test Scenario

1. **Manual Run**: Execute scenario once
2. **Check Database**: Verify tasks created in `agents_tasks`
3. **Check Telegram**: Confirm notification received
4. **Review Plan**: Ensure plan is logical and actionable

### Test Cases

- ✅ Normal day (moderate activity)
- ✅ High order volume day
- ✅ Low inventory day
- ✅ Multiple agents offline
- ✅ API errors (OpenRouter, Supabase)

## Monitoring

### Success Criteria

- Scenario completes in < 2 minutes
- Plan contains 5-10 tasks
- All high-priority tasks included
- No validation errors from mini
- Telegram notification sent

### Common Issues

1. **"No tasks generated"**
   - Check GPT-4o response format
   - Verify system state data is valid

2. **"Validation failed"**
   - Review mini's feedback
   - Adjust GPT-4o prompt if needed

3. **"Database insert failed"**
   - Check Supabase connection
   - Verify `agents_tasks` table schema

## Cost Estimate

**Per Execution**:
- GPT-4o: ~2000 tokens = $0.06
- GPT-4.1-mini: ~500 tokens = $0.003
- **Total**: ~$0.06/day

**Monthly**: ~$1.80

## Notes

- Planner runs first thing in the morning (08:00 UTC)
- Sets the agenda for all other agents
- Can be manually triggered if needed
- Plan is a recommendation, not enforcement
- Other agents can still operate independently
