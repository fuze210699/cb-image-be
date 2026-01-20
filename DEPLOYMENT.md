# Hướng dẫn Deploy Miễn phí

## Các nền tảng Free Hosting phù hợp

### 1. Railway.app (Khuyến nghị) ⭐
**Free Tier:** $5 credit/tháng (đủ cho app nhỏ)

**Ưu điểm:**
- Deploy từ GitHub dễ dàng
- Hỗ trợ Docker
- MongoDB addon miễn phí
- Auto-deploy khi push code
- Có domain miễn phí (.railway.app)

**Setup:**
```bash
# 1. Tạo tài khoản tại railway.app
# 2. Install Railway CLI
npm i -g @railway/cli

# 3. Login
railway login

# 4. Init project
railway init

# 5. Add MongoDB
railway add --plugin mongodb

# 6. Deploy
railway up
```

**Cấu hình environment:**
```
MONGODB_URI=mongodb://mongo:password@host:port/dbname
RAILS_MASTER_KEY=<your-key>
RAILS_ENV=production
```

---

### 2. Render.com ⭐
**Free Tier:** Miễn phí hoàn toàn (app sleep sau 15 phút không dùng)

**Ưu điể�ng:**
- Hoàn toàn miễn phí
- Hỗ trợ Docker
- Auto-deploy từ GitHub
- SSL miễn phí
- Domain miễn phí (.onrender.com)

**Hạn chế:**
- App sleep sau 15 phút không dùng
- Cold start ~30s

**Setup:**

1. **Tạo file `render.yaml`:**
```yaml
services:
  - type: web
    name: cb-image-api
    env: docker
    dockerfilePath: ./Dockerfile
    envVars:
      - key: MONGODB_URI
        sync: false
      - key: RAILS_MASTER_KEY
        sync: false
      - key: RAILS_ENV
        value: production
    plan: free

databases:
  - name: cb-image-db
    databaseName: cb_image_production
    user: cbimage
    plan: free
```

2. **Push lên GitHub**
3. **Connect repository tại render.com**
4. **Set environment variables**

---

### 3. Fly.io ⭐
**Free Tier:** 
- 3 shared-cpu-1x 256MB VMs
- 3GB persistent volume storage
- 160GB outbound data transfer

**Ưu điể�ng:**
- Rất mạnh cho Docker
- Không sleep
- Performance tốt
- Regions gần Việt Nam (Singapore, Tokyo)

**Setup:**

1. **Install Fly CLI:**
```bash
# macOS
brew install flyctl

# Linux
curl -L https://fly.io/install.sh | sh

# Login
fly auth login
```

2. **Launch app:**
```bash
fly launch
```

3. **Tạo MongoDB:**
```bash
# Sử dụng MongoDB Atlas (free) hoặc
# Deploy MongoDB trên Fly
fly postgres create
```

4. **Set secrets:**
```bash
fly secrets set MONGODB_URI="mongodb+srv://..."
fly secrets set RAILS_MASTER_KEY="..."
```

5. **Deploy:**
```bash
fly deploy
```

---

### 4. MongoDB Atlas (Database) 🔥
**Free Tier:** 512MB storage

**Setup:**

