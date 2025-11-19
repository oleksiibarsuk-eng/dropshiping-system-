# Troubleshooting Guide

## Common Issues and Solutions

### Frontend Issues

#### Cannot Connect to Supabase

**Symptoms**: Dashboard shows "Failed to fetch" or blank data

**Solutions**:
1. Check `.env.local` file exists in `/frontend/`
2. Verify `VITE_SUPABASE_URL` format: `https://xxx.supabase.co`
3. Verify `VITE_SUPABASE_ANON_KEY` is correct (no extra spaces)
4. Check Supabase project status at https://supabase.com/dashboard
5. Test connection manually:
```bash
curl https://YOUR_PROJECT.supabase.co/rest/v1/ \
  -H "apikey: YOUR_ANON_KEY"
```

#### npm install fails

**Error**: `ERESOLVE unable to resolve dependency tree`

**Solutions**:
```bash
# Clear cache and reinstall
rm -rf node_modules package-lock.json
npm cache clean --force
npm install

# Or use --legacy-peer-deps
npm install --legacy-peer-deps
```

#### Port 3000 already in use

**Error**: `Port 3000 is already in use`

**Solutions**:
```bash
# Find and kill process on port 3000
lsof -ti:3000 | xargs kill -9

# Or use different port
npm run dev -- --port 3001
```

---

### Make.com Issues

#### Authentication Failed

**Error**: `401 Unauthorized` or `403 Forbidden`

**Checklist**:
- [ ] API key copied correctly (no spaces)
- [ ] Connection type matches (HTTP/OAuth)
- [ ] Headers configured properly
- [ ] Token hasn't expired (eBay, Meta tokens expire)
- [ ] Service role key used (not anon key) for Supabase writes

**eBay Token Refresh**:
```bash
curl -X POST 'https://api.ebay.com/identity/v1/oauth2/token' \
  -H 'Content-Type: application/x-www-form-urlencoded' \
  -H 'Authorization: Basic BASE64(CLIENT_ID:CLIENT_SECRET)' \
  -d 'grant_type=refresh_token&refresh_token=REFRESH_TOKEN'
```

#### Rate Limit Exceeded

**Error**: `429 Too Many Requests`

**Solutions**:
1. **Reduce frequency**: Change schedule from every 15min to every 30min
2. **Add delays**: Insert "Sleep" module between iterations
3. **Batch requests**: Group multiple items in single API call
4. **Upgrade plan**: Check if you've hit Make.com operation limit
5. **Contact platform**: Request rate limit increase

**Make.com Operation Limits**:
- Free: 1,000 operations/month
- Core: 10,000 operations/month
- Pro: 40,000 operations/month

#### Scenario Fails Randomly

**Symptoms**: Works sometimes, fails other times

**Common Causes**:
1. **External API downtime**: Check status pages
   - eBay: https://developer.ebay.com/support/api-status
   - Shopify: https://status.shopify.com
   - OpenRouter: Check their Discord/Twitter
2. **Timeout**: Increase timeout in HTTP modules (default 40s → 120s)
3. **No error handler**: Add error handler to every scenario
4. **Data format**: Validate JSON before sending

**Best Practice**:
```
Add Error Handler Module:
- Resume execution: No (stop on error)
- Number of retries: 1
- Retry delay: 30 seconds
- Store error in variable
- Log to Supabase errors table
- Send Telegram alert
```

---

### Supabase Issues

#### Database Connection Failed

**Error**: `connection refused` or `timeout`

**Check**:
1. Project is not paused (free tier pauses after inactivity)
2. URL is correct: `https://PROJECT_ID.supabase.co`
3. Network allows connections (firewall, VPN)
4. Service is up: https://status.supabase.com

**Wake up paused project**:
- Go to Supabase dashboard
- Click "Restore" if paused
- Wait 1-2 minutes for project to wake

#### Migration Failed

**Error**: Syntax error in SQL

**Steps**:
1. Copy SQL from migration file
2. Go to Supabase SQL Editor
3. Run query line by line to find error
4. Check for:
   - Missing semicolons
   - Reserved keywords (use quotes)
   - Data type mismatches
   - Foreign key references

**Common fixes**:
```sql
-- Use quotes for reserved words
CREATE TABLE "order" (...)  -- "order" is reserved

-- Check data types
price DECIMAL(10,2)  -- Not MONEY or FLOAT

-- Enable UUID extension first
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
```

#### RLS Policy Error

**Error**: `permission denied for table`

**Solutions**:
1. **Use service_role key** for backend/Make.com (bypasses RLS)
2. **Use anon key only for frontend** with proper RLS policies
3. **Add RLS policy** if using anon key:
```sql
-- Allow read access to all users
CREATE POLICY "Public read access" ON products
FOR SELECT USING (true);

-- Allow insert only to authenticated users
CREATE POLICY "Authenticated insert" ON products
FOR INSERT TO authenticated
WITH CHECK (true);
```

---

### OpenRouter Issues

#### Insufficient Credits

**Error**: `402 Payment Required`

