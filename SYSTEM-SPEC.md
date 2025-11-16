# DROPSHIPPING AI CONTROL CENTER - SYSTEM SPECIFICATION

## 0. Document Purpose

This is the complete system specification for the Dropshipping AI Control Center including:
- Architecture (Supabase + Make + OpenRouter + React frontend)
- Data models and validation layers
- AI agents and their responsibilities
- Margin, compliance, and supplier rules
- Secrets management (Bitwarden)
- Interactive application design and React structure
- Key UX flows

---

## 1. Project Overview

Dropshipping AI Control Center is a system for managing dropshipping business (eBay / Shopify / Meta) using:

- **Supabase** as the main database and backend-as-a-service
- **Make** (make.com) as orchestrator for scenarios and integrations
- **AI Agents** (via OpenRouter) for intelligent automation
- **React/Vite dashboard** for operations control

**Goal**: A production-ready framework that can be deployed, connected to suppliers and marketplaces, and scaled.

---

## 2. High-Level Architecture

### Supabase
- Tables: `products`, `listings`, `suppliers`, `orders`, `errors`, `logs`, `agents_tasks`, `analytics_*`
- Auth (access to web panel)
- REST / RPC API for Make and frontend

### Make (make.com)
- Scenarios for product import, listing sync, order processing, error logging, and notifications
- Orchestrates calls to OpenRouter and external APIs (eBay, Shopify, Meta, Telegram)

### OpenRouter + LLM Models
- Single entry point to models (OpenAI, Anthropic)
- App Attribution (HTTP-Referer + X-Title) for ratings and analytics

### Frontend Dashboard
- React + Vite, professional design
- Shows agent statuses, tasks, logs, integrations, metrics

---

## 3. Technology Stack

- **Orchestrator**: Make (make.com)
- **Database**: Supabase (PostgreSQL, Auth, Storage)
- **AI Stack** (via OpenRouter):
  - `openai/gpt-4o` - main brain (complex tasks, generation)
  - `openai/gpt-4.1-mini` - fast, cheap checks and classification
  - `anthropic/claude-3.5-sonnet` - deep compliance and analysis
- **Integrations**: eBay API, Shopify API, Meta / Facebook Marketing API, Telegram Bot API
- **Frontend**: React + Vite + Tailwind CSS

---

## 4. OpenRouter and App Attribution

**Public URL for App Attribution:**  
`https://finder-pan-43124036.figma.site`

**Required headers for all OpenRouter requests:**
- `HTTP-Referer: https://finder-pan-43124036.figma.site`
- `X-Title: Dropshipping AI Control Center`

All Make scenarios and agents must use these headers so statistics and ratings are aggregated under one application.

---

## 5. Models and Validation Layers

### 5.1 Model Roles

- **`openai/gpt-4o`** - Core Reasoning & Generation:
  - Planning, strategies, listing and description generation
- **`openai/gpt-4.1-mini`** - Fast Checks & Classification:
  - Quick margin checks, prices, sanity-check
- **`anthropic/claude-3.5-sonnet`** - Compliance & Deep Review:
  - Compliance, risks, complex cases

### 5.2 Typical Pipeline

1. **Main decision (4o)** - agent forms draft (listing, price, action)
2. **Sanity-check (4.1-mini)** - check for basic errors, rule violations
3. **Compliance (claude, by trigger)** - deep-review for high-risk categories, large amounts, and tasks with flags from mini

Results are recorded in `agents_tasks`, `logs`, `errors`.

---

## 6. Make: Scenario Set

**Recommended structure:**

- `Dropshipping / Core`
  - `01. Infra Check`
  - `02. Products Sync`
  - `03. Listings Sync`
  - `04. Orders Fulfillment`
  - `05. Notifications & Alerts`
- `Dropshipping / AI Agents`
  - Planner / Multi-Sourcing / Compliance / Listing / Pricing / Ops / Reputation / Analytics Orchestration

Each scenario calls the needed model via OpenRouter and writes results to Supabase.

---

## 7. AI Agents

All agents use unified headers:
- `HTTP-Referer: https://finder-pan-43124036.figma.site`
- `X-Title: Dropshipping AI Control Center`

**General logic:**
- Complex tasks → `gpt-4o`
- Fast check layer → `gpt-4.1-mini`
- Compliance / deep-review → `claude-3.5-sonnet`

**Agents brief:**

