# Deploy to Fly.io + MongoDB Atlas

## 📋 Yêu cầu

- Tài khoản Fly.io (miễn phí)
- Tài khoản MongoDB Atlas (miễn phí)
- Docker Desktop đang chạy

## Bước 1: Setup MongoDB Atlas

### 1.1. Tạo Cluster

1. Truy cập https://www.mongodb.com/cloud/atlas
2. Đăng ký/Đăng nhập
3. **Create a New Cluster**
   - Cloud Provider: AWS
   - Region: **Singapore (ap-southeast-1)** hoặc Tokyo (gần VN)
   - Cluster Tier: **M0 Sandbox (FREE)**
   - Cluster Name: `cb-image-cluster`

### 1.2. Tạo Database User

1. Security > Database Access > **Add New Database User**
   - Authentication Method: Password
   - Username: `cbimage_admin`
   - Password: Tạo password mạnh (lưu lại)
   - Database User Privileges: **Read and write to any database**

### 1.3. Whitelist IP

1. Security > Network Access > **Add IP Address**
   - Click **"Allow Access from Anywhere"**
   - IP Address: `0.0.0.0/0`
   - (Hoặc chỉ whitelist IP của Fly.io)

### 1.4. Lấy Connection String

1. Database > Connect > **Connect your application**
2. Driver: Node.js / Version: 4.1 or later
3. Copy connection string:
```
mongodb+srv://cbimage_admin:<password>@cb-image-cluster.xxxxx.mongodb.net/?retryWrites=true&w=majority
```

4. Thay `<password>` bằng password thật:
```
mongodb+srv://cbimage_admin:YourPassword123@cb-image-cluster.xxxxx.mongodb.net/cb_image_production?retryWrites=true&w=majority
```

## Bước 2: Setup Fly.io

### 2.1. Install Fly CLI

**macOS/Linux:**
```bash
curl -L https://fly.io/install.sh | sh
```

**Windows (PowerShell):**
```powershell
iwr https://fly.io/install.ps1 -useb | iex
```

**Verify installation:**
```bash
flyctl version
```

### 2.2. Login

```bash
flyctl auth login
```

Browser sẽ mở để đăng nhập.

### 2.3. Create App

```bash
# Tạo app (nếu chưa có)
flyctl apps create cb-image-api --org personal
```

## Bước 3: Configure Secrets

### 3.1. Set MongoDB URI

```bash
flyctl secrets set MONGODB_URI='mongodb+srv://cbimage_admin:YourPassword123@cb-image-cluster.xxxxx.mongodb.net/cb_image_production?retryWrites=true&w=majority' -a cb-image-api
```

### 3.2. Set Rails Master Key

```bash
# Tự động lấy từ file
MASTER_KEY=$(cat config/master.key)
flyctl secrets set RAILS_MASTER_KEY="$MASTER_KEY" -a cb-image-api
```

### 3.3. Verify Secrets

```bash
flyctl secrets list -a cb-image-api
```

Output:
```
NAME                DIGEST           CREATED AT
MONGODB_URI         xxxxxxxxxxxxx    1m ago
RAILS_MASTER_KEY    xxxxxxxxxxxxx    30s ago
```

## Bước 4: Deploy

### Option 1: Dùng Script (Khuyến nghị)

```bash
./deploy.sh
```

### Option 2: Manual Deploy

```bash
flyctl deploy -a cb-image-api
```

Quá trình deploy:
1. Build Docker image (~5-10 phút lần đầu)
2. Push image to Fly.io registry
3. Deploy và start app
4. Health check

## Bước 5: Seed Database

### 5.1. SSH vào Container

```bash
flyctl ssh console -a cb-image-api
```

### 5.2. Run Seed Commands

```bash
# Seed data mẫu
rails db:seed_data

# Tạo super user
rails super_user:create

# Exit
exit
```

### Alternative: One-liner

```bash
# Seed data
flyctl ssh console -a cb-image-api -C 'rails db:seed_data'

# Create super user
flyctl ssh console -a cb-image-api -C 'rails super_user:create'
```

## Bước 6: Verify Deployment

### 6.1. Check Status

```bash
flyctl status -a cb-image-api
```

### 6.2. Get App URL

```bash
flyctl info -a cb-image-api
```

URL sẽ là: `https://cb-image-api.fly.dev`

### 6.3. Test API

```bash
# Health check
curl https://cb-image-api.fly.dev/up

# Test login
curl -X POST https://cb-image-api.fly.dev/api/v1/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "longpc.cbimage@wano.com",
    "password": "LongPC123456789"
  }'
```

