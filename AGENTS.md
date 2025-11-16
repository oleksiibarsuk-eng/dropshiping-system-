# AGENTS Guidelines for This Repository

This repository contains documentation and configuration for a dropshipping automation system. When working on this project interactively with Cursor Agent, please follow the guidelines below.

## Project Structure

- **Documentation**: All documentation is in `docs/` directory, written in Russian
- **Configuration**: Configuration templates in `config/`
- **n8n Workflows**: Workflow definitions in `n8n-workflows/`
- **Prompts**: AI agent prompts in `prompts/`
- **Scripts**: Utility scripts in `scripts/`

## Language and Documentation

- **Documentation language**: Russian (all `.md` files in `docs/`)
- **Code language**: English (variables, functions, classes)
- **Comments**: Russian for documentation, English for code

## Security Rules

- **NEVER** commit real secrets to the repository
- Use `config/credentials.template.json` as a template only
- Real secrets should be stored in 1Password/Bitwarden/Notion (private page)
- Always check `.gitignore` before committing

## Working with Rules

This project uses Cursor Rules in `.cursor/rules/` directory:

- **project-standards.mdc**: General project standards (always applied)
- **documentation.mdc**: Documentation rules (applies to markdown files)
- **api-integrations.mdc**: API integration standards (applies to workflows and scripts)
- **n8n-workflows.mdc**: n8n workflow rules (applies to workflow JSON files)
- **ai-agents.mdc**: AI agent and prompt rules (applies to prompts)
- **database.mdc**: Database and Supabase rules (applies to SQL and database docs)

## Documentation Standards

When creating or updating documentation:

1. Use Markdown format with proper heading structure
2. Include examples and code blocks where applicable
3. Add links to related documents in "См. также" section
4. Update dates and versions when making significant changes
5. Keep documentation in Russian

## API Integration Standards

When working with API integrations:

1. Always log errors to Supabase (errors table)
2. Send critical notifications via Telegram Bot
3. Use retry mechanisms with exponential backoff
4. Handle rate limits properly
5. Never hardcode secrets - use environment variables or config files

## n8n Workflows

When creating or updating n8n workflows:

1. Export workflows as JSON and store in `n8n-workflows/`
2. Use meaningful names for workflows and nodes
3. Include error handling nodes
4. Document workflows in `docs/KB_TECH_DOCS.md`
5. Use n8n Credentials for secrets, not hardcoded values

## AI Agents

When working with AI agents:

1. Store prompts in `prompts/` directory
2. Each agent should have clearly defined responsibility
3. Results should be verifiable
4. Critical decisions should not be made without additional verification
5. Log agent work to Supabase
6. Send critical notifications to Telegram

## Database (Supabase)

When working with Supabase:

1. Supabase is the single source of truth for transactional data
2. Always use Row Level Security (RLS) for tables
3. Document schema changes in `docs/KB_TECH_DOCS.md`
4. Version database migrations
5. Log all errors to errors table

## Committing Changes

- Use meaningful commit messages in Russian or English
- Never commit real secrets or credentials
- Always check `.gitignore` before committing
- Export and commit n8n workflow changes
- Update documentation when making functional changes

## Useful Commands

| Command | Purpose |
|---------|---------|
| `git status` | Check repository status |
| `git add .` | Stage all changes |
| `git commit -m "message"` | Commit changes |
| `git push` | Push to remote repository |

---

Following these practices ensures consistent development workflow and maintains project quality and security.
