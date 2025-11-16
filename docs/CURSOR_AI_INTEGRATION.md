# 🎨 Інтеграція Cursor AI у Workflow Дропшиппінгу

## Огляд

Cursor AI інтегрується у систему автоматизації дропшиппінгу як інструмент для:
1. Генерації та оптимізації промптів для агентів
2. Розробки та дебагу n8n workflows
3. Автоматичного рефакторингу коду агентів
4. Аналізу помилок та пропозицій виправлень

## 🔧 Налаштування Cursor AI

### Крок 1: Встановлення Cursor AI

```bash
# Завантажити Cursor AI
# https://cursor.sh/

# Відкрити проект
cursor /Users/admin/Documents/dropshipping-automation
```

### Крок 2: Конфігурація AI Rules

Cursor автоматично завантажує правила з папки `docs/rules/`:
- `work_documentation_rule.md` - правила документування
- `memory-bank-instructions.md` - інструкції Memory Bank
- `russian_language.md` - правила мови спілкування

### Крок 3: Активація Memory Bank

Cursor AI автоматично використовує Memory Bank для контексту:
```bash
# Memory Bank файли в
docs/rules/memory-bank/
├── brief.md          # Опис проекту
├── context.md        # Поточний контекст
├── architecture.md   # Архітектура
├── tech.md          # Технології
└── tasks.md         # Активні задачі
```

## 🤖 Cursor AI як Агент у n8n Workflow

### Архітектура інтеграції

```yaml
Cursor AI Agent:
  Роль: Розробка, оптимізація та дебаг агентів
  Функції:
    - Генерація промптів для AI агентів
    - Оптимізація n8n workflows
    - Автоматичний рефакторинг коду
    - Аналіз логів та помилок
    - Пропозиції покращень
  
  Workflow інтеграція:
    Тригер: Webhook від n8n
    Вхід: Код агента, логи, помилки
    Обробка: Cursor AI API
    Вихід: Оптимізований код, виправлення
```


### n8n Workflow: Cursor AI Agent для оптимізації

```javascript
// Node 1: Webhook Trigger - Отримання запиту на оптимізацію
{
  "method": "POST",
  "path": "cursor-ai-optimize",
  "responseMode": "onReceived"
}

// Приклад payload:
{
  "agent_name": "Pricing-Agent",
  "code": "const calculatePrice = (cost) => { return cost * 1.45; }",
  "error_logs": ["Price calculation failed for product X"],
  "optimization_request": "Make pricing more dynamic based on competitor data"
}
```

```javascript
// Node 2: Prepare Context for Cursor AI
const agentCode = $json.code;
const errorLogs = $json.error_logs;
const agentName = $json.agent_name;
const request = $json.optimization_request;

// Завантажити Memory Bank для контексту
const memoryBank = await $http.request({
  url: 'https://api.github.com/repos/your-repo/contents/docs/rules/memory-bank',
  headers: { 'Authorization': 'token YOUR_GITHUB_TOKEN' }
});

const context = {
  agent: agentName,
  current_code: agentCode,
  errors: errorLogs,
  request: request,
  memory_bank: memoryBank.data,
  project_rules: [
    'Follow russian_language.md for responses',
    'Document all changes per work_documentation_rule.md',
    'Update memory-bank after significant changes'
  ]
};

return { json: context };
```

```javascript
// Node 3: Call Cursor AI API (через OpenAI-compatible endpoint)
// Cursor AI може бути викликаний через API або локально

// Варіант A: Через OpenAI API (якщо Cursor підтримує)
const response = await $http.request({
  url: 'https://api.openai.com/v1/chat/completions',
  method: 'POST',
  headers: {
    'Authorization': `Bearer ${process.env.OPENAI_API_KEY}`,
    'Content-Type': 'application/json'
  },
  body: {
    model: 'gpt-4-turbo',
    messages: [
      {
        role: 'system',
        content: `You are Cursor AI integrated into dropshipping automation system.
        
Memory Bank Context:
${JSON.stringify($json.memory_bank, null, 2)}

Project Rules:
${$json.project_rules.join('\n')}

Your task: Optimize the agent code based on the request and fix any errors.
Always follow the project rules and document changes.`
      },
      {
        role: 'user',
        content: `Agent: ${$json.agent}

Current Code:
\`\`\`javascript
${$json.current_code}
\`\`\`

Errors:
${$json.errors.join('\n')}

Optimization Request:
${$json.request}

Please provide:
1. Optimized code
2. Explanation of changes
3. Updated documentation
4. Test cases`
      }
    ],
    temperature: 0.7,
    max_tokens: 2000
  }
});

return { json: response.data.choices[0].message.content };
```


```javascript
// Node 4: Parse Cursor AI Response
const aiResponse = $json;

