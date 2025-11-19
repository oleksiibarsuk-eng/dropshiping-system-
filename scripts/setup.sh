#!/bin/bash

# Dropshipping AI Control Center - Setup Script

set -e

echo "🚀 Dropshipping AI Control Center Setup"
echo "========================================"
echo ""

# Check prerequisites
echo "📋 Checking prerequisites..."

# Check Node.js
if ! command -v node &> /dev/null; then
    echo "❌ Node.js not found. Installing..."
    brew install node
else
    echo "✅ Node.js $(node --version) found"
fi

# Check npm
if ! command -v npm &> /dev/null; then
    echo "❌ npm not found"
    exit 1
else
    echo "✅ npm $(npm --version) found"
fi

echo ""
echo "📦 Installing frontend dependencies..."
cd frontend
npm install

echo ""
echo "🔧 Setting up environment..."
if [ ! -f .env.local ]; then
    cp ../config/.env.example .env.local
    echo "⚠️  Created .env.local - Please add your API keys!"
else
    echo "✅ .env.local already exists"
fi

echo ""
echo "✅ Setup complete!"
echo ""
echo "Next steps:"
echo "1. Edit frontend/.env.local with your Supabase credentials"
echo "2. Run: cd frontend && npm run dev"
echo "3. Open: http://localhost:3000"
echo ""
echo "📚 Documentation: docs/SETUP.md"
