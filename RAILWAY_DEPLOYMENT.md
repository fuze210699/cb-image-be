# 🚂 Deploy CB Image API lên Railway

## 🎯 Railway là gì?

Railway là platform deployment hiện đại, rất phù hợp với Rails + MongoDB:
- ✅ Free tier $5 credit/tháng
- ✅ Auto deploy từ GitHub
- ✅ MongoDB tích hợp sẵn
- ✅ Zero config, cực kỳ dễ dùng
- ✅ Performance tốt từ VN

---

## 📋 Bước 1: Chuẩn bị

### 1.1 Đảm bảo code đã push lên GitHub

```bash
git add .
git commit -m "Ready for Railway deployment"
git push origin main
```

### 1.2 Xóa các file deploy cũ (đã xóa)

✅ Đã xóa Fly.io config
✅ Đã reset Puma config

---

## 🚀 Bước 2: Deploy lên Railway

### 2.1 Tạo tài khoản Railway

1. Truy cập: **https://railway.app**
2. Click **Login with GitHub**
3. Authorize Railway truy cập GitHub

### 2.2 Tạo Project mới

1. Click **New Project**
2. Chọn **Deploy from GitHub repo**
3. Chọn repository: `cb_image_be`
4. Railway sẽ tự động detect Rails app

### 2.3 Add MongoDB Service

1. Trong project, click **New**
2. Chọn **Database**
3. Chọn **Add MongoDB**
4. Railway sẽ provision MongoDB instance

Sau vài giây, MongoDB đã sẵn sàng với:
- Connection string tự động
- Biến môi trường `MONGO_URL`
- Backup tự động

### 2.4 Configure Environment Variables

Click vào **Rails service** (cb_image_be) → Tab **Variables**

Add các biến sau:

```env
RAILS_ENV=production
RAILS_MASTER_KEY=64c1768021a5a96843c24e82389716cf
MONGODB_URI=${{MongoDB.MONGO_URL}}
PORT=3000
RAILS_LOG_TO_STDOUT=true
RAILS_SERVE_STATIC_FILES=true
```

**Lưu ý:**
- `${{MongoDB.MONGO_URL}}` - Railway tự động replace bằng connection string
- Hoặc dùng MongoDB Atlas: paste connection string vào `MONGODB_URI`

### 2.5 Deploy!

Railway sẽ tự động:
1. ✅ Detect Rails app
2. ✅ Install dependencies (bundle install)
3. ✅ Precompile assets
4. ✅ Start server
5. ✅ Generate public URL

**URL của bạn:** `https://cb-image-be-production.up.railway.app`

---

## 🌱 Bước 3: Seed Database

### Option 1: Dùng Railway CLI (Recommended)

```bash
# Install Railway CLI
npm install -g @railway/cli
# Hoặc: brew install railway

# Login
railway login

# Link với project (chọn project từ list)
railway link

# Seed data
railway run rails super_user:create
railway run rails db:seed_data

# Verify
railway run rails runner "puts 'Users: ' + User.count.to_s"
```

### Option 2: Dùng script tự động

```bash
./railway-seed.sh
```

### Option 3: Qua Railway Dashboard

1. Click vào Rails service
2. Chọn tab **Deployments**
3. Click vào deployment hiện tại
4. Click **View Logs** và copy command:

```bash
railway run bash
# Trong shell:
rails super_user:create
rails db:seed_data
exit
```

---

## 🧪 Bước 4: Test API

### Test Homepage

```bash
curl https://cb-image-be-production.up.railway.app/
```

### Test Login

```bash
curl -X POST https://cb-image-be-production.up.railway.app/api/v1/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "longpc.cbimage@wano.com",
    "password": "LongPC123456789"
  }' | jq
```

**Expected response:**
```json
{
  "success": true,
  "message": "Logged in successfully",
  "data": {
    "id": "...",
    "email": "longpc.cbimage@wano.com",
    "role": "super_user",
    "is_super_user": true,
    ...
  }
}
```

### Test Get Current User

```bash
curl https://cb-image-be-production.up.railway.app/api/v1/me \
  -H "Cookie: _cb_image_be_session=YOUR_SESSION_FROM_LOGIN" | jq
```

---

## 🎛️ Bước 5: Monitoring & Management

### View Logs

1. Railway Dashboard → Your service
2. Tab **Deployments** → Click deployment
3. **View Logs** - real-time logs

