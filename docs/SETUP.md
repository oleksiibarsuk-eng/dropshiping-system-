# Setup Guide

Complete setup instructions for the Dropshipping AI Control Center.

## Prerequisites

- Node.js 18+ and npm
- Supabase account (free tier works)
- Make.com account (free tier: 1000 operations/month)
- OpenRouter account with API key
- Platform accounts (eBay, Shopify, Meta)
- Bitwarden account for secrets management

## Phase 0: Account Setup (3-5 days)

### 1. Supabase Setup

1. Create account at https://supabase.com
2. Create new project (choose region closest to you)
3. Wait for project to provision (~2 minutes)
4. Go to Settings → API:
   - Copy `Project URL`
   - Copy `anon public` key
   - Copy `service_role` key (keep secret!)
5. Go to SQL Editor:
   - Run `supabase/migrations/001_initial_schema.sql`
   - Run `supabase/seed.sql`
6. Verify tables created successfully

### 2. OpenRouter Setup

1. Create account at https://openrouter.ai
2. Add credits ($10 minimum recommended)
3. Generate API key at https://openrouter.ai/keys
4. Note the key for Bitwarden

### 3. Make.com Setup

1. Create account at https://make.com
2. Verify email
3. Explore the dashboard
4. Note: Free tier gives 1000 operations/month (sufficient for testing)

### 4. eBay Developer Setup

1. Go to https://developer.ebay.com
2. Create developer account
3. Register application:
   - App Type: "Production"
   - Scopes: Sell API, Inventory API, Fulfillment API
4. Get credentials:
   - App ID
   - Client ID
   - Client Secret
5. Generate User Token (follow OAuth flow)
6. Store in Bitwarden

**Note**: eBay setup is complex. See https://developer.ebay.com/api-docs/static/oauth-credentials.html

### 5. Shopify Setup

1. Create Shopify store (free trial available)
2. Go to Settings → Apps and sales channels
3. Develop apps → Create an app
4. Configure Admin API scopes:
   - `read_products`, `write_products`
   - `read_orders`, `write_orders`
   - `read_inventory`, `write_inventory`
5. Install app and get Admin API access token
6. Store in Bitwarden

### 6. Meta Business Setup (Optional)

1. Create Facebook Business Manager account
2. Create Facebook Page for your business
3. Go to https://developers.facebook.com
4. Create app → Business → Marketing API
5. Generate access token with permissions:
   - `ads_management`
   - `pages_manage_posts`
6. Store in Bitwarden

### 7. Telegram Bot Setup

1. Message @BotFather on Telegram
2. Send `/newbot` command
3. Follow prompts to create bot
4. Copy bot token
5. Get your chat ID:
   - Message your bot
   - Visit: `https://api.telegram.org/bot<TOKEN>/getUpdates`
   - Find your `chat.id`
6. Store both in Bitwarden

## Phase 1: Frontend Setup (30 minutes)

### 1. Clone and Install

```bash
cd /Users/admin/dropshiping-system-
cd frontend
npm install
```

### 2. Configure Environment

```bash
cp ../config/.env.example .env.local
```

Edit `.env.local` with values from Bitwarden:
```bash
VITE_SUPABASE_URL=https://xxx.supabase.co
VITE_SUPABASE_ANON_KEY=your-anon-key
```

### 3. Run Development Server

```bash
npm run dev
```

Open http://localhost:3000 - you should see the dashboard!

### 4. Test Supabase Connection

- Go to Analytics page
- If data loads, connection works ✅
- If errors, check `.env.local` and Supabase project status

## Phase 2: Make.com Setup (2-3 hours)

### 1. Create Connections

Go to Make.com → Connections:

**Supabase Connection**:
- Type: HTTP
- Name: "Dropshipping - Supabase"
- Base URL: Your Supabase URL
- Headers:
  - `apikey`: Your Supabase anon key
  - `Authorization`: Bearer {service_role_key}

**OpenRouter Connection**:
- Type: HTTP
- Name: "Dropshipping - OpenRouter"
- Base URL: `https://openrouter.ai/api/v1`
- Headers:
  - `Authorization`: Bearer {api_key}
  - `HTTP-Referer`: `https://finder-pan-43124036.figma.site`
  - `X-Title`: `Dropshipping AI Control Center`

**eBay Connection**:
- Type: OAuth 2.0
- Follow eBay's OAuth setup
- Use credentials from Bitwarden

**Telegram Connection**:
- Type: Built-in Telegram
- Bot Token: From Bitwarden
- Chat ID: From Bitwarden

### 2. Create Scenarios

Start with core scenarios (in order):

1. **01. Infra Check**
   - Create new scenario
   - Add Schedule trigger (every 15 min)
   - Add HTTP modules to check each integration
   - Test and activate

2. **05. Notifications & Alerts**
   - Create webhook receiver
   - Add Telegram send message
   - Test with sample data

