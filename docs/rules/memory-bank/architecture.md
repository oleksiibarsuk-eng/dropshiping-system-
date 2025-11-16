# Architecture - Архітектура системи

## Загальна архітектура

### High-Level Overview

```
┌─────────────────────────────────────────────────────────────┐
│                     User (Entrepreneur)                      │
│                    Telegram Interface                        │
└────────────────────┬────────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────────┐
│                   n8n Orchestrator                           │
│              (Workflow Automation Engine)                    │
│                                                              │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐     │
│  │  Planner     │  │ Multi-Source │  │  Compliance  │     │
│  │   Agent      │  │    Agent     │  │    Agent     │     │
│  └──────────────┘  └──────────────┘  └──────────────┘     │
│                                                              │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐     │
│  │   Listing    │  │   Pricing    │  │     Ops      │     │
│  │    Agent     │  │    Agent     │  │    Agent     │     │
│  └──────────────┘  └──────────────┘  └──────────────┘     │
│                                                              │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐     │
│  │  Reputation  │  │  Analytics   │  │  Cursor AI   │     │
│  │    Agent     │  │    Agent     │  │    Agent     │     │
│  └──────────────┘  └──────────────┘  └──────────────┘     │
└────────┬────────────────────┬─────────────────┬────────────┘
         │                    │                 │
         ▼                    ▼                 ▼
┌─────────────────┐  ┌─────────────────┐  ┌──────────────┐
│   OpenAI API    │  │    Supabase     │  │  Cursor AI   │
│   (GPT-4 LLM)   │  │   (Database)    │  │   (AI IDE)   │
└─────────────────┘  └─────────────────┘  └──────────────┘
         │                    │
         ▼                    ▼
┌─────────────────────────────────────────────────────────────┐
│                    External Services                         │
│                                                              │
│  Shopify API  │  eBay API  │  AutoDS API  │  Meta API     │
│  DSM Tool     │  Telegram  │  GitHub      │  Sentry       │
└─────────────────────────────────────────────────────────────┘
```


## Структура агентів (Tier 1: MVP)

### 1. Planner-Agent
**Роль**: Декомпозиція задач та побудова плану  
**Тригер**: Ручний (через Telegram команду) або Schedule  
**Вхід**: Мета користувача, бюджет, обмеження  
**Вихід**: Список підзадач для інших агентів  

```yaml
Workflow:
  1. Отримати запит від користувача
  2. Проаналізувати через GPT-4
  3. Згенерувати план дій
  4. Розподілити підзадачі по агентах
  5. Відправити план в Telegram для підтвердження
```

### 2. Multi-Sourcing-Agent
**Роль**: Пошук товарів у декількох постачальників  
**Тригер**: Schedule (щодня) або Manual  
**Вхід**: Категорія товарів, фільтри, ліміти  
**Вихід**: Список прибуткових товарів з альтернативними джерелами  

```yaml
Workflow:
  1. Паралельний пошук у AutoDS + DSM
  2. Порівняння цін та надійності
  3. Фільтрація по маржі > 25%
  4. Створення таблиці альтернатив
  5. Відправка результатів до Listing-Agent
```

### 3. Compliance-Agent
**Роль**: Валідація лістингів перед публікацією  
**Тригер**: Webhook від Listing-Agent  
**Вхід**: Згенерований лістинг (title, description, category, price)  
**Вихід**: Статус валідації + рекомендації  

```yaml
Workflow:
  1. Отримати лістинг від Listing-Agent
  2. Перевірити через GPT-4 по чек-листу
  3. Оцінити ризик (low/medium/high)
  4. Якщо high → запит підтвердження в Telegram
  5. Якщо low/medium → автопублікація
```

### 4. Listing-Agent
**Роль**: Створення лістингів на всіх платформах  
**Тригер**: Webhook від Multi-Sourcing-Agent  
**Вхід**: Товар з даними (title, price, images)  
**Вихід**: Опубліковані лістинги на Shopify + eBay  

```yaml
Workflow:
  1. Отримати товар
  2. Згенерувати SEO-тексти через GPT-4
  3. Відправити на Compliance-Agent
  4. Після апруву → створити в Shopify API
  5. Синхронізувати з eBay через AutoDS
  6. Зберегти SKU в Supabase
```


### 5. Pricing-Agent
**Роль**: Розумне ціноутворення з моніторингом конкурентів  
**Тригер**: Schedule (щодня о 06:00) або Manual  
**Вхід**: Список активних товарів  
**Вихід**: Оновлені ціни на всіх платформах  

```yaml
Workflow:
  1. Отримати список товарів з Supabase
  2. Паралельно парсити ціни конкурентів (eBay Finding API)
  3. Обчислити оптимальну ціну (базове правило + конкуренція)
  4. Застосувати зміни через Shopify/eBay API
  5. Якщо демпінг → сховати лістинг + алерт
  6. Зберегти історію в Supabase
```

### 6. Ops-Agent
**Роль**: Автоматичне виконання замовлень  
**Тригер**: Webhook від Shopify (нове замовлення)  
**Вхід**: Order ID, товари, адреса доставки  
**Вихід**: Замовлення у постачальника + tracking number  

```yaml
Workflow:
  1. Отримати webhook від Shopify
  2. Перевірити наявність товару в AutoDS
  3. Автоматично зробити замовлення
  4. Отримати tracking number
  5. Оновити статус в Shopify
  6. Відправити трекінг клієнту
  7. Алерт в Telegram про успіх
```

### 7. Reputation-Agent
**Роль**: Моніторинг репутації та проактивна підтримка  
**Тригер**: Schedule (кожні 6 годин) або Event (негативний відгук)  
**Вхід**: Метрики eBay/Shopify, відгуки, спори  
**Вихід**: Автовідповіді клієнтам + алерти  

