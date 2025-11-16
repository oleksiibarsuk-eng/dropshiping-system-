# Marketplaces & Accounts - Шаблон для Notion

## Структура базы данных

Создайте базу данных в Notion со следующими свойствами:

### Свойства (Properties)

1. **Platform** (Select)
   - Тип: Select
   - Опции: eBay US, eBay DE, Shopify, FB, IG, другие платформы

2. **Account name** (Title)
   - Тип: Title
   - Описание: Человекочитаемое имя/бренд

3. **Login/email** (Text)
   - Тип: Text
   - Описание: Логин без пароля

4. **Status** (Select)
   - Тип: Select
   - Опции: active, in verification, limited, banned, suspended

5. **Limits** (Text)
   - Тип: Text
   - Описание: Ограничения аккаунта

6. **Created date** (Date)
   - Тип: Date
   - Описание: Дата создания аккаунта

7. **Last activity** (Date)
   - Тип: Date
   - Описание: Дата последней активности

8. **Total listings** (Number)
   - Тип: Number
   - Описание: Текущее количество активных листингов

9. **Total sales** (Number)
   - Тип: Number
   - Описание: Общее количество продаж

10. **Revenue (month)** (Number)
    - Тип: Number
    - Формат: Currency (USD)
    - Описание: Выручка за текущий месяц

11. **Rating** (Number)
    - Тип: Number
    - Описание: Рейтинг/отзывы (если применимо)

12. **API Access** (Checkbox)
    - Тип: Checkbox
    - Описание: Есть ли API доступ

13. **API Status** (Select)
    - Тип: Select
    - Опции: connected, not_connected, error

14. **Notes** (Text)
    - Тип: Text
    - Описание: Баны, кейсы, особенности политики платформы

15. **Created** (Created time)
    - Тип: Created time

16. **Last updated** (Last edited time)
    - Тип: Last edited time

## Представления (Views)

### 1. Все аккаунты (Table)
- Тип: Table
- Сортировка: Platform, затем Account name

### 2. Активные (Table)
- Тип: Table
- Фильтр: Status = active
- Сортировка: Revenue (month) (по убыванию)

### 3. По платформам (Board)
- Тип: Board
- Группировка: Platform
- Фильтр: Status = active

### 4. Проблемные (Table)
- Тип: Table
- Фильтр: Status = limited OR Status = in verification OR Status = banned
- Сортировка: Last activity (по убыванию)

### 5. По статусу (Board)
- Тип: Board
- Группировка: Status
- Сортировка: Last activity (по убыванию)

## Пример записи

```
Platform: eBay US
Account name: Camera Store Pro
Login/email: camerastore@example.com
Status: active
Limits: Selling limit: 50 listings/month, No category restrictions
Created date: 2023-05-15
Last activity: 2024-01-20
Total listings: 35
Total sales: 127
Revenue (month): 4500 USD
Rating: 4.8
API Access: ✓
API Status: connected
Notes: Стабильный аккаунт, без проблем. Последняя проверка лимитов: 2024-01-15
```