### 6.4. View Logs

```bash
# Realtime logs
flyctl logs -a cb-image-api

# Follow logs
flyctl logs -a cb-image-api -f
```

## Bước 7: Setup Custom Domain (Optional)

### 7.1. Add Certificate

```bash
flyctl certs add api.cb-image.com -a cb-image-api
```

### 7.2. Get DNS Info

```bash
flyctl certs show api.cb-image.com -a cb-image-api
```

### 7.3. Update DNS Records

Tại domain registrar (Namecheap, GoDaddy, etc):

**Option 1: CNAME (Khuyến nghị)**
```
Type: CNAME
Name: api
Value: cb-image-api.fly.dev
TTL: 3600
```

**Option 2: A + AAAA Records**
```
Type: A
Name: api
Value: <IPv4 từ flyctl certs show>

Type: AAAA
Name: api  
Value: <IPv6 từ flyctl certs show>
```

### 7.4. Verify Certificate

```bash
flyctl certs check api.cb-image.com -a cb-image-api
```

## Bước 8: Configure Frontend

Update frontend để gọi API:

```javascript
// .env.production
VITE_API_URL=https://cb-image-api.fly.dev/api/v1
# hoặc
VITE_API_URL=https://api.cb-image.com/api/v1
```

## Useful Commands

### Monitoring

```bash
# App status
flyctl status -a cb-image-api

# Resource usage
flyctl scale show -a cb-image-api

# Logs
flyctl logs -a cb-image-api -f
```

### Scaling

```bash
# Scale memory
flyctl scale memory 512 -a cb-image-api

# Scale VMs
flyctl scale count 2 -a cb-image-api
```

### Management

```bash
# Restart app
flyctl apps restart cb-image-api

# SSH vào container
flyctl ssh console -a cb-image-api

# Rails console
flyctl ssh console -a cb-image-api -C 'rails console'

# Open app in browser
flyctl open -a cb-image-api
```

### Database

```bash
# Backup MongoDB (từ Atlas dashboard)
# Deployments > Backup > On-Demand Snapshot

# Or manual backup
flyctl ssh console -a cb-image-api -C 'mongodump --uri="$MONGODB_URI"'
```

### Troubleshooting

```bash
# View detailed logs
flyctl logs -a cb-image-api --tail 100

# Check health
curl https://cb-image-api.fly.dev/up

# Restart
flyctl apps restart cb-image-api

# Rebuild and deploy
flyctl deploy -a cb-image-api --no-cache
```

## Environment Variables

Tất cả env vars đã được set:

```bash
# View all secrets
flyctl secrets list -a cb-image-api

# Add new secret
flyctl secrets set KEY=value -a cb-image-api

# Remove secret
flyctl secrets unset KEY -a cb-image-api
```

## Pricing

### Free Tier Includes:
- **3 shared-cpu-1x 256MB VMs**
- **3GB persistent volume storage**  
- **160GB outbound data transfer/month**

**App hiện tại sử dụng:**
- 1 VM (256MB RAM)
- Auto-stop khi không dùng (tiết kiệm)
- Free tier đủ cho ~10,000-50,000 requests/tháng

**MongoDB Atlas Free:**
- 512MB storage
- Shared cluster
- Đủ cho hàng ngàn users

**Total cost: $0/tháng** 🎉

## Rollback

Nếu deployment có lỗi:

```bash
# List releases
flyctl releases -a cb-image-api

# Rollback to previous
flyctl releases rollback -a cb-image-api
```

## CI/CD với GitHub Actions (Optional)

Tạo file `.github/workflows/deploy.yml`:

```yaml
name: Deploy to Fly.io

on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - uses: superfly/flyctl-actions/setup-flyctl@master
      
      - run: flyctl deploy --remote-only
        env:
          FLY_API_TOKEN: ${{ secrets.FLY_API_TOKEN }}
```

Lấy API token:
```bash
flyctl auth token
```

Add vào GitHub Secrets: `FLY_API_TOKEN`

## Support

- Fly.io Docs: https://fly.io/docs
- MongoDB Atlas: https://docs.atlas.mongodb.com
- Community: https://community.fly.io

## Summary

✅ **Setup MongoDB Atlas** - Database miễn phí 512MB
✅ **Deploy to Fly.io** - Hosting miễn phí với auto-scaling
✅ **Configure CORS** - Cho phép cb-image.com
✅ **Seed Database** - Tạo data mẫu
✅ **Custom Domain** - api.cb-image.com (optional)
✅ **Total Cost: $0/tháng**

🚀 **Your API is live at:** https://cb-image-api.fly.dev