```yaml
Workflow:
  1. Отримати метрики через API (Defect Rate, Feedback Score)
  2. Якщо > threshold → критичний алерт
  3. Моніторити трекінг замовлень
  4. Якщо затримка > 10 днів → проактивний лист клієнту
  5. При негативному відгуку → автошаблон + алерт вам
  6. Зберегти історію в Supabase
```

### 8. Analytics-Agent
**Роль**: Збір статистики та генерація звітів  
**Тригер**: Schedule (щодня о 08:00)  
**Вхід**: Дані з Supabase (продажі, витрати, маржа)  
**Вихід**: Щоденний звіт в Telegram  

```yaml
Workflow:
  1. Агрегувати дані за 24 години
  2. Розрахувати KPI (ROI, середня маржа, конверсія)
  3. Згенерувати візуалізації
  4. Відправити звіт в Telegram
  5. Зберегти в Google Sheets для історії
```


### 9. Cursor AI Agent (Спеціальний)
**Роль**: Оптимізація та розробка інших агентів  
**Тригер**: Manual або Webhook (performance < threshold)  
**Вхід**: Код агента, логи помилок, запит на оптимізацію  
**Вихід**: Оптимізований код, документація, тести  

```yaml
Workflow:
  1. Отримати запит на оптимізацію
  2. Завантажити Memory Bank для контексту
  3. Викликати GPT-4 з промптом "Ти - Cursor AI"
  4. Згенерувати оптимізовану версію коду
  5. Створити unit tests
  6. Оновити документацію
  7. Commit в GitHub + PR
  8. Відправити на апрув в Telegram
```

## Ключові технічні рішення

### 1. Чому n8n, а не custom code?
- ✅ Візуальний редактор → швидша розробка
- ✅ Вбудовані інтеграції → менше boilerplate
- ✅ Легке дебагування → візуальні логи
- ✅ Горизонтальне масштабування
- ❌ Складні алгоритми → все одно потрібен code node

### 2. Чому Supabase, а не MySQL/Mongo?
- ✅ PostgreSQL + REST API out of the box
- ✅ Realtime subscriptions для моніторингу
- ✅ Row Level Security для безпеки
- ✅ Безкоштовний tier до 500MB
- ✅ Вбудована авторизація

### 3. Чому GPT-4, а не Claude/Gemini?
- ✅ Найкраща якість structured outputs
- ✅ Function calling для агентів
- ✅ Найбільший context window (128K)
- ✅ Стабільний API
- ❌ Дорожче (~$0.01/1K tokens)

### 4. Чому Cursor AI інтеграція?
- ✅ Автоматична оптимізація промптів
- ✅ AI-driven debugging
- ✅ Швидке створення нових агентів
- ✅ A/B тестування змін
- ✅ Зменшення часу розробки на 70%

## Design Patterns

### 1. Agent Communication Pattern
```
Тригер → Agent A → Webhook → Agent B → Result → Telegram
```
Агенти спілкуються тільки через webhooks, без прямих викликів.

### 2. Error Handling Pattern
```
Try:
  Execute workflow
Catch:
  Log error to Supabase
  Send alert to Telegram
  Trigger Cursor AI Auto-Debug
  Retry with exponential backoff
```


### 3. State Management Pattern
```yaml
Кожен агент зберігає стан в Supabase:
  - Execution ID
  - Timestamp
  - Input data
  - Output data
  - Status (pending/success/failed)
  - Error logs

Це дозволяє:
  - Replay failed workflows
  - Audit trail
  - Analytics
```

### 4. Security Pattern
```yaml
Sensitive data (API keys, tokens):
  - Зберігаються в n8n Credentials (encrypted)
  - НІКОЛИ не логуються
  - Доступ через environment variables
  
Rate Limiting:
  - OpenAI: 3 requests per minute (starter tier)
  - eBay: 5000 calls/day
  - Shopify: 2 calls/second
  - Exponential backoff при 429 errors
```

## Критичні шляхи реалізації

### 1. Product Sourcing → Listing Flow
```
User Command (/find_products cameras 5)
  ↓
Planner-Agent (розбиває на queries)
  ↓
Multi-Sourcing-Agent (паралельний пошук)
  ↓
Filter by Margin (code node)
  ↓
Listing-Agent (генерує тексти)
  ↓
Compliance-Agent (валідує)
  ↓ (якщо low/medium risk)
Shopify API (створює product)
  ↓
AutoDS API (додає до import list)
  ↓
Telegram (success notification)
```

### 2. Order Fulfillment Flow
```
Shopify Webhook (new order)
  ↓
Ops-Agent (отримує замовлення)
  ↓
Check Stock в AutoDS
  ↓
Auto-order у постачальника
  ↓
Get Tracking Number
  ↓
Update Shopify Order Status
  ↓
Send Tracking to Customer (email)
  ↓
Telegram (confirmation)
  ↓
Supabase (log for analytics)
```

### 3. Error Recovery Flow
```
Agent Error
  ↓
Log to Supabase
  ↓
Critical Alert to Telegram
  ↓
Cursor AI Auto-Debug (аналіз логів)
  ↓
Generate Fix
  ↓
Create PR on GitHub
  ↓
User Approval через Telegram
  ↓
Auto-deploy if approved
  ↓
Retry original operation
```

## Source Code Paths

```
/Users/admin/Documents/dropshipping-automation/
├── docs/                           # Вся документація
├── n8n-workflows/                  # JSON експорти workflows
├── prompts/                        # Промпти для агентів
├── scripts/setup/                  # Скрипти початкової настройки
├── scripts/monitoring/             # Скрипти моніторингу
└── config/                         # Конфігураційні файли
```
