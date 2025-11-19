# 02. Products Sync - Make.com Scenario

## Purpose
Synchronize product data between database and marketplaces, update prices and inventory.

## Trigger
**Schedule**: Every 2 hours

## Flow

### 1. Get Products Needing Sync
```sql
SELECT * FROM products
WHERE updated_at < NOW() - INTERVAL '2 hours'
AND status IN ('ACTIVE', 'PUBLISHED')
```

### 2. For Each Product

**Check Supplier Availability**:
- Query source (eBay.de)
- Verify still available
- Check price changes

**Update Database**:
- New cost price
- Availability status
- Last sync timestamp

**Update Marketplaces**:
- Adjust selling price if needed
- Update inventory
- Modify description if changed

### 3. Handle Price Changes

If supplier price changed > 5%:
- Trigger Pricing Agent
- Recalculate margins
- Update listings

### 4. Handle Unavailable Products

If product no longer available:
- Mark as OUT_OF_STOCK
- Delist from marketplaces
- Find alternative supplier
- Alert via Telegram

## Monitoring

- Sync success rate
- Products needing attention
- Price change frequency
- Availability issues
