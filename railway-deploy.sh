#!/bin/bash

echo "🚀 Railway Deployment Script"
echo "=============================="

# Run database migrations (if any)
# bundle exec rails db:migrate

# Precompile assets
echo "📦 Precompiling assets..."
bundle exec rails assets:precompile

# Seed data (only run once manually, not on every deploy)
# bundle exec rails db:seed_data
# bundle exec rails super_user:create

echo "✅ Ready to start server!"