// Парсинг відповіді
const codeMatch = aiResponse.match(/```javascript\n([\s\S]*?)\n```/);
const optimizedCode = codeMatch ? codeMatch[1] : null;

const explanationMatch = aiResponse.match(/Explanation:([\s\S]*?)(?=Updated Documentation:|Test Cases:|$)/);
const explanation = explanationMatch ? explanationMatch[1].trim() : '';

const documentationMatch = aiResponse.match(/Updated Documentation:([\s\S]*?)(?=Test Cases:|$)/);
const documentation = documentationMatch ? documentationMatch[1].trim() : '';

const testCasesMatch = aiResponse.match(/Test Cases:([\s\S]*?)$/);
const testCases = testCasesMatch ? testCasesMatch[1].trim() : '';

return {
  json: {
    optimized_code: optimizedCode,
    explanation: explanation,
    documentation: documentation,
    test_cases: testCases,
    timestamp: new Date().toISOString()
  }
};
```

```javascript
// Node 5: Create Git Commit (автоматичне збереження змін)
const commitMessage = `feat: ${$json.agent} optimization by Cursor AI

${$json.explanation}

Changes:
- Optimized pricing algorithm
- Added competitor price monitoring
- Improved error handling

Generated by: Cursor AI Agent
Timestamp: ${$json.timestamp}`;

await $http.request({
  url: 'https://api.github.com/repos/your-repo/contents/agents/pricing-agent.js',
  method: 'PUT',
  headers: {
    'Authorization': 'token YOUR_GITHUB_TOKEN',
    'Content-Type': 'application/json'
  },
  body: {
    message: commitMessage,
    content: Buffer.from($json.optimized_code).toString('base64'),
    sha: 'CURRENT_FILE_SHA' // отримати через GET запит спочатку
  }
});
```

```javascript
// Node 6: Update Memory Bank
const memoryBankUpdate = {
  file: 'docs/rules/memory-bank/context.md',
  content: `## Recent Changes (${new Date().toLocaleDateString('uk-UA')})

### ${$json.agent} Optimization
**By**: Cursor AI Agent
**Date**: ${$json.timestamp}

**Changes**:
${$json.explanation}

**Impact**:
- Improved performance
- Better error handling
- More dynamic pricing logic

**Next Steps**:
- Test in staging environment
- Monitor for 24 hours
- Deploy to production if stable

---

${EXISTING_CONTEXT_CONTENT}
`
};

await updateMemoryBank(memoryBankUpdate);
```


```javascript
// Node 7: Send Notification via Telegram
const message = `
🤖 Cursor AI Agent завершив оптимізацію!

**Агент**: ${$json.agent}
**Час**: ${new Date($json.timestamp).toLocaleString('uk-UA')}

**Зміни**:
${$json.explanation}

**Документація**:
${$json.documentation}

**Тест-кейси**:
${$json.test_cases}

✅ Код оновлено в репозиторії
📝 Memory Bank оновлено

Перевірити зміни: https://github.com/your-repo/commit/latest
`;

await $telegram.sendMessage({
  chat_id: process.env.TELEGRAM_CHAT_ID,
  text: message,
  parse_mode: 'Markdown',
  reply_markup: {
    inline_keyboard: [
      [
        {text: "✅ Схвалити", callback_data: `approve_${$json.timestamp}`},
        {text: "❌ Відхилити", callback_data: `reject_${$json.timestamp}`},
        {text: "📝 Змінити", callback_data: `modify_${$json.timestamp}`}
      ]
    ]
  }
});
```

## 🔄 Автоматичні Workflow з Cursor AI

### 1. Щоденна Оптимізація Промптів

```yaml
Schedule: Cron: 0 2 * * * (щодня о 2:00)

Workflow:
  1. Аналіз логів за останні 24 години
  2. Виявлення неефективних промптів
  3. Виклик Cursor AI для оптимізації
  4. A/B тестування нових vs старих промптів
  5. Автоматичне впровадження якщо покращення > 15%
```

### 2. Моніторинг Помилок та Автофікс

```yaml
Trigger: Webhook on Error (від будь-якого агента)

Workflow:
  1. Отримання error logs + stack trace
  2. Cursor AI аналізує помилку
  3. Генерація фіксу
  4. Автоматичне тестування
  5. Створення PR з виправленням
  6. Алерт в Telegram для схвалення
```

### 3. Генерація Нових Агентів

```yaml
Trigger: Manual (через Telegram команду)

Команда: /create_agent [agent_name] [description]

Workflow:
  1. Cursor AI отримує опис нового агента
  2. Генерує код на основі існуючих паттернів
  3. Створює промпти
  4. Генерує тести
  5. Створює документацію
  6. Відправляє на ревʼю через Telegram
```

