# База Marketplaces & Accounts

## Назначение

Позволяет видеть полный ландшафт аккаунтов и их ограничений. Это важно для оценки рисков (лимиты, блокировки) и для планирования масштабирования. При большом количестве аккаунтов и площадок без подобной базы легко потерять целостное представление о том, где какие активы находятся и в каком они состоянии.

## Структура базы данных

### Основные поля

#### Platform
- **Тип**: Select
- **Описание**: Платформа
- **Варианты**: 
  - eBay US
  - eBay DE
  - Shopify
  - FB (Facebook Marketplace)
  - IG (Instagram)
  - другие платформы
- **Пример**: "eBay US"

#### Account name / Store name
- **Тип**: Текст
- **Описание**: Человекочитаемое имя/бренд (как видит пользователь)
- **Пример**: "Camera Store Pro", "my_shopify_store"

#### Login/email
- **Тип**: Текст
- **Описание**: Логин без пароля (пароль хранится в хранилище секретов)
- **Пример**: "camerastore@example.com"

#### Status
- **Тип**: Select
- **Описание**: Текущий статус аккаунта
- **Варианты**: 
  - active — активен
  - in verification — в процессе верификации
  - limited — ограничен (лимиты)
  - banned — заблокирован
  - suspended — приостановлен
- **Пример**: "active"

#### Limits
- **Тип**: Текст (длинный)
- **Описание**: Ограничения аккаунта
- **Что фиксировать**:
  - Selling limits (лимиты на продажи)
  - Ad limits (лимиты на рекламу)
  - Ограничения по категориям или регионам
  - Другие ограничения
- **Пример**: 
  - "Selling limit: 50 listings/month"
  - "Ad spend limit: $500/day"
  - "Restricted categories: Electronics > Cameras (some models)"

#### Notes
- **Тип**: Текст (длинный)
- **Описание**: Дополнительная информация
- **Что фиксировать**:
  - Баны (история)
  - Кейсы
  - Особенности политики платформы
  - История обращений в поддержку
- **Пример**: 
  - "Бан в 2023-06, причина: нарушение политики, восстановлен через 2 недели"
  - "Особенность: требует верификацию для каждой новой категории"
  - "Последний контакт с поддержкой: 2024-01-10, вопрос решён"

### Дополнительные поля

#### Created date
- **Тип**: Date
- **Описание**: Дата создания аккаунта
- **Пример**: 2023-05-15

#### Last activity
- **Тип**: Date
- **Описание**: Дата последней активности
- **Пример**: 2024-01-20

#### Total listings
- **Тип**: Number
- **Описание**: Текущее количество активных листингов
- **Пример**: 35

#### Total sales
- **Тип**: Number
- **Описание**: Общее количество продаж
- **Пример**: 127

#### Revenue (month)
- **Тип**: Number
- **Описание**: Выручка за текущий месяц
- **Пример**: 4500

#### Rating
- **Тип**: Number
- **Описание**: Рейтинг/отзывы (если применимо)
- **Пример**: 4.8/5.0

#### API Access
- **Тип**: Checkbox
- **Описание**: Есть ли API доступ
- **Пример**: ✓

#### API Status
- **Тип**: Select
- **Описание**: Статус API интеграции
- **Варианты**: 
  - connected — подключено
  - not_connected — не подключено
  - error — ошибка
- **Пример**: "connected"

## Примеры записей

### Пример 1: Активный eBay аккаунт

```
Platform: eBay US
Account name: Camera Store Pro
Login/email: camerastore@example.com
Status: active
Limits: 
  - Selling limit: 50 listings/month
  - No category restrictions
Created date: 2023-05-15
Last activity: 2024-01-20
Total listings: 35
Total sales: 127
Revenue (month): 4500
Rating: 4.8/5.0
API Access: ✓
API Status: connected
Notes: Стабильный аккаунт, без проблем. Последняя проверка лимитов: 2024-01-15
```

### Пример 2: Аккаунт в верификации

```
Platform: Shopify
Account name: my_shopify_store
Login/email: shop@example.com
Status: in verification
Limits: 
  - No limits yet (pending verification)
Created date: 2024-01-10
Last activity: 2024-01-18
Total listings: 0
Total sales: 0
Revenue (month): 0
API Access: ✓
API Status: connected
Notes: Верификация начата 2024-01-10, ожидаем ответ до 2024-01-25
```

### Пример 3: Ограниченный аккаунт

```
Platform: eBay DE
Account name: Camera Source DE
Login/email: source@example.com
Status: limited
Limits: 
  - Selling limit: 10 listings/month (reduced due to policy violation)
  - Restricted: Electronics > Cameras (some models)
Created date: 2023-08-20
Last activity: 2024-01-15
Total listings: 8
Total sales: 45
Revenue (month): 1200
Rating: 4.5/5.0
API Access: ✓
API Status: connected
Notes: 
  - Лимит снижен 2023-12-01 из-за нарушения политики
  - Обращение в поддержку отправлено 2024-01-05, ожидаем ответ
  - Планируем восстановление лимитов через улучшение рейтинга
```

## Рекомендации по использованию

1. **Регулярное обновление**: Обновляйте статусы и лимиты регулярно
2. **Мониторинг рисков**: Отслеживайте аккаунты со статусом "limited" или "in verification"
3. **История**: Ведите подробную историю в Notes для анализа паттернов
4. **Планирование**: Используйте базу для планирования масштабирования

## Интеграция с системой

База Marketplaces & Accounts интегрируется с:
- **Account-Agent** — для проверки статуса аккаунтов
- **Supabase** — таблица marketplaces синхронизируется с этой базой
- **n8n workflows** — для автоматического обновления статусов и лимитов
- **Telegram Bot** — для уведомлений о критических изменениях

## Оценка рисков

База позволяет оценивать риски:
- **Высокий риск**: banned, suspended
- **Средний риск**: limited, in verification
- **Низкий риск**: active

## Планирование масштабирования

При планировании масштабирования используйте базу для:
- Определения доступных мощностей (лимиты)
- Выявления узких мест
- Планирования создания новых аккаунтов

## См. также

- [KB_MAIN.md](KB_MAIN.md) — главная страница базы знаний
- [SECRETS_MANAGEMENT.md](SECRETS_MANAGEMENT.md) — управление секретами аккаунтов
- [Шаблон для Notion](../../templates/notion/marketplaces-template.md)

