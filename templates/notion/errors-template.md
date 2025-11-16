# Errors & Incidents - Шаблон для Notion

## Структура базы данных

Создайте базу данных в Notion со следующими свойствами:

### Свойства (Properties)

1. **Title** (Title)
   - Тип: Title
   - Описание: Краткое название инцидента

2. **Severity** (Select)
   - Тип: Select
   - Опции: critical, high, medium, low

3. **Component** (Select)
   - Тип: Select
   - Опции: AutoDS, eBay, Shopify, Meta, n8n, Supabase, OpenAI, Telegram, Other

4. **Error Type** (Select)
   - Тип: Select
   - Опции: API Error, Authentication, Data, Network, Configuration, Logic, Other

5. **Status** (Select)
   - Тип: Select
   - Опции: open, investigating, resolved, closed

6. **Date occurred** (Date)
   - Тип: Date
   - Описание: Когда произошёл инцидент

7. **Date resolved** (Date)
   - Тип: Date
   - Описание: Когда был решён инцидент

8. **Impact** (Text)
   - Тип: Text
   - Описание: Влияние на бизнес

9. **Created** (Created time)
   - Тип: Created time

10. **Last updated** (Last edited time)
    - Тип: Last edited time

## Структура страницы

Каждая запись должна содержать следующие разделы:

### Description
[Подробное описание инцидента]

### Error Message
[Точное сообщение об ошибке]

### Stack Trace / Logs
```
[Stack trace или логи]
```

### Impact
[Влияние на бизнес]

### Root Cause
[Корневая причина инцидента]

### Resolution
[Как была решена проблема]

### Prevention
[Меры для предотвращения повторения]

### Related Items
- [Связанные элементы]

## Представления (Views)

### 1. Все инциденты (Table)
- Тип: Table
- Сортировка: Date occurred (по убыванию)

### 2. Открытые (Table)
- Тип: Table
- Фильтр: Status = open OR Status = investigating
- Сортировка: Severity, затем Date occurred (по убыванию)

### 3. По серьёзности (Board)
- Тип: Board
- Группировка: Severity
- Фильтр: Status = open OR Status = investigating

### 4. По компонентам (Board)
- Тип: Board
- Группировка: Component
- Фильтр: Status = resolved
- Сортировка: Date occurred (по убыванию)

### 5. Решённые (Table)
- Тип: Table
- Фильтр: Status = resolved
- Сортировка: Date resolved (по убыванию)

### 6. Критические (Table)
- Тип: Table
- Фильтр: Severity = critical
- Сортировка: Date occurred (по убыванию)

## Пример записи

```
Title: AutoDS failed to place order
Severity: high
Component: AutoDS
Error Type: API Error
Status: resolved
Date occurred: 2024-01-20
Date resolved: 2024-01-20

Impact: 1 заказ не был размещён, клиент получил уведомление об отмене. Потеря потенциальной прибыли: €150.

---

## Description
AutoDS не смог разместить заказ для товара Sony A7III. Заказ был создан в системе, но AutoDS вернул ошибку при попытке размещения заказа у поставщика.

## Error Message
Error 500: Internal server error

## Stack Trace / Logs
[логи из n8n]

## Root Cause
Временный сбой на стороне AutoDS API, возможно из-за высокой нагрузки.

## Resolution
Повторная попытка через 5 минут успешно разместила заказ. Добавлен retry механизм в n8n workflow.

## Prevention
- Добавлен retry с exponential backoff в n8n workflow
- Добавлено уведомление в Telegram при ошибках AutoDS
- Создан мониторинг доступности AutoDS API

## Related Items
- Order: [Order #12345]
- n8n workflow: [order-fulfillment.json]
```

