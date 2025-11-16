# 🚀 Система Автоматизации Дропшиппинга с AI-Агентами

## 📋 Обзор проекта

Данный документ описывает целостный, многоуровневый инфраструктурный контур для дропшиппинг‑системы, ориентированной на мультиплатформенную торговлю (eBay, Shopify, Meta, AutoDS) с использованием оркестрации через n8n, централизованного хранилища данных в Supabase и набора AI‑инструментов (ChatGPT, Claude, Cursor, Chat.z.ai, DeepSeek, Ollama и др.).

Система спроектирована так, чтобы её можно было постепенно разворачивать по фазам: от базовой ручной конфигурации аккаунтов и первичных интеграций до полуавтоматического и затем почти полностью автономного контура, в котором AI‑агенты и n8n‑воркфлоу выполняют большую часть рутинных операций.

### 🎯 Бизнес-модель
- **Ниша**: Камеры и фотооборудование (Sony, Canon, Fuji, Panasonic, Ricoh)
- **Модель**: Арбитраж eBay.de → eBay.com/Shopify/Facebook Marketplace
- **Целевая маржа**: Минимум 25-30% после всех комиссий
- **Ожидаемый прибыль**: €90-180 на товар, €900-2500/месяц (стартовый уровень)

### 🏗️ Технологический стек
- **Оркестратор**: n8n (Cloud или Self-hosted)
- **LLM**: OpenAI GPT-4 Turbo
- **База данных**: Supabase (PostgreSQL)
- **Маркетплейсы**: Shopify, eBay US/DE, Facebook Marketplace
- **Sourcing**: AutoDS, DSM Tool
- **Алерты**: Telegram Bot
- **AI IDE**: Cursor AI для разработки и поддержки

## 🤖 Архитектура агентов

### Tier 1: Core MVP Agents (обязательно на старте)

1. **Planner-Agent** - Декомпозиция задач
2. **Account-Agent** - Проверка инфраструктуры
3. **Multi-Sourcing-Agent** - Поиск у нескольких поставщиков
4. **Compliance-Agent** - Валидация листингов
5. **Listing-Agent** - Создание листингов
6. **Pricing-Agent** - Умное ценообразование
7. **Ops-Agent** - Автовыполнение заказов
8. **Reputation-Agent** - Мониторинг репутации
9. **Analytics-Agent** - Отчёты и аналитика

### Tier 2: Advanced Agents (через 1-2 месяца)

10. **Marketing-Agent** - Подготовка рекламных кампаний (полуавтомат)
11. **Expansion-Agent** - Поиск новых товаров (отложить до масштабирования)

## 📁 Структура проекта

```
dropshipping-automation/
├── README.md                                  # Этот файл
├── docs/
│   ├── ARCHITECTURE_OVERVIEW.md              # Общий обзор архитектуры
│   ├── KNOWLEDGE_BASE.md                     # Полная база знаний
│   ├── PHASE_0_CHECKLIST.md                  # Ручная настройка
│   ├── SETUP_SHOPIFY.md                      # Настройка Shopify
│   ├── SETUP_EBAY.md                         # Настройка eBay
│   ├── SETUP_META.md                         # Настройка Meta Business Suite
│   ├── SETUP_AUTODS.md                       # Настройка AutoDS
│   ├── SETUP_N8N.md                          # Настройка n8n
│   ├── SETUP_OPENAI.md                       # Настройка OpenAI API
│   ├── SETUP_TELEGRAM.md                     # Настройка Telegram Bot
│   ├── SETUP_SUPABASE.md                     # Настройка Supabase
│   ├── SECRETS_MANAGEMENT.md                 # Управление секретами
│   ├── KB_MAIN.md                            # Главная страница базы знаний
│   ├── KB_PRODUCTS_RESEARCH.md               # База Products Research
│   ├── KB_SUPPLIERS.md                       # База Suppliers
│   ├── KB_MARKETPLACES.md                    # База Marketplaces & Accounts
│   ├── KB_SOPS.md                            # База SOPs & Playbooks
│   ├── KB_TECH_DOCS.md                       # База Tech & API Docs
│   ├── KB_ERRORS.md                          # База Errors & Incidents
│   ├── CURSOR_AI_INTEGRATION.md              # Интеграция с Cursor AI
│   └── rules/
│       ├── work_documentation_rule.md        # Правила документации
│       ├── memory-bank-instructions.md       # Инструкции Memory Bank
│       ├── russian_language.md               # Правила языка
│       └── memory-bank/                      # Memory Bank файлы
├── n8n-workflows/
│   ├── product-sourcing.json                 # Workflow поиска товаров
│   ├── listing-creation.json                 # Workflow создания листингов
│   ├── order-fulfillment.json                # Workflow выполнения заказов
│   └── reputation-monitoring.json            # Workflow мониторинга репутации
├── prompts/
│   ├── planner-agent.md                      # Промпт для Planner
│   ├── compliance-agent.md                   # Промпт для Compliance
│   ├── pricing-agent.md                      # Промпт для Pricing
│   └── reputation-agent.md                   # Промпт для Reputation
├── templates/
│   └── notion/                               # Шаблоны для экспорта в Notion
│       ├── kb-main-template.md
│       ├── products-research-template.md
│       ├── suppliers-template.md
│       ├── marketplaces-template.md
│       ├── sops-template.md
│       └── tech-docs-template.md
├── scripts/
│   ├── setup/                                # Скрипты настройки
│   └── monitoring/                           # Скрипты мониторинга
└── config/
    ├── credentials.template.json             # Шаблон credentials
    ├── secrets-structure.md                  # Структура хранилища секретов
    └── agent-configs/                        # Конфигурации агентов
```

