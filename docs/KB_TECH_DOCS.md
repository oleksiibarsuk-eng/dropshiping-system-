# База Tech & API Docs

## Назначение

Техническая документация по интеграциям и инфраструктуре. Она нужна для того, чтобы любые изменения в коде, воркфлоу и конфигурации не оставались «только в головах», а фиксировались в систематизированном виде. При активном использовании AI‑инструментов и оркестраторов такая документация становится критически важной для поддержки и развития системы.

## Структура базы данных

### Основные поля

#### Title
- **Тип**: Текст
- **Описание**: Название документации
- **Пример**: "eBay API Integration", "Supabase Schema v2"

#### Category
- **Тип**: Select
- **Описание**: Категория документации
- **Варианты**: 
  - API — документация по API
  - Infrastructure — инфраструктура
  - Database — база данных
  - Workflow — воркфлоу
  - Configuration — конфигурация
  - Other — другое
- **Пример**: "API"

#### Platform/Service
- **Тип**: Select
- **Описание**: Платформа или сервис
- **Варианты**: 
  - eBay
  - Shopify
  - Meta
  - AutoDS
  - n8n
  - Supabase
  - OpenAI
  - Telegram
  - Other
- **Пример**: "eBay"

#### Description
- **Тип**: Текст (длинный)
- **Описание**: Краткое описание что документируется
- **Пример**: "Интеграция с eBay API для создания листингов и управления заказами"

#### Content
- **Тип**: Текст (очень длинный) или Markdown
- **Описание**: Содержимое документации
- **Может включать**:
  - Endpoints
  - Параметры запросов
  - Примеры кода
  - Схемы данных
  - Диаграммы
- **Пример**: [Markdown с примерами кода]

#### API Endpoints
- **Тип**: Текст (длинный)
- **Описание**: Список используемых API endpoints
- **Пример**: 
  - POST /sell/inventory/v1/offer
  - GET /sell/account/v1/return_policy

#### Authentication
- **Тип**: Текст
- **Описание**: Метод аутентификации
- **Пример**: "OAuth 2.0, User Token required"

#### Rate Limits
- **Тип**: Текст
- **Описание**: Ограничения по частоте запросов
- **Пример**: "5000 calls per day, 5 calls per second"

#### Error Handling
- **Тип**: Текст (длинный)
- **Описание**: Как обрабатываются ошибки
- **Пример**: "Retry with exponential backoff, log to Supabase errors table"

#### Related Files
- **Тип**: Links
- **Описание**: Ссылки на связанные файлы в репозитории
- **Пример**: 
  - Code: [n8n-workflows/ebay-listing.json]
  - Config: [config/ebay-config.json]
  - Docs: [docs/SETUP_EBAY.md]

#### Version
- **Тип**: Number
- **Описание**: Версия документации
- **Пример**: 1.0

#### Last updated
- **Тип**: Date
- **Описание**: Дата последнего обновления
- **Пример**: 2024-01-20

#### Status
- **Тип**: Select
- **Описание**: Статус документации
- **Варианты**: 
  - current — актуальна
  - outdated — устарела
  - deprecated — устарела и не используется
- **Пример**: "current"

## Примеры записей

### Пример 1: API документация

```
Title: eBay API - Listing Creation
Category: API
Platform/Service: eBay
Description: Интеграция с eBay API для создания листингов через n8n

Content:
## Endpoint
POST https://api.ebay.com/sell/inventory/v1/offer

## Headers
Authorization: Bearer {USER_TOKEN}
Content-Type: application/json

## Request Body
{
  "sku": "CAMERA-001",
  "marketplaceId": "EBAY_US",
  "format": "FIXED_PRICE",
  "listingDescription": "...",
  "pricingSummary": {
    "price": {
      "value": "650.00",
      "currency": "USD"
    }
  },
  ...
}

## Response
{
  "offerId": "123456789",
  "warnings": []
}

API Endpoints:
  - POST /sell/inventory/v1/offer (create listing)
  - GET /sell/inventory/v1/offer/{offerId} (get listing)
  - PUT /sell/inventory/v1/offer/{offerId} (update listing)

Authentication: OAuth 2.0, User Token (получается через OAuth flow)
Rate Limits: 5000 calls/day, 5 calls/second
Error Handling: 
  - 429 (Rate Limit): Wait and retry
  - 400 (Bad Request): Log error, notify via Telegram
  - 401 (Unauthorized): Refresh token

Related Files:
  - n8n workflow: [n8n-workflows/listing-creation.json]
  - Config: [config/ebay-config.json]
  - Setup guide: [docs/SETUP_EBAY.md]

Version: 1.2
Last updated: 2024-01-20
Status: current
```

### Пример 2: Database схема

```
Title: Supabase Schema - Products Table
Category: Database
Platform/Service: Supabase
Description: Схема таблицы products в Supabase

Content:
## Table: products

```sql
CREATE TABLE products (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name TEXT NOT NULL,
  sku TEXT UNIQUE,
  category TEXT,
  source_marketplace TEXT,
  source_price DECIMAL(10,2),
  target_marketplace TEXT,
  target_price DECIMAL(10,2),
  margin_percent DECIMAL(5,2),
  status TEXT DEFAULT 'idea',
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_products_status ON products(status);
CREATE INDEX idx_products_category ON products(category);
```

## Relationships
- products → listings (one-to-many)
- products → price_logs (one-to-many)

## Triggers
- updated_at автоматически обновляется при изменении записи

Related Files:
  - Migration: [scripts/setup/migrations/001_create_products.sql]
  - Setup: [docs/SETUP_SUPABASE.md]

Version: 1.0
Last updated: 2024-01-15
Status: current
```

### Пример 3: Workflow документация

```
Title: n8n Workflow - Product Sourcing
Category: Workflow
Platform/Service: n8n
Description: Workflow для поиска товаров через AutoDS и анализа через OpenAI

Content:
## Workflow Overview
1. Trigger: Manual или Cron (ежедневно в 02:00)
2. AutoDS API: Поиск товаров по критериям
3. OpenAI API: Анализ спроса и маржи
4. Supabase: Сохранение результатов
5. Telegram: Уведомление о найденных товарах

## Nodes
- HTTP Request (AutoDS)
- OpenAI (GPT-4)
- Supabase (Insert)
- Telegram (Send Message)

## Configuration
- AutoDS API Key: из secrets
- OpenAI API Key: из secrets
- Supabase credentials: из secrets

## Error Handling
- Retry: 3 attempts
- On error: Log to Supabase errors table, notify via Telegram

Related Files:
  - Workflow JSON: [n8n-workflows/product-sourcing.json]
  - Setup: [docs/SETUP_N8N.md]

Version: 2.1
Last updated: 2024-01-18
Status: current
```

## Рекомендации по использованию

1. **Регулярное обновление**: Обновляйте документацию при каждом изменении кода или конфигурации
2. **Версионирование**: Отслеживайте версии документации
3. **Примеры**: Всегда включайте рабочие примеры
4. **Связность**: Связывайте документацию с кодом и конфигурациями

## Интеграция с системой

База Tech & API Docs интегрируется с:
- **Репозиторий** — ссылки на код и конфигурации
- **n8n workflows** — документация воркфлоу
- **AI агенты** — для использования в разработке
- **Onboarding** — для обучения новых разработчиков

## См. также

- [KB_MAIN.md](KB_MAIN.md) — главная страница базы знаний
- [SETUP_*.md](SETUP_EBAY.md) — гайды по настройке платформ
- [Шаблон для Notion](../../templates/notion/tech-docs-template.md)

