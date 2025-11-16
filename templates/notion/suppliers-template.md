# Suppliers - Шаблон для Notion

## Структура базы данных

Создайте базу данных в Notion со следующими свойствами:

### Свойства (Properties)

1. **Supplier name** (Title)
   - Тип: Title
   - Описание: Наименование поставщика

2. **Type** (Select)
   - Тип: Select
   - Опции: магазин, частный продавец, платформа, оптовик

3. **Country/Region** (Select)
   - Тип: Select
   - Опции: Германия, Япония, США, другие

4. **Link** (URL)
   - Тип: URL
   - Описание: Ссылка на сайт/профиль

5. **Email** (Email)
   - Тип: Email
   - Описание: Контактный email

6. **Products** (Relation)
   - Тип: Relation
   - Связь: Products Research
   - Описание: Связанные товары

7. **Average handling time** (Number)
   - Тип: Number
   - Описание: Среднее время обработки заказов (дни)

8. **Shipping methods** (Text)
   - Тип: Text
   - Описание: Доступные способы доставки и стоимости

9. **Return policy** (Text)
   - Тип: Text
   - Описание: Политика возвратов

10. **Reliability score** (Number)
    - Тип: Number
    - Описание: Рейтинг надёжности (1-5)

11. **Reliability comment** (Text)
    - Тип: Text
    - Описание: Комментарий к рейтингу

12. **Last order date** (Date)
    - Тип: Date
    - Описание: Дата последнего заказа

13. **Total orders** (Number)
    - Тип: Number
    - Описание: Общее количество заказов

14. **Success rate** (Number)
    - Тип: Number
    - Формат: Percent
    - Описание: Процент успешных заказов

15. **Status** (Select)
    - Тип: Select
    - Опции: active, testing, paused, blocked

16. **Notes** (Text)
    - Тип: Text
    - Описание: Зафиксированные кейсы, особенности коммуникации

17. **Created** (Created time)
    - Тип: Created time

18. **Last updated** (Last edited time)
    - Тип: Last edited time

## Представления (Views)

### 1. Все поставщики (Table)
- Тип: Table
- Сортировка: Reliability score (по убыванию)

### 2. Активные (Table)
- Тип: Table
- Фильтр: Status = active
- Сортировка: Reliability score (по убыванию)

### 3. По странам (Board)
- Тип: Board
- Группировка: Country/Region
- Фильтр: Status = active

### 4. Надёжные (Table)
- Тип: Table
- Фильтр: Reliability score >= 4 AND Status = active
- Сортировка: Total orders (по убыванию)

## Пример записи

```
Supplier name: Camera Store Berlin
Type: магазин
Country/Region: Германия
Link: https://camerastore.de
Email: info@camerastore.de
Products: [Sony A7III, Canon EF 50mm]
Average handling time: 1
Shipping methods: DHL Standard €20 (5-7 дней), Express €40 (2-3 дня)
Return policy: 14 дней, покупатель оплачивает доставку
Reliability score: 5
Reliability comment: Очень надёжный, быстрая обработка, качественная упаковка
Last order date: 2024-01-20
Total orders: 25
Success rate: 100%
Status: active
Notes: Всегда быстро отвечает на вопросы. Специальная скидка 5% при заказе от 3 товаров.
```