1. **Planner Agent** - strategy, prioritization, research and listing plan (4o + mini-check)
2. **Multi-Sourcing Agent** - supplier search/comparison, prices, conditions and risks (4o + mini + claude)
3. **Compliance Agent** - eBay/Shopify/Meta policy, prohibited content, TM (mini + claude)
4. **Listing Agent** - listing generation, completeness/quality check (4o + mini, compliance via Compliance Agent)
5. **Pricing Agent** - dynamic pricing, margin protection, competitor reactions (4o + mini)
6. **Ops Agent** - errors, retries, health-check (mini, for complex cases 4o)
7. **Reputation Agent** - reviews, sentiment, reputation, customer responses (4o + mini)
8. **Analytics Agent** - sales/margin/LLM usage analytics, trends (4o + mini)

---

## 8. Secrets & Bitwarden

All keys are stored in Bitwarden and don't go into the repository.

**Main variables:**
- `OPENROUTER_API_KEY`
- `SUPABASE_URL`
- `SUPABASE_SERVICE_ROLE_KEY`
- `SUPABASE_ANON_KEY`
- `EBAY_APP_ID` / `EBAY_CLIENT_ID` / `EBAY_CLIENT_SECRET`
- `SHOPIFY_ACCESS_TOKEN`
- `META_ACCESS_TOKEN`
- `TELEGRAM_BOT_TOKEN`
- `MAKE_API_TOKEN` (if needed)

**Usage:**
- Frontend (Vite): `.env.local` with `VITE_SUPABASE_URL`, `VITE_SUPABASE_ANON_KEY`
- Make: variables / connections with OpenRouter, Supabase and integration keys
- Backend/CLI: `.env` + `dotenv`

**Rule**: No hardcoded keys in code.

---

## 9. System Rules

### 9.1 Global Rules

- Single access point to models - only OpenRouter
- All critical actions go through: 4o → 4.1-mini → (optional) claude
- Mandatory logging:
  - `agents_tasks` for agent tasks
  - `errors` for errors
- Task statuses: `PENDING / IN_PROGRESS / SUCCESS / NEEDS_REVIEW / FAILED`
- High-risk tasks (`NEEDS_REVIEW`, `COMPLIANCE_RISK`) require manual approval
- Agents don't write to marketplaces directly - only through Make scenarios

### 9.2 Margin and Prices

- Supabase stores `minimal_margin_percent` for each product
- Price cannot be below `cost * (1 + minimal_margin_percent)` or global threshold (e.g. 20%)
- Price change > X% (e.g. 30%) at once requires `NEEDS_REVIEW`
- If price < 50% or > 200% of market average - task automatically `NEEDS_REVIEW`

### 9.3 Compliance

- High-risk categories and words - in `compliance_rules` table
- Any match → trigger Compliance Agent
- Verdict: `ALLOW / ALLOW_WITH_CHANGES / BLOCK` + reasons and list of edits
- Everything logged in `compliance_issues`

### 9.4 Suppliers

- Preferably ≥ 2 reliable suppliers per product
- `HIGH_RISK_SUPPLIER` → block auto-orders, manual approval only
- Any change in supplier conditions triggers margin and listing review

---

## 10. Design and React Structure

**Main screens:**
- **Overview** - summary metrics, charts, activity feed
- **Agents** - agent list, statuses, detail panel, prompt testing
- **Tasks** - task queue, `NEEDS_REVIEW` filter, review modal
- **Analytics** - sales, margin, LLM usage charts
- **Settings** - margin, compliance rules, integrations

**`frontend/src` structure:**
- `pages/` - Overview, Agents, Tasks, Analytics, Settings
- `components/` - layout, overview, agents, tasks, analytics, settings, common (Button, Card, Modal, Table, etc.)

---

## 11. UX Flows

**Key scenarios:**

### 1. Manual Review of `NEEDS_REVIEW` Task
- Agent creates task → mini/claude set flag → user on TasksPage via `TaskReviewModal` approves or rejects → Make executes action → event in ActivityFeed

### 2. Creating New Listing
- Planner / Multi-Sourcing create products → Listing Agent generates draft (4o + mini + claude if needed) → if `NEEDS_REVIEW` manual edit in UI → after `Approve` Make publishes listing

### 3. Integration Error
- Make gets marketplace error → writes to `errors` + task for Ops Agent → Ops Agent classifies and suggests plan → user fixes config in Settings → health-check scenario verifies status

### 4. Rule Change
- User changes margin or compliance rules in Settings → Supabase saves → Make picks up changes and uses new rules in next tasks → changes are logged

---

This file can be placed in the repository as `README.md` or `SYSTEM-SPEC.md` for the Dropshipping AI Control Center.
