#!/bin/bash

# Security Check Script
# Проверяет код на наличие секретов, опасных паттернов и уязвимостей зависимостей
# Usage: ./scripts/security_check.sh

set -euo pipefail

# Colors for output
RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

# Helper functions
heading() {
  echo
  echo "========================================"
  echo "$1"
  echo "========================================"
  echo
}

has_cmd() {
  command -v "$1" >/dev/null 2>&1
}

run_search() {
  local pattern="$1"
  local category="$2"
  local found=0
  
  # Search in code files (exclude node_modules, .git, etc.)
  while IFS= read -r file; do
    if grep -qiE "$pattern" "$file" 2>/dev/null; then
      if [ $found -eq 0 ]; then
        echo "[$category] Found potential issues:"
        found=1
      fi
      echo "  - $file"
      grep -niE "$pattern" "$file" 2>/dev/null | head -3 | sed 's/^/    /'
    fi
  done < <(find . -type f \( -name "*.js" -o -name "*.ts" -o -name "*.jsx" -o -name "*.tsx" -o -name "*.json" -o -name "*.py" -o -name "*.sh" -o -name "*.md" \) \
    ! -path "*/node_modules/*" \
    ! -path "*/.git/*" \
    ! -path "*/.n8n/*" \
    ! -path "*/dist/*" \
    ! -path "*/build/*" \
    ! -path "*/.next/*" \
    2>/dev/null)
  
  if [ $found -eq 0 ]; then
    echo "[OK] No $category issues found."
  fi
}

#######################################
# 1. Hardcoded Secrets Detection
#######################################

heading "1. Hardcoded Secrets Detection"

# API Keys and Tokens
echo "--- Checking for API keys and tokens ---"

SECRET_PATTERNS=(
  "api[_-]?key\s*[:=]\s*['\"][^'\"]{20,}"
  "api[_-]?token\s*[:=]\s*['\"][^'\"]{20,}"
  "access[_-]?token\s*[:=]\s*['\"][^'\"]{20,}"
  "secret[_-]?key\s*[:=]\s*['\"][^'\"]{20,}"
  "private[_-]?key\s*[:=]\s*['\"][^'\"]{20,}"
  "auth[_-]?token\s*[:=]\s*['\"][^'\"]{20,}"
  "bearer\s+[A-Za-z0-9_-]{20,}"
  "x-api-key\s*[:=]\s*['\"][^'\"]{20,}"
)

for pattern in "${SECRET_PATTERNS[@]}"; do
  run_search "$pattern" "ALERT"
done

# Specific service keys
echo
echo "--- Checking for service-specific keys ---"

SERVICE_PATTERNS=(
  "shopify.*api[_-]?key"
  "ebay.*token"
  "supabase.*key"
  "openai.*api[_-]?key"
  "telegram.*bot[_-]?token"
  "sk-[A-Za-z0-9]{32,}"  # OpenAI API key pattern
  "xox[baprs]-[0-9]{10,13}-[0-9]{10,13}-[0-9]{10,13}[a-zA-Z0-9]{24,}"  # Slack token
  "AIza[0-9A-Za-z_-]{35}"  # Google API key
  "AKIA[0-9A-Z]{16}"  # AWS Access Key ID
)

for pattern in "${SERVICE_PATTERNS[@]}"; do
  run_search "$pattern" "ALERT"
done

# Passwords
echo
echo "--- Checking for hardcoded passwords ---"

PASSWORD_PATTERNS=(
  "password\s*[:=]\s*['\"][^'\"]{8,}"
  "passwd\s*[:=]\s*['\"][^'\"]{8,}"
  "pwd\s*[:=]\s*['\"][^'\"]{8,}"
  "db[_-]?password\s*[:=]\s*['\"][^'\"]{8,}"
  "database[_-]?password\s*[:=]\s*['\"][^'\"]{8,}"
)

for pattern in "${PASSWORD_PATTERNS[@]}"; do
  run_search "$pattern" "ALERT"
done

# Database connection strings
echo
echo "--- Checking for database connection strings ---"

DB_PATTERNS=(
  "postgresql://[^'\"]+"
  "postgres://[^'\"]+"
  "mysql://[^'\"]+"
  "mongodb://[^'\"]+"
  "connection[_-]?string\s*[:=]\s*['\"][^'\"]{20,}"
)

for pattern in "${DB_PATTERNS[@]}"; do
  run_search "$pattern" "WARN"
done

#######################################
# 2. PII and Sensitive Data
#######################################

heading "2. PII and Sensitive Data Detection"

PII_PATTERNS=(
  "email\s*[:=]\s*['\"][a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}['\"]"
  "phone\s*[:=]\s*['\"][0-9+\-\(\)\s]{10,}['\"]"
  "ssn\s*[:=]\s*['\"][0-9]{3}-?[0-9]{2}-?[0-9]{4}['\"]"
  "credit[_-]?card\s*[:=]\s*['\"][0-9]{13,19}['\"]"
  "[0-9]{4}[-\s]?[0-9]{4}[-\s]?[0-9]{4}[-\s]?[0-9]{4}"  # Credit card pattern
)

for pattern in "${PII_PATTERNS[@]}"; do
  run_search "$pattern" "WARN"
done