Hoặc CLI:
```bash
railway logs
```

### View Metrics

Dashboard → **Metrics** tab:
- CPU usage
- Memory usage
- Network traffic
- Request count

### Restart Service

```bash
railway restart
```

Hoặc qua Dashboard: **Settings** → **Restart**

### Rollback Deployment

Dashboard → **Deployments** → Chọn deployment cũ → **Rollback**

---

## 🌐 Bước 6: Custom Domain (Optional)

### 6.1 Add Domain

1. Service **Settings** → **Domains**
2. Click **Add Domain**
3. Nhập domain của bạn: `api.cbimage.com`

### 6.2 Configure DNS

Railway sẽ hiện hướng dẫn, thường là:

**A Record:**
```
Type: A
Name: api (hoặc @)
Value: [Railway IP]
```

**CNAME Record:**
```
Type: CNAME
Name: api
Value: cb-image-be-production.up.railway.app
```

### 6.3 SSL Certificate

Railway tự động provision SSL certificate (Let's Encrypt)
- Chờ vài phút
- HTTPS tự động hoạt động

---

## 💰 Pricing & Limits

### Free Tier (Trial)
- $5 credit/tháng (không cần card)
- ~500 hours runtime
- Đủ cho dev/testing

### Developer Plan ($5/month)
- $5 credit/tháng
- Thêm usage-based pricing
- Đủ cho production nhỏ

### Ước tính chi phí

**Rails App:**
- CPU: $0.000463/vCPU-hour
- RAM: $0.000231/GB-hour
- 1 GB RAM 24/7: ~$5/month

**MongoDB:**
- Storage: $0.00023/GB-hour
- 5GB data: ~$1/month

**Tổng: ~$6-10/month cho production nhỏ**

---

## 🔧 Troubleshooting

### ❌ Build Failed

**Check logs:**
```bash
railway logs --deployment
```

**Common issues:**
- Missing Gemfile.lock → commit it
- RAILS_MASTER_KEY sai → check env vars
- Bundle install failed → check Gemfile

### ❌ MongoDB Connection Failed

**Check:**
1. Biến `MONGODB_URI` có đúng không
2. MongoDB service đã chạy chưa
3. Connection string format đúng chưa

```bash
railway run rails runner "puts Mongoid.default_client.cluster.summary"
```

### ❌ Assets Not Loading

Add env var:
```env
RAILS_SERVE_STATIC_FILES=true
```

### ❌ App Crashed

Check logs:
```bash
railway logs
```

Common causes:
- Missing env vars
- MongoDB not connected
- RAILS_MASTER_KEY invalid

---

## 📚 Advanced Features

### Auto Deploy on Git Push

Railway tự động deploy khi push lên `main` branch:

```bash
git push origin main
# Railway auto-detects và deploy
```

### Multiple Environments

Tạo nhiều services:
- `production` - branch main
- `staging` - branch develop
- `preview` - PR deployments

### Database Backups

MongoDB service → **Settings** → Configure backups

### Scaling

**Vertical (tăng resources):**
- Settings → Adjust CPU/RAM

**Horizontal (nhiều instances):**
- Settings → Replicas (paid plan)

### Health Checks

File `railway.toml` đã config:
```toml
[[healthchecks]]
path = "/"
timeout = 100
interval = 30
```

---

## 🔄 CI/CD Pipeline

Railway tự động:

```
Git Push → Railway Detects Change → Build → Test → Deploy → Live
```

Không cần setup CI/CD riêng!

---

## 📞 Support

- **Docs:** https://docs.railway.app
- **Discord:** https://discord.gg/railway (rất active!)
- **Status:** https://status.railway.app
- **Twitter:** @Railway

---

## ✅ Checklist

- [ ] Railway account created
- [ ] GitHub repo connected
- [ ] MongoDB service added
- [ ] Environment variables set
- [ ] App deployed successfully
- [ ] Database seeded
- [ ] API endpoints tested
- [ ] Logs checked
- [ ] Metrics monitored
- [ ] (Optional) Custom domain added

---

## 🎉 Kết luận

Railway giúp deploy Rails + MongoDB:
- ⚡ Cực kỳ nhanh (< 10 phút)
- 🎯 Zero config
- 💰 Giá tốt ($5-10/month)
- 📊 Monitoring tốt
- 🔄 Auto deploy từ GitHub

**Không còn lo về infrastructure, chỉ cần code!** 🚀
