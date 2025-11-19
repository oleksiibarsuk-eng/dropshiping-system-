#!/bin/bash

# Test all integrations

echo "🧪 Testing Integrations"
echo "======================"
echo ""

# Load environment variables
if [ -f frontend/.env.local ]; then
    export $(cat frontend/.env.local | xargs)
fi

# Test Supabase
echo "Testing Supabase..."
response=$(curl -s -o /dev/null -w "%{http_code}" "${VITE_SUPABASE_URL}/rest/v1/" \
  -H "apikey: ${VITE_SUPABASE_ANON_KEY}")

if [ "$response" = "200" ]; then
    echo "✅ Supabase: Connected"
else
    echo "❌ Supabase: Failed (HTTP $response)"
fi

# Test OpenRouter
if [ ! -z "$OPENROUTER_API_KEY" ]; then
    echo "Testing OpenRouter..."
    response=$(curl -s -o /dev/null -w "%{http_code}" "https://openrouter.ai/api/v1/models" \
      -H "Authorization: Bearer ${OPENROUTER_API_KEY}")
    
    if [ "$response" = "200" ]; then
        echo "✅ OpenRouter: Connected"
    else
        echo "❌ OpenRouter: Failed (HTTP $response)"
    fi
else
    echo "⏭️  OpenRouter: Skipped (no API key)"
fi

# Test eBay
if [ ! -z "$EBAY_ACCESS_TOKEN" ]; then
    echo "Testing eBay API..."
    response=$(curl -s -o /dev/null -w "%{http_code}" "https://api.ebay.com/sell/account/v1/privilege" \
      -H "Authorization: Bearer ${EBAY_ACCESS_TOKEN}")
    
    if [ "$response" = "200" ]; then
        echo "✅ eBay: Connected"
    else
        echo "❌ eBay: Failed (HTTP $response)"
    fi
else
    echo "⏭️  eBay: Skipped (no access token)"
fi

# Test Telegram
if [ ! -z "$TELEGRAM_BOT_TOKEN" ]; then
    echo "Testing Telegram Bot..."
    response=$(curl -s "https://api.telegram.org/bot${TELEGRAM_BOT_TOKEN}/getMe" | grep -o '"ok":true')
    
    if [ "$response" = '"ok":true' ]; then
        echo "✅ Telegram: Connected"
    else
        echo "❌ Telegram: Failed"
    fi
else
    echo "⏭️  Telegram: Skipped (no bot token)"
fi

echo ""
echo "Test complete!"
