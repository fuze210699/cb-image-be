# Quick Deploy Guide

## 🚀 Deploy trong 5 phút

### 1. Setup MongoDB Atlas (2 phút)

```bash
# 1. Truy cập https://mongodb.com/cloud/atlas
# 2. Create Free Cluster (M0) - Region: Singapore
# 3. Create User: cbimage_admin / <password>
# 4. Whitelist IP: 0.0.0.0/0
# 5. Copy Connection String:
mongodb+srv://cbimage_admin:<password>@cluster.mongodb.net/cb_image_production
```

### 2. Install Fly CLI (1 phút)

```bash
# macOS/Linux
curl -L https://fly.io/install.sh | sh

# Login
flyctl auth login
```

### 3. Deploy (2 phút)

```bash
# Set secrets
flyctl secrets set MONGODB_URI='mongodb+srv://...' -a cb-image-api
flyctl secrets set RAILS_MASTER_KEY="$(cat config/master.key)" -a cb-image-api

# Deploy
./deploy.sh
```

### 4. Seed Data (30 giây)

```bash
flyctl ssh console -a cb-image-api -C 'rails db:seed_data'
flyctl ssh console -a cb-image-api -C 'rails super_user:create'
```

### ✅ Done!

Your API: `https://cb-image-api.fly.dev`

Test:
```bash
curl https://cb-image-api.fly.dev/api/v1/login \
  -H "Content-Type: application/json" \
  -d '{"email":"longpc.cbimage@wano.com","password":"LongPC123456789"}'
```

## Frontend Integration

```javascript
// .env.production
VITE_API_URL=https://cb-image-api.fly.dev/api/v1

// api.js
const API_URL = import.meta.env.VITE_API_URL;

fetch(`${API_URL}/login`, {
  method: 'POST',
  headers: { 'Content-Type': 'application/json' },
  credentials: 'include',
  body: JSON.stringify({ email, password })
});
```

CORS đã được cấu hình cho **cb-image.com** ✅

## Troubleshooting

```bash
# Logs
flyctl logs -a cb-image-api -f

# Status
flyctl status -a cb-image-api

# Restart
flyctl apps restart cb-image-api
```

Chi tiết: [DEPLOY_FLYIO.md](DEPLOY_FLYIO.md)