**Solution**:
1. Go to https://openrouter.ai/credits
2. Add credits ($10 minimum)
3. Wait 1-2 minutes for activation
4. Retry request

#### Model Not Found

**Error**: `model not found` or `invalid model`

**Check**:
- Model name is correct: `openai/gpt-4o` (not `gpt-4o`)
- Model is available on OpenRouter
- No typos in model name

**Available Models**:
```
openai/gpt-4o
openai/gpt-4.1-mini
anthropic/claude-3.5-sonnet
```

#### Request Too Large

**Error**: `413 Request Entity Too Large`

**Solutions**:
1. Reduce prompt length
2. Summarize input data
3. Remove unnecessary context
4. Use smaller context window

**Token Limits**:
- GPT-4o: 128k tokens
- GPT-4.1-mini: 128k tokens
- Claude 3.5: 200k tokens

---

### eBay API Issues

#### Listing Creation Failed

**Error**: `error 21916883`

**Reason**: Category, item specifics, or policy requirements not met

**Solutions**:
1. Check eBay category requirements
2. Fill all required item specifics
3. Include return policy
4. Add shipping details
5. Use correct condition code

**Required fields**:
- Title (80 chars max)
- Description
- Category ID
- Price
- Condition
- Return policy
- Shipping options

#### Token Expired

**Error**: `error 001`

**Solution**: Refresh OAuth token (see above)

**Token Lifetimes**:
- Access token: 2 hours
- Refresh token: 18 months
- User consent: Must re-authorize if revoked

---

### Debugging Tools

#### Test Supabase Connection

```bash
# Test REST API
curl https://YOUR_PROJECT.supabase.co/rest/v1/products?limit=1 \
  -H "apikey: YOUR_ANON_KEY"

# Should return JSON array
```

#### Test OpenRouter

```bash
curl https://openrouter.ai/api/v1/models \
  -H "Authorization: Bearer YOUR_API_KEY"

# Should return models list
```

#### Test Make.com Webhook

```bash
curl -X POST https://hook.eu1.make.com/YOUR_WEBHOOK_ID \
  -H "Content-Type: application/json" \
  -d '{"test": true}'

# Check Make.com execution history
```

#### Check Make.com Logs

1. Go to Make.com scenario
2. Click "History" tab
3. Click failed execution
4. Expand each module to see input/output
5. Look for red error messages

#### Check Supabase Logs

1. Go to Supabase Dashboard → Logs
2. Filter by timeframe
3. Look for errors (red)
4. Check API logs for failed requests

---

### Performance Issues

#### Slow Dashboard

**Causes**:
- Large datasets (thousands of records)
- Missing database indexes
- Slow API responses
- Not using pagination

**Solutions**:
1. Add pagination to data tables
2. Limit initial data load
3. Add database indexes:
```sql
CREATE INDEX idx_products_status ON products(status);
CREATE INDEX idx_listings_platform ON listings(platform);
```
4. Use Supabase RPC for complex queries
5. Cache data in frontend (React Query)

#### Slow Make.com Scenarios

**Causes**:
- Too many iterations
- No parallel processing
- Large API responses
- Complex LLM prompts

**Solutions**:
1. Use parallel paths where possible
2. Batch database inserts
3. Reduce LLM prompt size
4. Cache repeated API calls
5. Use aggregators instead of iterations

---

### Getting Help

#### Resources

- **Make.com**: https://www.make.com/en/help
- **Supabase**: https://supabase.com/docs
- **OpenRouter**: https://openrouter.ai/docs
- **eBay Developers**: https://developer.ebay.com/support

#### Before Asking for Help

1. Check this troubleshooting guide
2. Review Make.com execution logs
3. Check external service status pages
4. Test API endpoints manually
5. Verify all credentials
6. Try with fresh data

#### What to Include

When reporting an issue:
- Exact error message
- Steps to reproduce
- Screenshots of logs
- Environment (dev/prod)
- Recent changes made
- Already attempted solutions

---

### Emergency Procedures

#### System Down

1. **Check status pages** of all services
2. **Pause all Make.com scenarios** to prevent cascading failures
3. **Check database** for critical errors
4. **Notify stakeholders** via Telegram
5. **Begin systematic recovery**:
   - Fix root cause
   - Test in isolation
   - Gradually re-enable scenarios
   - Monitor closely

#### Data Corruption

1. **Stop all writes immediately**
2. **Backup current database**:
```bash
# Use Supabase dashboard: Database → Backups
```
3. **Identify corrupt data**
4. **Restore from backup if needed**
5. **Fix data integrity**
6. **Add validation** to prevent recurrence

#### Account Suspended

**eBay/Shopify/Meta suspension**:

1. **Identify reason** (check email, dashboard)
2. **Pause all related scenarios**
3. **Review recent listings** for policy violations
4. **Submit appeal** with:
   - Explanation of violation
   - Steps taken to fix
   - Prevention measures
5. **Wait for response** (usually 3-7 days)
6. **Resume carefully** after reinstatement

---

This troubleshooting guide covers 90% of common issues. Update it as you encounter new problems and solutions.