1. Tạo tài khoản tại [mongodb.com/cloud/atlas](https://mongodb.com/cloud/atlas)
2. Tạo free cluster (M0)
3. Chọn region gần (Singapore)
4. Tạo database user
5. Whitelist IP: `0.0.0.0/0` (allow all)
6. Lấy connection string:
```
mongodb+srv://username:password@cluster.mongodb.net/dbname?retryWrites=true&w=majority
```

---

## So sánh các Platform

| Platform | Free Tier | MongoDB | Sleep | Performance | Khuyến nghị |
|----------|-----------|---------|-------|-------------|-------------|
| **Railway** | $5/tháng | ✅ Addon | ❌ | ⭐⭐⭐⭐⭐ | Tốt nhất |
| **Render** | Unlimited | ❌ | ✅ 15min | ⭐⭐⭐ | Tốt cho test |
| **Fly.io** | 3 VMs | ❌ | ❌ | ⭐⭐⭐⭐⭐ | Tốt cho production |
| **Heroku** | ❌ Không còn | ❌ | ❌ | - | Không khả dụng |

---

## Hướng dẫn chi tiết: Deploy lên Railway (Khuyến nghị)

### Bước 1: Chuẩn bị code

1. **Tạo file `railway.json`:**
```json
{
  "$schema": "https://railway.app/railway.schema.json",
  "build": {
    "builder": "DOCKERFILE",
    "dockerfilePath": "Dockerfile"
  },
  "deploy": {
    "restartPolicyType": "ON_FAILURE",
    "restartPolicyMaxRetries": 10
  }
}
```

2. **Update Dockerfile cho production:**
```dockerfile
# Sử dụng Dockerfile hiện tại (đã có sẵn)
# Không cần thay đổi gì
```

3. **Push code lên GitHub:**
```bash
git add .
git commit -m "Ready for deployment"
git push origin main
```

### Bước 2: Deploy trên Railway

1. **Đăng ký tại:** https://railway.app
2. **New Project** > **Deploy from GitHub repo**
3. **Select repository:** cb_image_be
4. **Add MongoDB:**
   - Click "New" > "Database" > "Add MongoDB"
   - Railway tự động tạo `MONGO_URL`

5. **Add environment variables:**
```
MONGODB_URI=${{MongoDB.MONGO_URL}}/cb_image_be_production
RAILS_MASTER_KEY=<copy từ config/master.key>
RAILS_ENV=production
```

6. **Deploy:**
   - Railway tự động deploy
   - Chờ ~5 phút

7. **Generate domain:**
   - Settings > Networking > Generate Domain
   - URL: `https://your-app.railway.app`

### Bước 3: Setup database

```bash
# SSH vào container (trên Railway dashboard > Shell)
rails db:seed_data
rails super_user:create
```

### Bước 4: Update CORS

Update `config/application.rb`:
```ruby
config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins 'localhost:5173', '127.0.0.1:5173', 'your-frontend.vercel.app'
    resource '/api/*',
      headers: :any,
      methods: [:get, :post, :put, :patch, :delete, :options, :head],
      credentials: true,
      expose: ['Authorization']
  end
end
```

---

## Hướng dẫn chi tiết: Deploy lên Render

### Bước 1: Tạo Render account

1. Đăng ký tại: https://render.com
2. Connect GitHub account

### Bước 2: Create Web Service

1. **New** > **Web Service**
2. **Connect repository:** cb_image_be
3. **Settings:**
   - Name: cb-image-api
   - Environment: Docker
   - Dockerfile Path: `./Dockerfile`
   - Instance Type: Free

### Bước 3: Environment Variables

```
MONGODB_URI=mongodb+srv://user:pass@cluster.mongodb.net/dbname
RAILS_MASTER_KEY=<your-key>
RAILS_ENV=production
```

### Bước 4: Deploy

- Click "Create Web Service"
- Đợi build & deploy (~10 phút)
- URL: `https://cb-image-api.onrender.com`

### Bước 5: Seed data

```bash
# Từ Render dashboard > Shell
rails db:seed_data
rails super_user:create
```

---

## Chi phí ước tính

### Option 1: Hoàn toàn FREE
- **Backend:** Render (free, có sleep)
- **Database:** MongoDB Atlas (512MB)
- **Frontend:** Vercel/Netlify (free)
- **Total:** $0/tháng

### Option 2: Không sleep ($7/tháng)
- **Backend:** Railway ($5/tháng)
- **Database:** Railway MongoDB (included)
- **Frontend:** Vercel (free)
- **Total:** ~$5/tháng

### Option 3: Production-ready ($20/tháng)
- **Backend:** Fly.io ($10/tháng)
- **Database:** MongoDB Atlas M10 ($9/tháng)
- **Frontend:** Vercel Pro ($20/tháng, optional)
- **Total:** ~$20/tháng

---

## Khuyến nghị

### Cho Development/Testing:
✅ **Render.com** - Hoàn toàn miễn phí, đủ để test

### Cho Production (giá rẻ):
✅ **Railway.app** - $5/tháng, không sleep, performance tốt

### Cho Production (serious):
✅ **Fly.io + MongoDB Atlas** - $20/tháng, scalable

---

## Next Steps

1. Chọn platform phù hợp
2. Deploy theo hướng dẫn
3. Update CORS cho frontend domain
4. Test API endpoints
5. Deploy frontend lên Vercel/Netlify

Bạn muốn deploy lên platform nào? Tôi sẽ hướng dẫn chi tiết hơn!
