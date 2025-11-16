# Tech - Технології та інструменти

## Основний технологічний стек

### Core Infrastructure

#### n8n - Workflow Orchestrator
```yaml
Версія: Latest (Cloud або Self-hosted)
Призначення: Оркестрація всіх агентів
Вартість:
  - Cloud: $20/міс (5,000 executions)
  - Self-hosted: $5-10/міс (VPS)

Налаштування:
  - Cloud: n8n.io → Sign up → Create workspace
  - Self-hosted:
      docker run -it --rm \
        --name n8n \
        -p 5678:5678 \
        -v ~/.n8n:/home/node/.n8n \
        n8nio/n8n

Environment Variables:
  - N8N_BASIC_AUTH_ACTIVE=true
  - N8N_BASIC_AUTH_USER=admin
  - N8N_BASIC_AUTH_PASSWORD=your_password
  - N8N_ENCRYPTION_KEY=your_encryption_key
  - WEBHOOK_URL=https://your-n8n.app
```

#### OpenAI API - LLM для агентів
```yaml
Модель: GPT-4 Turbo (gpt-4-turbo-preview)
Вартість: $0.01/1K input tokens, $0.03/1K output tokens

Оцінка витрат:
  - Product Sourcing (50 товарів): ~$1-2
  - Listing Generation (50 лістингів): ~$3-5
  - Daily operations: ~$10-15/день

Monthly budget: ~$300-450

API Key: platform.openai.com → API keys → Create new

Використання в n8n:
  Node: OpenAI
  Model: gpt-4-turbo-preview
  Temperature: 0.7
  Max Tokens: 2000
```

#### Supabase - PostgreSQL Database
```yaml
Версія: Latest
Вартість: Free tier (500MB, 2GB egress)

Налаштування:
  1. supabase.com → New Project
  2. Get API URL + anon key
  3. Create tables:
     - products (SKU, title, cost, selling_price, margin, source)
     - orders (order_id, shopify_id, status, tracking, date)
     - pricing_history (product_id, old_price, new_price, reason, timestamp)
     - errors (agent_name, error_message, stack_trace, timestamp)
     - analytics (date, sales, revenue, profit, orders_count)

Environment Variables:
  - SUPABASE_URL=https://xxxxx.supabase.co
  - SUPABASE_ANON_KEY=your_anon_key
```


#### Cursor AI - AI IDE
```yaml
Версія: Latest
Вартість: Free (з обмеженнями) або Pro $20/міс

Налаштування:
  1. Завантажити з cursor.sh
  2. Відкрити проект:
     cursor /Users/admin/Documents/dropshipping-automation
  3. AI Rules завантажуються автоматично з docs/rules/
  4. Memory Bank доступний через @docs/rules/memory-bank/

Використання:
  - Composer: Cmd+I для чату з контекстом
  - Inline: Cmd+K для швидких правок
  - @ mentions: Посилання на файли/папки
  
Інтеграція в workflow:
  - Cursor AI може викликатися через OpenAI API
  - Workflow: cursor-ai-optimizer.json
```

### External Services

#### Shopify - E-commerce Platform
```yaml
План: Basic ($39/міс)
API Version: 2024-01

Налаштування:
  1. Settings → Apps → Develop apps
  2. Create app → Configure Admin API
  3. Permissions:
     - read_products, write_products
     - read_orders, write_orders
     - read_inventory, write_inventory
  4. Install app → Get Admin API access token

API Endpoints:
  - Get Products: GET /admin/api/2024-01/products.json
  - Create Product: POST /admin/api/2024-01/products.json
  - Update Product: PUT /admin/api/2024-01/products/{id}.json
  - Get Orders: GET /admin/api/2024-01/orders.json

Rate Limits:
  - 2 requests/second
  - Використати Retry-After header

Environment Variables:
  - SHOPIFY_STORE_URL=your-store.myshopify.com
  - SHOPIFY_ACCESS_TOKEN=shpat_xxxxx
```

#### eBay API
```yaml
Marketplace: eBay.com (продаж), eBay.de (закупівля)
API: Trading API, Finding API

Налаштування:
  1. developer.ebay.com → My Account
  2. Create Keyset → Production
  3. Get credentials:
     - App ID (Client ID)
     - Dev ID
     - Cert ID (Client Secret)
  4. Generate User Token (OAuth)

API Endpoints:
  - Finding API: svcs.ebay.com/services/search/FindingService/v1
  - Trading API: api.ebay.com/ws/api.dll

Rate Limits:
  - 5,000 calls/day (production)
  - Категорія товару: 11700 (Cameras & Photo)

Environment Variables:
  - EBAY_APP_ID=YourAppID
  - EBAY_DEV_ID=YourDevID
  - EBAY_CERT_ID=YourCertID
  - EBAY_USER_TOKEN=v^1.1.xxxxx
```