3. **Planner Agent**
   - Follow `make-scenarios/agents/planner-agent.md`
   - Test manually before scheduling
   - Schedule for 08:00 UTC daily

### 3. Test Scenarios

For each scenario:
- ✅ Run once manually
- ✅ Check Make.com execution log
- ✅ Verify data in Supabase
- ✅ Confirm Telegram notifications
- ✅ Test error handling

## Phase 3: Integration Testing (1-2 hours)

### 1. Test Product Sourcing

1. Trigger Multi-Sourcing Agent (create scenario first)
2. Check `products` table in Supabase
3. Verify data appears in dashboard

### 2. Test Listing Creation

1. Trigger Listing Agent with test product
2. Check `listings` table
3. Verify listing appears in dashboard

### 3. Test Compliance Check

1. Create listing with high-risk keyword ("replica")
2. Trigger Compliance Agent
3. Verify task flagged as `NEEDS_REVIEW`
4. Check Tasks page in dashboard

### 4. Test End-to-End Flow

```
1. Planner Agent creates daily plan
2. Multi-Sourcing Agent finds products
3. Compliance Agent validates products
4. Listing Agent creates listings
5. Pricing Agent sets prices
6. (Manually create test order)
7. Ops Agent fulfills order
8. Analytics Agent generates report
```

## Phase 4: Production Deployment (Optional)

### 1. Deploy Frontend

**Option A: Vercel (Recommended)**
```bash
# Install Vercel CLI
npm i -g vercel

# Deploy
cd frontend
vercel

# Set environment variables in Vercel dashboard
```

**Option B: Netlify**
```bash
# Build
npm run build

# Deploy dist/ folder to Netlify
```

### 2. Configure Production Secrets

- Use separate API keys for production
- Rotate all development keys
- Set up monitoring and alerts

### 3. Enable All Scenarios

- Review each scenario schedule
- Ensure all are activated
- Monitor first 24 hours closely

## Troubleshooting

### Frontend Issues

**"Cannot connect to Supabase"**
- Verify `VITE_SUPABASE_URL` format (must include https://)
- Check Supabase project is active
- Verify anon key is correct

**"Module not found"**
```bash
rm -rf node_modules package-lock.json
npm install
```

### Make.com Issues

**"Authentication failed"**
- Re-check API keys in connections
- Verify no extra spaces in keys
- Check token expiration (eBay, Meta)

**"Rate limit exceeded"**
- Reduce scenario frequency
- Upgrade Make.com plan if needed
- Implement queuing/throttling

**"Scenario fails randomly"**
- Add error handlers to all modules
- Implement retry logic
- Check external API status pages

### Supabase Issues

**"Database error"**
- Check SQL syntax in migrations
- Verify all tables created
- Review Supabase logs

**"RLS policy error"**
- Using service_role key bypasses RLS
- For frontend queries, add RLS policies

## Monitoring Checklist

Daily:
- [ ] Check Make.com execution history
- [ ] Review Supabase `errors` table
- [ ] Check Telegram for alerts
- [ ] Review dashboard metrics

Weekly:
- [ ] Analyze costs (Make.com, OpenRouter, Supabase)
- [ ] Review agent performance
- [ ] Check for stuck tasks
- [ ] Verify all integrations healthy

Monthly:
- [ ] Rotate sensitive API keys
- [ ] Review and optimize scenarios
- [ ] Analyze business metrics
- [ ] Plan for scaling

## Next Steps

After setup is complete:

1. **Run for 1 week in test mode**
   - Use `TEST_` prefix for all products
   - Don't publish to real marketplaces
   - Monitor all metrics closely

2. **Gradual rollout**
   - Start with 10-20 real products
   - Monitor for 3-5 days
   - Gradually increase volume

3. **Optimization**
   - Tune agent prompts based on results
   - Adjust pricing strategies
   - Refine compliance rules
   - Optimize costs

## Support

- **Make.com**: https://www.make.com/en/help
- **Supabase**: https://supabase.com/docs
- **OpenRouter**: https://openrouter.ai/docs
- **This project**: Check docs/ folder

## Estimated Costs

### Free Tier (Development)
- Supabase: Free (500MB database, 2GB bandwidth)
- Make.com: Free (1000 operations/month)
- OpenRouter: Pay-as-you-go (~$5-10/month for testing)
- **Total**: ~$5-10/month

### Production (Light usage)
- Supabase: $25/month (Pro plan)
- Make.com: $9/month (Core plan, 10k operations)
- OpenRouter: $50-100/month (depends on volume)
- **Total**: ~$85-135/month

### Production (Heavy usage)
- Supabase: $25-50/month
- Make.com: $16-29/month (Pro/Advanced plan)
- OpenRouter: $200-500/month
- **Total**: ~$240-580/month

*Costs exclude marketplace fees, ad spend, and product costs*
