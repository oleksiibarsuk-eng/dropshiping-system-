# Tech & API Docs - Шаблон для Notion

## Структура базы данных

Создайте базу данных в Notion со следующими свойствами:

### Свойства (Properties)

1. **Title** (Title)
   - Тип: Title
   - Описание: Название документации

2. **Category** (Select)
   - Тип: Select
   - Опции: API, Infrastructure, Database, Workflow, Configuration, Other

3. **Platform/Service** (Select)
   - Тип: Select
   - Опции: eBay, Shopify, Meta, AutoDS, n8n, Supabase, OpenAI, Telegram, Other

4. **Description** (Text)
   - Тип: Text
   - Описание: Краткое описание что документируется

5. **Authentication** (Text)
   - Тип: Text
   - Описание: Метод аутентификации

6. **Rate Limits** (Text)
   - Тип: Text
   - Описание: Ограничения по частоте запросов

7. **Version** (Number)
   - Тип: Number
   - Описание: Версия документации

8. **Status** (Select)
   - Тип: Select
   - Опции: current, outdated, deprecated

9. **Last updated** (Date)
   - Тип: Date
   - Описание: Дата последнего обновления

10. **Related files** (Text)
    - Тип: Text
    - Описание: Ссылки на связанные файлы в репозитории

11. **Created** (Created time)
    - Тип: Created time

## Структура страницы

Каждая запись должна содержать следующие разделы:

### Description
[Краткое описание что документируется]

### API Endpoints
- [Endpoint 1]
- [Endpoint 2]
...

### Authentication
[Метод аутентификации]

### Rate Limits
[Ограничения по частоте запросов]

### Request Example
```json
{
  "example": "request"
}
```

### Response Example
```json
{
  "example": "response"
}
```

### Error Handling
[Как обрабатываются ошибки]

### Related Files
- Code: [ссылка]
- Config: [ссылка]
- Docs: [ссылка]

## Представления (Views)

### 1. Вся документация (Table)
- Тип: Table
- Сортировка: Platform/Service, затем Category

### 2. Актуальная (Table)
- Тип: Table
- Фильтр: Status = current
- Сортировка: Last updated (по убыванию)

### 3. По платформам (Board)
- Тип: Board
- Группировка: Platform/Service
- Фильтр: Status = current

### 4. По категориям (Board)
- Тип: Board
- Группировка: Category
- Фильтр: Status = current

### 5. Устаревшая (Table)
- Тип: Table
- Фильтр: Status = outdated OR Status = deprecated
- Сортировка: Last updated (по убыванию)

## Пример записи

```
Title: eBay API - Listing Creation
Category: API
Platform/Service: eBay
Description: Интеграция с eBay API для создания листингов через n8n

Authentication: OAuth 2.0, User Token (получается через OAuth flow)
Rate Limits: 5000 calls/day, 5 calls/second

Version: 1.2
Status: current
Last updated: 2024-01-20

Related files:
  - n8n workflow: n8n-workflows/listing-creation.json
  - Config: config/ebay-config.json
  - Setup guide: docs/SETUP_EBAY.md

---

## API Endpoints
- POST /sell/inventory/v1/offer (create listing)
- GET /sell/inventory/v1/offer/{offerId} (get listing)
- PUT /sell/inventory/v1/offer/{offerId} (update listing)

## Request Example
```json
POST https://api.ebay.com/sell/inventory/v1/offer
Headers:
  Authorization: Bearer {USER_TOKEN}
  Content-Type: application/json

Body:
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
  }
}
```

## Response Example
```json
{
  "offerId": "123456789",
  "warnings": []
}
```

## Error Handling
- 429 (Rate Limit): Wait and retry
- 400 (Bad Request): Log error, notify via Telegram
- 401 (Unauthorized): Refresh token
```

