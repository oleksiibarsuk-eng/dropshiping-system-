# Синхронизация с Notion

## Обзор

Этот документ описывает процесс создания и синхронизации базы знаний в Notion на основе структуры репозитория.

## Структура базы знаний в Notion

Создайте в Notion следующую структуру:

### Главная страница: DROP-SHIPPING SYSTEM

1. Создайте новую страницу в Notion с названием "DROP-SHIPPING SYSTEM"
2. Используйте шаблон из [templates/notion/kb-main-template.md](../../templates/notion/kb-main-template.md)
3. Добавьте описание системы и ссылки на все базы данных

### Базы данных

Создайте следующие базы данных в Notion:

#### 1. Products Research

- **Шаблон**: [templates/notion/products-research-template.md](../../templates/notion/products-research-template.md)
- **Документация**: [KB_PRODUCTS_RESEARCH.md](KB_PRODUCTS_RESEARCH.md)
- **Создание**: 
  1. Создайте новую базу данных в Notion
  2. Добавьте свойства согласно шаблону
  3. Настройте представления (Views)

#### 2. Suppliers

- **Шаблон**: [templates/notion/suppliers-template.md](../../templates/notion/suppliers-template.md)
- **Документация**: [KB_SUPPLIERS.md](KB_SUPPLIERS.md)
- **Создание**: Аналогично Products Research

#### 3. Marketplaces & Accounts

- **Шаблон**: [templates/notion/marketplaces-template.md](../../templates/notion/marketplaces-template.md)
- **Документация**: [KB_MARKETPLACES.md](KB_MARKETPLACES.md)

#### 4. SOPs & Playbooks

- **Шаблон**: [templates/notion/sops-template.md](../../templates/notion/sops-template.md)
- **Документация**: [KB_SOPS.md](KB_SOPS.md)

#### 5. Tech & API Docs

- **Шаблон**: [templates/notion/tech-docs-template.md](../../templates/notion/tech-docs-template.md)
- **Документация**: [KB_TECH_DOCS.md](KB_TECH_DOCS.md)

#### 6. Errors & Incidents

- **Шаблон**: [templates/notion/errors-template.md](../../templates/notion/errors-template.md)
- **Документация**: [KB_ERRORS.md](KB_ERRORS.md)

## Пошаговая инструкция

### Шаг 1: Создание главной страницы

1. Откройте Notion
2. Создайте новую страницу "DROP-SHIPPING SYSTEM"
3. Скопируйте содержимое из [templates/notion/kb-main-template.md](../../templates/notion/kb-main-template.md)
4. Заполните описание системы
5. Добавьте ссылки на базы данных (создадите их в следующих шагах)

### Шаг 2: Создание баз данных

Для каждой базы данных:

1. Создайте новую базу данных в Notion
2. Откройте соответствующий шаблон из `templates/notion/`
3. Создайте свойства (Properties) согласно шаблону:
   - Нажмите на "+" рядом с "Properties"
   - Добавьте каждое свойство с правильным типом
4. Создайте представления (Views) согласно шаблону
5. Добавьте пример записи для понимания структуры

### Шаг 3: Настройка связей

1. Свяжите базы данных между собой через Relations (если применимо):
   - Products Research ↔ Suppliers
   - Products Research ↔ Marketplaces & Accounts
2. Добавьте ссылки на базы данных на главной странице

### Шаг 4: Импорт начальных данных

Если у вас уже есть данные:

1. Экспортируйте данные из текущего источника (если есть)
2. Импортируйте в соответствующие базы данных Notion
3. Проверьте корректность данных

## Автоматическая синхронизация (опционально)

Для автоматической синхронизации можно использовать:

1. **Notion API** - для программной синхронизации данных
2. **n8n workflows** - для автоматического обновления баз данных
3. **Zapier/Make** - для интеграции с другими сервисами

### Пример интеграции через Notion API

```javascript
// Пример синхронизации ошибок из Supabase в Notion
const { Client } = require('@notionhq/client');

const notion = new Client({ auth: process.env.NOTION_API_KEY });

async function syncErrorToNotion(error) {
  await notion.pages.create({
    parent: { database_id: process.env.NOTION_ERRORS_DB_ID },
    properties: {
      'Title': { title: [{ text: { content: error.title } }] },
      'Severity': { select: { name: error.severity } },
      'Component': { select: { name: error.component } },
      'Status': { select: { name: error.status } },
      'Date occurred': { date: { start: error.date_occurred } }
    }
  });
}
```

## Рекомендации

1. **Ограничьте доступ**: Настройте права доступа только для необходимых людей
2. **Регулярное обновление**: Привыкайте фиксировать новые знания сразу
3. **Версионирование**: Отмечайте даты изменений в важных записях
4. **Резервное копирование**: Периодически экспортируйте данные из Notion

## См. также

- [KB_MAIN.md](KB_MAIN.md) - Главная страница базы знаний
- [Шаблоны для Notion](../../templates/notion/) - Все шаблоны для экспорта
- [SECRETS_MANAGEMENT.md](SECRETS_MANAGEMENT.md) - Управление секретами (включая Notion API ключи)

