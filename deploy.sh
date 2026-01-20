#!/bin/bash
# Deploy script for Fly.io

set -e

echo "🚀 Deploying to Fly.io..."

# Check if flyctl is installed
if ! command -v flyctl &> /dev/null; then
    echo "❌ flyctl is not installed"
    echo "Install it with: curl -L https://fly.io/install.sh | sh"
    exit 1
fi

# Check if logged in
if ! flyctl auth whoami &> /dev/null; then
    echo "❌ Not logged in to Fly.io"
    echo "Please run: flyctl auth login"
    exit 1
fi

echo "✅ flyctl is installed and authenticated"

# Check if app exists
if ! flyctl apps list | grep -q "cb-image-api"; then
    echo "📝 Creating new app..."
    flyctl apps create cb-image-api --org personal
fi

# Check secrets
echo "🔐 Checking secrets..."
if ! flyctl secrets list -a cb-image-api | grep -q "MONGODB_URI"; then
    echo "⚠️  MONGODB_URI not set"
    echo "Please set it with:"
    echo "flyctl secrets set MONGODB_URI='mongodb+srv://...' -a cb-image-api"
    exit 1
fi

if ! flyctl secrets list -a cb-image-api | grep -q "RAILS_MASTER_KEY"; then
    echo "⚠️  RAILS_MASTER_KEY not set"
    echo "Setting RAILS_MASTER_KEY..."
    MASTER_KEY=$(cat config/master.key)
    flyctl secrets set RAILS_MASTER_KEY="$MASTER_KEY" -a cb-image-api
fi

# Deploy
echo "🚢 Deploying application..."
flyctl deploy -a cb-image-api --remote-only

echo "✅ Deployment complete!"
echo ""
echo "📊 App info:"
flyctl info -a cb-image-api

echo ""
echo "🌐 Your app is available at:"
flyctl status -a cb-image-api | grep "https://"

echo ""
echo "📝 Next steps:"
echo "1. Run database seed: flyctl ssh console -a cb-image-api -C 'rails db:seed_data'"
echo "2. Create super user: flyctl ssh console -a cb-image-api -C 'rails super_user:create'"
echo "3. View logs: flyctl logs -a cb-image-api"
