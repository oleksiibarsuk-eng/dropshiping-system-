# Настройка Supabase

## Обзор

Supabase реализует централизованный персистентный слой данных (PostgreSQL + REST/RPC API), на который опираются агенты, n8n‑сценарии, аналитика и часть вспомогательных инструментов. В отличие от разрозненных таблиц в Notion или Google Sheets, Supabase обеспечивает транзакционность, управляемость схемы, безопасность и масштабируемость, что критично для систем, где накапливаются и активно используются исторические данные.

С точки зрения общей архитектуры, Supabase — это объективная операционная память системы: здесь живут сущности products, listings, price_logs, errors и любые другие таблицы, которые описывают реальное состояние бизнеса. Все остальные компоненты (AI‑агенты, оркестраторы, дашборды) должны рассматриваться как клиенты Supabase, а не как альтернативные источники правды.

## ⏱️ Оценка трудоёмкости

20–40 минут при условии базового понимания реляционных БД и интерфейса Supabase, плюс некоторое время на обсуждение и фиксацию начальной схемы данных.

## Шаги настройки

### 1. Создание проекта

1. Зарегистрируйтесь на [supabase.com](https://supabase.com)
2. Создайте новый проект:
   - Выберите организацию (или создайте новую)
   - Введите название проекта (например, "dropshipping-automation")
   - Выберите регион (ближайший к вашим серверам)
   - Установите пароль для базы данных (сохраните его!)
   - Выберите план (Free tier достаточно для начала)

### 2. Получение ключей доступа

1. Перейдите в **Settings** → **API**
2. Сохраните следующие ключи:
   - **Project URL** — URL вашего проекта (например, `https://xxxxx.supabase.co`)
   - **anon key** — публичный ключ для клиентских приложений
   - **service_role key** — приватный ключ для серверных приложений (храните в секрете!)

### 3. Создание базовой схемы данных

#### Таблица products

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
```

#### Таблица listings

```sql
CREATE TABLE listings (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  product_id UUID REFERENCES products(id),
  marketplace TEXT NOT NULL,
  marketplace_listing_id TEXT,
  title TEXT NOT NULL,
  price DECIMAL(10,2) NOT NULL,
  status TEXT DEFAULT 'draft',
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

#### Таблица price_logs

```sql
CREATE TABLE price_logs (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  product_id UUID REFERENCES products(id),
  source_price DECIMAL(10,2),
  target_price DECIMAL(10,2),
  margin_percent DECIMAL(5,2),
  logged_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

#### Таблица errors

```sql
CREATE TABLE errors (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  error_type TEXT NOT NULL,
  error_message TEXT,
  component TEXT,
  context JSONB,
  resolved BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  resolved_at TIMESTAMP WITH TIME ZONE
);
```

#### Таблица orders

```sql
CREATE TABLE orders (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  marketplace TEXT NOT NULL,
  marketplace_order_id TEXT UNIQUE,
  product_id UUID REFERENCES products(id),
  customer_email TEXT,
  total_amount DECIMAL(10,2),
  status TEXT DEFAULT 'pending',
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

### 4. Настройка Row Level Security (RLS)

1. Включите RLS для всех таблиц для безопасности
2. Настройте политики доступа в зависимости от ваших потребностей

Пример политики для чтения:

```sql
ALTER TABLE products ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Allow read access" ON products
  FOR SELECT
  USING (true);
```

### 5. Настройка API

1. Проверьте, что REST API автоматически доступен для всех таблиц
2. При необходимости настройте дополнительные endpoints через Edge Functions

## Сохранение данных для интеграции

Сохраните следующие данные в хранилище секретов (см. [SECRETS_MANAGEMENT.md](SECRETS_MANAGEMENT.md)):

- **Project URL** — URL вашего проекта
- **anon key** — публичный ключ
- **service_role key** — приватный ключ (храните в секрете!)
- **Database password** — пароль для прямого доступа к БД
- **Ссылка на документацию по текущей схеме** — где хранится актуальная схема БД

## Интеграция с системой

Supabase интегрируется в систему через:
- **n8n workflows** — для записи и чтения данных
- **AI агенты** — для аналитики и принятия решений на основе данных
- **Дашборды** — для визуализации данных (опционально)

## Рекомендации

1. **Версионирование схемы**: Храните SQL миграции в репозитории
2. **Резервное копирование**: Настройте автоматические бэкапы
3. **Мониторинг**: Следите за использованием ресурсов
4. **Индексы**: Создавайте индексы для часто используемых полей

## Следующие шаги

После настройки Supabase переходите к:
- [SECRETS_MANAGEMENT.md](SECRETS_MANAGEMENT.md) — Управление секретами
- Созданию n8n workflows для интеграции с Supabase