#######################################
# 3. Environment Variables Check
#######################################

heading "3. Environment Variables Check"

echo "--- Checking for .env files in repository ---"

if find . -name ".env" -o -name ".env.local" -o -name ".env.production" 2>/dev/null | grep -v node_modules | grep -v ".git" | head -5 | while read -r file; do
  echo "[ALERT] Found .env file: $file"
  echo "  Make sure it's in .gitignore!"
done; then
  :
else
  echo "[OK] No .env files found (or they are properly ignored)."
fi

echo
echo "--- Checking .gitignore for common secret files ---"

if [ -f ".gitignore" ]; then
  REQUIRED_IGNORES=(
    ".env"
    "*.key"
    "*.pem"
    "credentials.json"
    "secrets"
  )
  
  for ignore in "${REQUIRED_IGNORES[@]}"; do
    # Simple check - just see if the pattern exists in .gitignore
    if grep -qF "$ignore" .gitignore 2>/dev/null; then
      echo "[OK] .gitignore contains: $ignore"
    else
      echo "[WARN] .gitignore might be missing: $ignore"
    fi
  done
else
  echo "[WARN] .gitignore file not found!"
fi

#######################################
# 4. Dangerous Code Patterns
#######################################

heading "4. Dangerous Code Patterns"

DANGEROUS_PATTERNS=(
  "eval\s*\("
  "Function\s*\("
  "setTimeout\s*\([^,]+,\s*[^)]*\)"
  "setInterval\s*\([^,]+,\s*[^)]*\)"
  "innerHTML\s*="
  "dangerouslySetInnerHTML"
  "document\.write\s*\("
  "exec\s*\("
  "system\s*\("
  "shell_exec\s*\("
  "passthru\s*\("
  "popen\s*\("
  "proc_open\s*\("
  "base64_decode\s*\("
  "gzinflate\s*\("
  "str_rot13\s*\("
)

for p in "${DANGEROUS_PATTERNS[@]}"; do
  echo "--- Pattern: $p ---"
  run_search "$p" "dangerous"
done

#######################################
# 5. Dependency security audit (Node / Python)
#######################################

heading "5. Dependency security audit"

# Node.js – npm / yarn
if [[ -f "package-lock.json" || -f "pnpm-lock.yaml" || -f "yarn.lock" || -f "package.json" ]]; then
  echo "[INFO] Node.js project detected."

  if has_cmd npm; then
    echo
    echo "--- npm audit (production only) ---"
    npm audit --omit=dev 2>&1 || echo "[WARN] npm audit reported issues (check above)."
  else
    echo "[WARN] npm not found. Skipping npm audit."
  fi

  if has_cmd yarn && [[ -f "yarn.lock" ]]; then
    echo
    echo "--- yarn audit (prod deps) ---"
    yarn audit --groups dependencies 2>&1 || echo "[WARN] yarn audit reported issues (check above)."
  fi
else
  echo "[INFO] No Node.js lockfile detected (skipping npm/yarn audit)."
fi

# Python – pip-audit (optional)
if [[ -f "requirements.txt" || -f "pyproject.toml" ]]; then
  echo
  echo "[INFO] Python project detected."
  if has_cmd pip-audit; then
    echo "--- pip-audit ---"
    pip-audit 2>&1 || echo "[WARN] pip-audit reported issues (check above)."
  else
    echo "[INFO] pip-audit not installed. You can install it with:"
    echo "  python -m pip install pip-audit"
  fi
fi

#######################################
# 6. n8n Workflow Security Check
#######################################

heading "6. n8n Workflow Security Check"

if [ -d "n8n-workflows" ]; then
  echo "--- Checking n8n workflows for hardcoded credentials ---"
  
  WORKFLOW_SECRET_PATTERNS=(
    "\"password\"\s*:\s*\"[^\"]{8,}\""
    "\"apiKey\"\s*:\s*\"[^\"]{20,}\""
    "\"token\"\s*:\s*\"[^\"]{20,}\""
    "\"secret\"\s*:\s*\"[^\"]{20,}\""
  )
  
  for pattern in "${WORKFLOW_SECRET_PATTERNS[@]}"; do
    found=0
    while IFS= read -r file; do
      if grep -qiE "$pattern" "$file" 2>/dev/null; then
        if [ $found -eq 0 ]; then
          echo "[ALERT] Found potential hardcoded credentials in workflows:"
          found=1
        fi
        echo "  - $file"
        grep -niE "$pattern" "$file" 2>/dev/null | head -2 | sed 's/^/    /'
      fi
    done < <(find n8n-workflows -name "*.json" 2>/dev/null)
  done
  
  if [ $found -eq 0 ]; then
    echo "[OK] No hardcoded credentials found in n8n workflows."
  fi
else
  echo "[INFO] No n8n-workflows directory found."
fi

#######################################
# 7. Summary
#######################################

heading "7. Summary"

echo "Review the sections above for:"
echo "- [ALERT] and [WARN] lines for critical or important issues."
echo "- Potential hardcoded secrets and PII."
echo "- Dangerous code patterns which may need refactoring."
echo "- Dependency vulnerabilities from npm/yarn/pip-audit."
echo "- n8n workflow security issues."

echo
echo "Security check completed."

