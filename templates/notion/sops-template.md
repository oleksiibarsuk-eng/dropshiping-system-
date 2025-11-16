# SOPs & Playbooks - Шаблон для Notion

## Структура базы данных

Создайте базу данных в Notion со следующими свойствами:

### Свойства (Properties)

1. **Title** (Title)
   - Тип: Title
   - Описание: Название процедуры или сценария

2. **Type** (Select)
   - Тип: Select
   - Опции: SOP, Playbook

3. **Category** (Select)
   - Тип: Select
   - Опции: Listing, Order, Support, Compliance, Troubleshooting, Other

4. **Goal** (Text)
   - Тип: Text
   - Описание: Цель процедуры

5. **Prerequisites** (Text)
   - Тип: Text
   - Описание: Что нужно иметь/знать перед выполнением

6. **Estimated time** (Number)
   - Тип: Number
   - Описание: Ориентировочное время выполнения (минуты)

7. **Status** (Select)
   - Тип: Select
   - Опции: draft, active, outdated, archived

8. **Version** (Number)
   - Тип: Number
   - Описание: Версия процедуры

9. **Author** (Person)
   - Тип: Person
   - Описание: Автор процедуры

10. **Last updated** (Date)
    - Тип: Date
    - Описание: Дата последнего обновления

11. **Related workflows** (Text)
    - Тип: Text
    - Описание: Ссылки на n8n воркфлоу, API докам, скрипты

12. **Created** (Created time)
    - Тип: Created time

## Структура страницы

Каждая запись должна содержать следующие разделы:

### Goal
[Цель процедуры и критерии успеха]

### Prerequisites
[Что нужно иметь/знать перед выполнением]

### Steps
1. [Шаг 1]
2. [Шаг 2]
3. [Шаг 3]
...

### Screenshots / Templates
[Скриншоты, шаблоны сообщений, ссылки на формы]

### Related Workflows
- n8n workflow: [ссылка]
- API Docs: [ссылка]
- Script: [ссылка]

## Представления (Views)

### 1. Все процедуры (Table)
- Тип: Table
- Сортировка: Category, затем Title

### 2. Активные (Table)
- Тип: Table
- Фильтр: Status = active
- Сортировка: Category

### 3. По категориям (Board)
- Тип: Board
- Группировка: Category
- Фильтр: Status = active

### 4. По типу (Board)
- Тип: Board
- Группировка: Type
- Фильтр: Status = active

### 5. Устаревшие (Table)
- Тип: Table
- Фильтр: Status = outdated
- Сортировка: Last updated (по убыванию)

## Пример записи

```
Title: Создание нового лота на eBay US
Type: SOP
Category: Listing
Goal: Создать новый листинг на eBay US с соблюдением всех требований платформы. Критерий успеха: листинг опубликован и проходит проверку Compliance-Agent.

Prerequisites: Активный аккаунт eBay US, готовый товар с описанием и фото

Estimated time: 15

Status: active
Version: 1.3
Author: [Иван Иванов]
Last updated: 2024-01-20

Related workflows: 
  - n8n: listing-creation.json
  - Compliance check: compliance-agent.md

---

## Steps

1. Открыть eBay Seller Hub
2. Выбрать "Sell an item"
3. Ввести название товара (использовать шаблон из KB_TECH_DOCS)
4. Выбрать категорию (Cameras & Photo > Digital Cameras)
5. Заполнить Item Specifics (Brand, Model, Megapixels, Sensor Type)
6. Добавить описание (использовать шаблон, проверить через Compliance-Agent)
7. Загрузить фото (минимум 5, первое фото — главное)
8. Установить цену (использовать Pricing-Agent для проверки)
9. Выбрать Business Policy (Payment, Shipping, Returns)
10. Проверить через Compliance-Agent
11. Опубликовать листинг

## Screenshots
[Скриншот Seller Hub], [Скриншот Item Specifics]

## Related Workflows
- n8n: [listing-creation.json]
- Compliance check: [compliance-agent.md]
```

