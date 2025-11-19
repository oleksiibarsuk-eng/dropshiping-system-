# Reputation Agent - Make.com Scenario

## Purpose

Monitor reviews, respond to customer feedback, manage reputation, and handle customer service issues.

## Trigger

**Webhook**: New review/message received  
**Schedule**: Check reviews every 30 minutes

## Scenario Flow

### 1. Fetch New Reviews

**HTTP - Platform API**: Get reviews since last check
```
GET /reviews?since={{last_check_time}}
```

### 2. Analyze Sentiment with GPT-4.1-mini

**Prompt**:
```
Analyze this review:
Rating: {{rating}}/5
Comment: "{{comment}}"

Output:
{
  "sentiment": "POSITIVE|NEUTRAL|NEGATIVE",
  "sentiment_score": 0-1,
  "issues": ["shipping_delay", "quality_concern"],
  "urgency": "LOW|MEDIUM|HIGH",
  "requires_response": boolean
}
```

### 3. Generate Response with GPT-4o (if needed)

**Prompt**:
```
Write professional response to this {{sentiment}} review:

Review: {{comment}}
Rating: {{rating}}/5
Issues: {{issues}}

Guidelines:
- Thank customer for feedback
- Address specific concerns
- Offer solution if applicable
- Professional and empathetic tone
- Keep under 200 words

Output: { "response": "..." }
```

### 4. Post Response

**HTTP - Platform API**: Reply to review
- Log response in database
- Track response effectiveness

### 5. Alert if Critical

**If negative review**:
- Immediate Telegram alert
- Flag for manual follow-up
- Consider refund/replacement

## Monitoring

- Average rating trend
- Response time to reviews
- Issue resolution rate
- Sentiment score over time

## Cost: ~$0.01/review
