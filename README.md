# DROPSHIPPING AI CONTROL CENTER

## Overview

AI-powered dropshipping automation system for camera/photo equipment arbitrage (eBay.de → eBay.com/Shopify/Facebook Marketplace) with 25-30% target margins.

## Architecture

- **Database**: Supabase (PostgreSQL + Auth + Storage)
- **Orchestration**: Make (make.com) for workflows and integrations
- **AI Models**: OpenRouter (GPT-4o, GPT-4.1-mini, Claude 3.5 Sonnet)
- **Frontend**: React + Vite + Tailwind CSS
- **Integrations**: eBay API, Shopify API, Meta Business API, Telegram Bot

## App Attribution

- **Public URL**: https://finder-pan-43124036.figma.site
- **HTTP-Referer**: `https://finder-pan-43124036.figma.site`
- **X-Title**: `Dropshipping AI Control Center`

All OpenRouter requests must include these headers for proper attribution.

## Project Structure

```
dropshiping-system-/
├── frontend/                 # React + Vite dashboard
│   ├── src/
│   │   ├── pages/           # Main pages (Overview, Agents, Tasks, Analytics, Settings)
│   │   ├── components/      # Reusable components
│   │   ├── lib/             # Supabase client, utilities
│   │   └── App.jsx
│   ├── package.json
│   └── vite.config.js
├── supabase/                 # Database schemas and migrations
│   ├── migrations/          # SQL migration files
│   └── seed.sql             # Initial data
├── make-scenarios/           # Make.com scenario templates
│   ├── core/                # Core workflows
│   └── agents/              # AI agent orchestration
├── docs/                     # Documentation
│   ├── AGENTS.md            # Agent specifications and model assignments
│   ├── API_INTEGRATIONS.md  # Integration guides
│   └── SETUP.md             # Setup instructions
├── config/                   # Configuration templates
│   ├── .env.example         # Environment variables template
│   └── bitwarden.md         # Secrets management guide
└── README.md                # This file
```

## AI Agents (8 Core Agents)

1. **Planner Agent** - Task orchestration & planning (GPT-4o + mini)
2. **Multi-Sourcing Agent** - Supplier comparison (GPT-4o + mini + Claude)
3. **Compliance Agent** - Policy validation (mini + Claude)
4. **Listing Agent** - SEO listing generation (GPT-4o + mini)
5. **Pricing Agent** - Dynamic pricing (GPT-4o + mini)
6. **Ops Agent** - Error handling & health checks (mini + GPT-4o)
7. **Reputation Agent** - Reviews & customer service (GPT-4o + mini)
8. **Analytics Agent** - Business intelligence (GPT-4o + mini)

## Model Strategy

- **GPT-4o (`openai/gpt-4o`)**: Core reasoning, complex decisions, content generation
- **GPT-4.1-mini (`openai/gpt-4.1-mini`)**: Fast checks, classification, sanity validation
- **Claude 3.5 Sonnet (`anthropic/claude-3.5-sonnet`)**: Compliance, risk analysis, deep review

## Key Features

- ✅ Multi-supplier product sourcing with profitability analysis
- ✅ Automated listing creation with SEO optimization
- ✅ Compliance checking for eBay/Shopify/Meta policies
- ✅ Dynamic pricing with margin protection (20-30%)
- ✅ Order fulfillment automation
- ✅ Reputation monitoring and customer service
- ✅ Real-time analytics and reporting
- ✅ Interactive dashboard for monitoring and control

## Quick Start

1. **Set up Supabase**
   ```bash
   # Run migrations in supabase/migrations/
   ```

2. **Configure Environment**
   ```bash
   cp config/.env.example frontend/.env.local
   # Add your API keys from Bitwarden
   ```

3. **Install Frontend**
   ```bash
   cd frontend
   npm install
   npm run dev
   ```

4. **Set up Make.com**
   - Import scenarios from `make-scenarios/`
   - Configure connections and API keys
   - Set up webhooks

## Documentation

- [AGENTS.md](docs/AGENTS.md) - Detailed agent specifications
- [API_INTEGRATIONS.md](docs/API_INTEGRATIONS.md) - Integration setup guides
- [SETUP.md](docs/SETUP.md) - Complete setup instructions
- [SYSTEM-SPEC.md](SYSTEM-SPEC.md) - Full system specification

## Security

All secrets are stored in Bitwarden. Never commit API keys or tokens to the repository.

Required secrets:
- `OPENROUTER_API_KEY`
- `SUPABASE_URL` / `SUPABASE_SERVICE_ROLE_KEY` / `SUPABASE_ANON_KEY`
- `EBAY_APP_ID` / `EBAY_CLIENT_ID` / `EBAY_CLIENT_SECRET`
- `SHOPIFY_ACCESS_TOKEN`
- `META_ACCESS_TOKEN`
- `TELEGRAM_BOT_TOKEN`

## License

Proprietary - Internal use only