## 🚀 Быстрый старт

### Предварительные требования
- Node.js 18+ (для n8n)
- Аккаунты: Shopify, eBay US/DE, Meta Business, AutoDS
- OpenAI API ключ
- Telegram Bot
- Supabase проект

### Этапы настройки

1. **Фаза 0: Ручная настройка инфраструктуры** (~4-7 дней)
   - См. [PHASE_0_CHECKLIST.md](docs/PHASE_0_CHECKLIST.md) для детального чеклиста
   - Настройка всех платформ (Shopify, eBay, Meta, AutoDS, n8n, OpenAI, Telegram, Supabase)
   - См. отдельные гайды в папке `docs/`:
     - [SETUP_SHOPIFY.md](docs/SETUP_SHOPIFY.md) - Настройка Shopify (~30-45 минут)
     - [SETUP_EBAY.md](docs/SETUP_EBAY.md) - Настройка eBay (2-3 часа + до 48ч на верификацию)
     - [SETUP_META.md](docs/SETUP_META.md) - Настройка Meta Business Suite (1-2 часа + 3-5 дней на верификацию)
     - [SETUP_AUTODS.md](docs/SETUP_AUTODS.md) - Настройка AutoDS (~15-25 минут)
     - [SETUP_N8N.md](docs/SETUP_N8N.md) - Настройка n8n (30-60 минут)
     - [SETUP_OPENAI.md](docs/SETUP_OPENAI.md) - Настройка OpenAI API (~10-20 минут)
     - [SETUP_TELEGRAM.md](docs/SETUP_TELEGRAM.md) - Настройка Telegram Bot (5-10 минут)
     - [SETUP_SUPABASE.md](docs/SETUP_SUPABASE.md) - Настройка Supabase (20-40 минут)

2. **Управление секретами**
   - См. [SECRETS_MANAGEMENT.md](docs/SECRETS_MANAGEMENT.md) для структуры хранилища секретов
   - Используйте [config/credentials.template.json](config/credentials.template.json) как шаблон

3. **База знаний**
   - См. [KB_MAIN.md](docs/KB_MAIN.md) для структуры базы знаний
   - Используйте шаблоны в `templates/notion/` для экспорта в Notion

## 📚 Документация

### Основные документы
- [ARCHITECTURE_OVERVIEW.md](docs/ARCHITECTURE_OVERVIEW.md) - Общий обзор архитектуры системы
- [KNOWLEDGE_BASE.md](docs/KNOWLEDGE_BASE.md) - Полная база знаний системы
- [PHASE_0_CHECKLIST.md](docs/PHASE_0_CHECKLIST.md) - Чеклист ручной настройки

### Настройка платформ
- [SETUP_SHOPIFY.md](docs/SETUP_SHOPIFY.md) - Настройка Shopify
- [SETUP_EBAY.md](docs/SETUP_EBAY.md) - Настройка eBay
- [SETUP_META.md](docs/SETUP_META.md) - Настройка Meta Business Suite
- [SETUP_AUTODS.md](docs/SETUP_AUTODS.md) - Настройка AutoDS
- [SETUP_N8N.md](docs/SETUP_N8N.md) - Настройка n8n
- [SETUP_OPENAI.md](docs/SETUP_OPENAI.md) - Настройка OpenAI API
- [SETUP_TELEGRAM.md](docs/SETUP_TELEGRAM.md) - Настройка Telegram Bot
- [SETUP_SUPABASE.md](docs/SETUP_SUPABASE.md) - Настройка Supabase

### База знаний
- [KB_MAIN.md](docs/KB_MAIN.md) - Главная страница базы знаний
- [KB_PRODUCTS_RESEARCH.md](docs/KB_PRODUCTS_RESEARCH.md) - База Products Research
- [KB_SUPPLIERS.md](docs/KB_SUPPLIERS.md) - База Suppliers
- [KB_MARKETPLACES.md](docs/KB_MARKETPLACES.md) - База Marketplaces & Accounts
- [KB_SOPS.md](docs/KB_SOPS.md) - База SOPs & Playbooks
- [KB_TECH_DOCS.md](docs/KB_TECH_DOCS.md) - База Tech & API Docs
- [KB_ERRORS.md](docs/KB_ERRORS.md) - База Errors & Incidents

### Безопасность
- [SECRETS_MANAGEMENT.md](docs/SECRETS_MANAGEMENT.md) - Управление секретами и учетными данными

## 🔐 Безопасность

**ВАЖНО**: Никогда не коммитьте реальные секреты в репозиторий. Используйте:
- Шаблон [config/credentials.template.json](config/credentials.template.json)
- Специализированные хранилища секретов (1Password, Bitwarden, Notion с ограниченным доступом)
- См. [SECRETS_MANAGEMENT.md](docs/SECRETS_MANAGEMENT.md) для детальной информации

## 📖 Дополнительные ресурсы

- [Интеграция Cursor AI](docs/CURSOR_AI_INTEGRATION.md)
- [Шаблоны для Notion](templates/notion/)

## 🤝 Вклад в проект

При работе с проектом следуйте правилам документации в [docs/rules/](docs/rules/).

## 📝 Лицензия

Проект предназначен для внутреннего использования.