#### Cursor AI - AI IDE
```yaml
Версія: Latest
Вартість: Free (з обмеженнями) або Pro $20/міс

Налаштування:
  1. Завантажити з cursor.sh
  2. Відкрити проект:
     cursor /Users/admin/Documents/dropshipping-automation
  3. AI Rules завантажуються автоматично з docs/rules/
  4. Memory Bank доступний через @docs/rules/memory-bank/

Використання:
  - Composer: Cmd+I для чату з контекстом
  - Inline: Cmd+K для швидких правок
  - @ mentions: Посилання на файли/папки
  
Інтеграція в workflow:
  - Cursor AI може викликатися через OpenAI API
  - Workflow: cursor-ai-optimizer.json
```

### External Services

#### Shopify - E-commerce Platform
```yaml
План: Basic ($39/міс)
API Version: 2024-01

Налаштування:
  1. Settings → Apps → Develop apps
  2. Create app → Configure Admin API
  3. Permissions:
     - read_products, write_products
     - read_orders, write_orders
     - read_inventory, write_inventory
  4. Install app → Get Admin API access token

API Endpoints:
  - Get Products: GET /admin/api/2024-01/products.json
  - Create Product: POST /admin/api/2024-01/products.json
  - Update Product: PUT /admin/api/2024-01/products/{id}.json
  - Get Orders: GET /admin/api/2024-01/orders.json

Rate Limits:
  - 2 requests/second
  - Використати Retry-After header

Environment Variables:
  - SHOPIFY_STORE_URL=your-store.myshopify.com
  - SHOPIFY_ACCESS_TOKEN=shpat_xxxxx
```

#### eBay API
```yaml
Marketplace: eBay.com (продаж), eBay.de (закупівля)
API: Trading API, Finding API

Налаштування:
  1. developer.ebay.com → My Account
  2. Create Keyset → Production
  3. Get credentials:
     - App ID (Client ID)
     - Dev ID
     - Cert ID (Client Secret)
  4. Generate User Token (OAuth)

API Endpoints:
  - Finding API: svcs.ebay.com/services/search/FindingService/v1
  - Trading API: api.ebay.com/ws/api.dll

Rate Limits:
  - 5,000 calls/day (production)
  - Категорія товару: 11700 (Cameras & Photo)

Environment Variables:
  - EBAY_APP_ID=YourAppID
  - EBAY_DEV_ID=YourDevID
  - EBAY_CERT_ID=YourCertID
  - EBAY_USER_TOKEN=v^1.1.xxxxx
```


#### Cursor AI - AI IDE
```yaml
Версія: Latest
Вартість: Free (з обмеженнями) або Pro $20/міс

Налаштування:
  1. Завантажити з cursor.sh
  2. Відкрити проект:
     cursor /Users/admin/Documents/dropshipping-automation
  3. AI Rules завантажуються автоматично з docs/rules/
  4. Memory Bank доступний через @docs/rules/memory-bank/

Використання:
  - Composer: Cmd+I для чату з контекстом
  - Inline: Cmd+K для швидких правок
  - @ mentions: Посилання на файли/папки
  
Інтеграція в workflow:
  - Cursor AI може викликатися через OpenAI API
  - Workflow: cursor-ai-optimizer.json
```

### External Services

#### Shopify - E-commerce Platform
```yaml
План: Basic ($39/міс)
API Version: 2024-01

Налаштування:
  1. Settings → Apps → Develop apps
  2. Create app → Configure Admin API
  3. Permissions:
     - read_products, write_products
     - read_orders, write_orders
     - read_inventory, write_inventory
  4. Install app → Get Admin API access token

API Endpoints:
  - Get Products: GET /admin/api/2024-01/products.json
  - Create Product: POST /admin/api/2024-01/products.json
  - Update Product: PUT /admin/api/2024-01/products/{id}.json
  - Get Orders: GET /admin/api/2024-01/orders.json

Rate Limits:
  - 2 requests/second
  - Використати Retry-After header

Environment Variables:
  - SHOPIFY_STORE_URL=your-store.myshopify.com
  - SHOPIFY_ACCESS_TOKEN=shpat_xxxxx
```

#### eBay API
```yaml
Marketplace: eBay.com (продаж), eBay.de (закупівля)
API: Trading API, Finding API

Налаштування:
  1. developer.ebay.com → My Account
  2. Create Keyset → Production
  3. Get credentials:
     - App ID (Client ID)
     - Dev ID
     - Cert ID (Client Secret)
  4. Generate User Token (OAuth)

API Endpoints:
  - Finding API: svcs.ebay.com/services/search/FindingService/v1
  - Trading API: api.ebay.com/ws/api.dll

Rate Limits:
  - 5,000 calls/day (production)
  - Категорія товару: 11700 (Cameras & Photo)

Environment Variables:
  - EBAY_APP_ID=YourAppID
  - EBAY_DEV_ID=YourDevID
  - EBAY_CERT_ID=YourCertID
  - EBAY_USER_TOKEN=v^1.1.xxxxx
```

