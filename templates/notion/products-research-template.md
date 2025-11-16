# Products Research - Шаблон для Notion

## Структура базы данных

Создайте базу данных в Notion со следующими свойствами:

### Свойства (Properties)

1. **Name** (Title)
   - Тип: Title
   - Описание: Название товара

2. **Category** (Select)
   - Тип: Select
   - Опции: cameras, lenses, accessories, collectibles, other

3. **Niche/Use-case** (Text)
   - Тип: Text
   - Описание: Целевая аудитория и сценарий использования

4. **Source marketplace** (Select)
   - Тип: Select
   - Опции: eBay.de, японские площадки, локальные магазины, другие источники

5. **Source link** (URL)
   - Тип: URL
   - Описание: Исходная ссылка на товар

6. **Source price** (Number)
   - Тип: Number
   - Формат: Currency (EUR)

7. **Source price date** (Date)
   - Тип: Date
   - Описание: Дата фиксации цены

8. **Target marketplace** (Multi-select)
   - Тип: Multi-select
   - Опции: eBay US, Shopify, FB Marketplace, другие платформы

9. **Target price** (Number)
   - Тип: Number
   - Формат: Currency (USD)

10. **Estimated margin %** (Number)
    - Тип: Number
    - Формат: Percent

11. **Estimated margin €** (Number)
    - Тип: Number
    - Формат: Currency (EUR)

12. **Demand signals** (Text)
    - Тип: Text
    - Описание: Сигналы спроса

13. **Impact** (Number)
    - Тип: Number
    - Описание: Ожидаемое влияние на бизнес (1-5)

14. **Confidence** (Number)
    - Тип: Number
    - Описание: Уверенность в успехе (1-5)

15. **Effort** (Number)
    - Тип: Number
    - Описание: Сложность реализации (1-5)

16. **Priority Score** (Formula)
    - Тип: Formula
    - Формула: `(prop("Impact") * prop("Confidence")) / prop("Effort")`

17. **Status** (Select)
    - Тип: Select
    - Опции: idea, testing, active, rejected

18. **Notes** (Text)
    - Тип: Text
    - Описание: Специфика товара, потенциальные риски

19. **Created** (Created time)
    - Тип: Created time

20. **Last updated** (Last edited time)
    - Тип: Last edited time

## Представления (Views)

### 1. Все товары (Table)
- Тип: Table
- Сортировка: Priority Score (по убыванию)

### 2. Активные (Table)
- Тип: Table
- Фильтр: Status = active
- Сортировка: Last updated (по убыванию)

### 3. Тестируемые (Table)
- Тип: Table
- Фильтр: Status = testing
- Сортировка: Priority Score (по убыванию)

### 4. Идеи (Board)
- Тип: Board
- Группировка: Category
- Фильтр: Status = idea
- Сортировка: Priority Score (по убыванию)

## Пример записи

```
Name: Sony A7III
Category: cameras
Niche/Use-case: профессиональная съёмка, travel‑контент
Source marketplace: eBay.de
Source link: https://www.ebay.de/itm/sony-a7iii
Source price: 1200 EUR
Source price date: 2024-01-15
Target marketplace: eBay US, Shopify
Target price: 1800 USD
Estimated margin %: 35%
Estimated margin €: 420 EUR
Demand signals: 25-30 продаж/месяц на eBay US, стабильный спрос
Impact: 4
Confidence: 4
Effort: 2
Priority Score: 8.0
Status: active
Notes: Высокий спрос, стабильная маржа, надёжные поставщики
```

