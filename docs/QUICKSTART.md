# Quick Start Guide

Get your Dropshipping AI Control Center running in 15 minutes.

## Prerequisites

- macOS/Linux
- Homebrew installed
- Internet connection

## Step 1: Run Setup Script (5 min)

```bash
cd /Users/admin/dropshiping-system-
chmod +x scripts/setup.sh
./scripts/setup.sh
```

This will:
- Install Node.js (if needed)
- Install frontend dependencies
- Create .env.local template

## Step 2: Set Up Supabase (5 min)

1. Go to https://supabase.com/dashboard
2. Click "New project"
3. Fill in:
   - Name: `dropshipping-ai`
   - Database Password: (generate strong password)
   - Region: (closest to you)
4. Wait ~2 minutes for project creation
5. Go to Settings → API:
   - Copy `Project URL`
   - Copy `anon public` key
6. Go to SQL Editor → New query
7. Copy and run `/Users/admin/dropshiping-system-/supabase/migrations/001_initial_schema.sql`
8. Run `/Users/admin/dropshiping-system-/supabase/migrations/002_helper_functions.sql`
9. Run `/Users/admin/dropshiping-system-/supabase/seed.sql`

## Step 3: Configure Environment (2 min)

Edit `frontend/.env.local`:

```env
VITE_SUPABASE_URL=https://your-project.supabase.co
VITE_SUPABASE_ANON_KEY=your-anon-key-here
```

## Step 4: Run Dashboard (1 min)

```bash
cd frontend
npm run dev
```

Open http://localhost:3000 - You should see the dashboard! 🎉

## Step 5: Test Integration (2 min)

```bash
cd ..
chmod +x scripts/test-integrations.sh
./scripts/test-integrations.sh
```

Expected output:
```
✅ Supabase: Connected
```

## What's Next?

### For Testing (Recommended First)

1. **Set up OpenRouter**:
   - Go to https://openrouter.ai
   - Add $10 credits
   - Copy API key
   - Add to `.env.local`

2. **Test with Make.com free tier**:
   - Create account at https://make.com
   - Import scenario from `make-scenarios/agents/planner-agent.md`
   - Test manually

### For Production

Follow complete setup guide: `docs/SETUP.md`

1. eBay Developer Account
2. Shopify Store
3. Meta Business Account
4. Telegram Bot
5. Deploy all Make.com scenarios

## Troubleshooting

**Dashboard is blank**:
- Check browser console for errors
- Verify Supabase URL format: `https://xxx.supabase.co`
- Check Supabase project is active

**npm install fails**:
```bash
rm -rf node_modules package-lock.json
npm cache clean --force
npm install
```

**Port 3000 in use**:
```bash
npm run dev -- --port 3001
```

## Key URLs

- Dashboard: http://localhost:3000
- Supabase Dashboard: https://supabase.com/dashboard
- OpenRouter: https://openrouter.ai/keys
- Make.com: https://make.com
- Documentation: `docs/SETUP.md`

## Architecture Overview

```
┌─────────────┐
│   React     │  ← You are here (Dashboard)
│  Dashboard  │
└──────┬──────┘
       │
       v
┌─────────────┐
│  Supabase   │  ← Database (13 tables)
│  PostgreSQL │
└──────┬──────┘
       │
       v
┌─────────────┐
│  Make.com   │  ← Automation (8 AI agents)
│  Scenarios  │
└──────┬──────┘
       │
       v
┌─────────────┐
│ OpenRouter  │  ← AI Models (GPT-4o, mini, Claude)
│   + APIs    │
└─────────────┘
```

## Support

- Full Setup: `docs/SETUP.md`
- Troubleshooting: `docs/TROUBLESHOOTING.md`
- API Integration: `docs/API_INTEGRATIONS.md`
- Agent Specs: `docs/AGENTS.md`

## Cost Estimate (Testing)

- Supabase: Free
- Make.com: Free (1000 ops/month)
- OpenRouter: ~$5-10/month
- **Total**: $5-10/month

Ready to scale? See `docs/SETUP.md` for production deployment.
