# Ops Agent - Make.com Scenario

## Purpose

Automated order fulfillment, error handling, and operational health monitoring.

## Trigger

**Webhook**: Order received from marketplace  
**Schedule**: Check pending orders every 5 minutes

## Scenario Flow

### 1. Receive Order Notification

**Webhook payload**:
```json
{
  "order_id": "12345",
  "platform": "eBay",
  "product_sku": "SONY-A7IV",
  "customer": {...},
  "amount": 2999.00
}
```

### 2. Validate Order with GPT-4.1-mini

Quick checks:
- Product still available from supplier
- Price hasn't changed significantly
- Shipping address valid
- No fraud indicators

### 3. Purchase from Supplier

**HTTP - eBay.de**: Place order with supplier
- Use stored payment method
- Add buyer's shipping address
- Request tracking number

### 4. Update Customer Order

**HTTP - Marketplace API**: Update order status
- Mark as shipped
- Add tracking number
- Send customer notification

### 5. Handle Errors

**If purchase fails**:
- Try alternative supplier
- Notify customer of delay
- Flag for manual intervention
- Log detailed error

## Monitoring

- Order fulfillment success rate
- Average fulfillment time
- Error types and frequency
- Supplier reliability scores

## Cost: ~$0.001/order
