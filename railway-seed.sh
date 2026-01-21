#!/bin/bash

echo "🌱 Seeding production database on Railway..."

# Install Railway CLI if not installed
if ! command -v railway &> /dev/null; then
    echo "Installing Railway CLI..."
    npm install -g @railway/cli
fi

# Login check
railway whoami || railway login

# Seed data
echo "Creating super user..."
railway run rails super_user:create

echo ""
echo "Seeding sample data..."
railway run rails db:seed_data

echo ""
echo "Verifying data..."
railway run rails runner "puts '✓ Users: ' + User.count.to_s"
railway run rails runner "puts '✓ Promotions: ' + Promotion.count.to_s"

echo ""
echo "✅ Database seeding complete!"
