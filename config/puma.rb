# This configuration file will be evaluated by Puma. The top-level methods that
# are invoked here are part of Puma's configuration DSL. For more information
# about methods provided by the DSL, see https://puma.io/puma/Puma/DSL.html.
#
# Puma starts a configurable number of processes (workers) and each process
# serves each request in a thread from an internal thread pool.
#
# You can control the number of workers using ENV["WEB_CONCURRENCY"]. You
# should only set this value when you want to run 2 or more workers. The
# default is already 1.
#
# The ideal number of threads per worker depends both on how much time the
# application spends waiting for IO operations and on how much you wish to
# prioritize throughput over latency.
#
# As a rule of thumb, increasing the number of threads will increase how much
# traffic a given process can handle (throughput), but due to CRuby's
# Global VM Lock (GVL) it has diminishing returns and will degrade the
# response time (latency) of the application.
#
# The default is set to 3 threads as it's deemed a decent compromise between
# throughput and latency for the average Rails application.
#
# Any libraries that use a connection pool or another resource pool should
# be configured to provide at least as many connections as the number of
# threads. This includes Active Record's `pool` parameter in `database.yml`.
threads_count = ENV.fetch("RAILS_MAX_THREADS", 3)
threads threads_count, threads_count

# Specifies the `port` that Puma will listen on to receive requests; default is 3000.
port ENV.fetch("PORT", 3000)

# Specifies the `environment` that Puma will run in.
environment ENV.fetch("RAILS_ENV") { "development" }

# Allow puma to be restarted by `bin/rails restart` command.
plugin :tmp_restart

# Specify the PID file. Defaults to tmp/pids/server.pid in development.
# In other environments, only set the PID file if requested.
pidfile ENV["PIDFILE"] if ENV["PIDFILE"]




















































































































































































































































































**Xong! App của bạn đã live! 🎉**```railway run rails super_user:create# 6. Seed data# 5. Deploy tự động!MONGODB_URI=${{MongoDB.MONGO_URL}}RAILS_MASTER_KEY=your_keyRAILS_ENV=production# 4. Set env vars:# 3. Add MongoDB service# 2. Railway.app → New Project → Deploy from GitHubgit push origin main# 1. Push to GitHub```bash## ⚡ QUICK START (TL;DR)---- Pricing: https://railway.app/pricing- Rails on Railway: https://docs.railway.app/guides/rails- Railway Discord: https://discord.gg/railway- Railway Docs: https://docs.railway.app## 📞 Support & Resources---**Đề xuất:** Dùng Railway MongoDB cho đơn giản, hoặc giữ Atlas nếu đã setup xong.- 💰 Free hoặc $9+/month- ❌ Phức tạp hơn setup- ✅ Global clusters- ✅ Enterprise features- ✅ Free tier 512MB### MongoDB Atlas (Hiện tại của bạn)- 💰 ~$3-5/month- ✅ Easy scaling- ✅ Metrics tích hợp- ✅ Tự động backup- ✅ 1-click setup### Railway MongoDB (Đề xuất)## 🔄 So sánh MongoDB Options---- [ ] (Optional) Add custom domain- [ ] Test API endpoints- [ ] Seed database- [ ] Deploy app- [ ] Set environment variables- [ ] Add MongoDB service- [ ] Connect GitHub repo- [ ] Tạo Railway account- [ ] Push code lên GitHub- [x] Xóa Fly.io config files- [x] Xóa Fly.io app## 📋 CHECKLIST MIGRATION---3. SSL tự động2. Update DNS records theo hướng dẫn1. Settings → **Domains** → Add custom domain### Bước 8: Custom Domain (Optional)```railway run rails console# Hoặc open shellrailway run rails super_user:createrailway run rails db:seed_data# Run rake taskrailway link# Link projectrailway login# Login# Hoặc: brew install railwaynpm install -g @railway/cli# Install Railway CLI```bash### Bước 7: Seed Database- Check logs trong Railway dashboard- Nhận domain: `your-app.up.railway.app`- Railway tự động build và deploy### Bước 6: Deploy!```restartPolicyMaxRetries = 10restartPolicyType = "on_failure"startCommand = "bin/rails server -b 0.0.0.0"[deploy]builder = "nixpacks"[build]```toml**railway.toml** (optional):Railway auto-detect Rails, nhưng có thể customize:### Bước 5: Configure Build```PORT=3000MONGODB_URI=${{MongoDB.MONGO_URL}}RAILS_MASTER_KEY=64c1768021a5a96843c24e82389716cfRAILS_ENV=production```envClick vào Rails service → **Variables**:### Bước 4: Configure Environment Variables3. Tự động set biến `MONGO_URL`2. Railway tự động tạo MongoDB instance1. Click **New** → **Database** → **Add MongoDB**### Bước 3: Add MongoDB5. Chọn repo `cb_image_be`4. Chọn **Deploy from GitHub repo**3. Click **New Project**2. Sign up với GitHub1. Truy cập: https://railway.app### Bước 2: Setup Railway```git push origin maingit commit -m "Prepare for Railway deployment"git add .# Đảm bảo code đã push lên GitHub```bash### Bước 1: Chuẩn bị GitHub repo## 🚀 HƯỚNG DẪN DEPLOY VỚI RAILWAY (ĐỀ XUẤT)---**→ VPS DigitalOcean Droplet** ($6-12/month)### Cho Budget thấp + có kỹ năng DevOps**→ DigitalOcean App Platform** ($20/month)### Cho Production lớn hoặc cần performance VN tốt**→ Railway.app** ($10-15/month)### Cho Production nhỏ-vừa (< 10k users)**→ Railway.app** (Free tier $5 credit)### Cho Development/Testing## 🎯 ĐỀ XUẤT CUỐI CÙNG---- Droplet 2GB RAM: $12/month (recommended cho production)- Droplet 1GB RAM: $6/month**Chi phí:****Phù hợp:** Có kinh nghiệm DevOps, muốn control hoàn toàn- ❌ Cần kiến thức DevOps- ❌ Không auto-scale- ❌ Tự quản lý security, updates- ❌ Phải tự setup server, nginx, SSL**Nhược điểm:**- ✅ Chạy cả app + MongoDB trên 1 server- ✅ Nhiều resources- ✅ Full control- ✅ Rẻ nhất ($4-6/month)**Ưu điểm:**### 4. VPS Tự quản (DigitalOcean/Linode/Vultr Droplet)- **Tổng: $16+/month**- MongoDB addon (mLab/ObjectRocket): $9+/month- Basic dyno: $7/month- Eco dyno: $5/month (sleep)**Chi phí:****Phù hợp:** Enterprise, apps cần độ tin cậy cao- ❌ Chậm từ VN- ❌ Đắt nhất ($7/dyno, $9/month MongoDB addon tối thiểu)- ❌ Đã xóa free tier**Nhược điểm:**- ✅ Documentation xuất sắc- ✅ Add-ons nhiều- ✅ Rails ecosystem tốt nhất- ✅ Rất ổn định**Ưu điểm:**### 3. Heroku- **Tổng: $20/month**- MongoDB Cluster: $15/month- Basic Web App: $5/month**Chi phí:****Phù hợp:** Production apps, cần performance cao- ❌ MongoDB từ $15/month- ❌ Tốn $5/month tối thiểu cho Basic app- ❌ Không có free tier thực sự**Nhược điểm:**- ✅ Ổn định cao- ✅ Performance tốt- ✅ MongoDB Managed Database- ✅ Server gần VN (Singapore datacenter)**Ưu điểm:**### 2. DigitalOcean App Platform- MongoDB: Dùng Atlas free tier- Web Service: Free hoặc $7/month (no sleep)**Chi phí:****Phù hợp:** Prototype, demo, side projects ít traffic- ❌ Limited resources (512MB RAM)- ❌ Cold start ~30s (chậm)- ❌ Free tier: app sleep sau 15 phút inactive- ❌ MongoDB không free (cần dùng Atlas)**Nhược điểm:**- ✅ Dễ dùng- ✅ Auto SSL- ✅ Zero config cho Rails- ✅ Hoàn toàn miễn phí cho web service**Ưu điểm:**### 1. Render.com## 🥈 PHƯƠNG ÁN THAY THẾ---- **Tổng: ~$8-15/month**- MongoDB: $3-5/month- Rails app: $5-10/month**Ước tính cho production nhỏ:**- MongoDB: $0.00023/GB-hour storage- $0.000463/vCPU-hour (~$10/month cho 1 vCPU)- $0.000231/GB-hour RAM (~$5/month cho 1GB)**Paid (nếu vượt free):**- Không cần credit card- ~500 hours runtime- $5 credit/tháng**Free Tier:**### 💵 Chi phí Railway   - Pricing rõ ràng theo usage   - Horizontal scaling (replicas)   - Vertical scaling (CPU/RAM)6. **📈 Scale dễ dàng**   - Fast cold starts   - CDN tích hợp   - Edge locations Singapore5. **🌏 Performance tốt từ VN**   - Auto SSL certificates   - Custom domains   - Easy rollback   - Metrics dashboard   - Live logs4. **🔧 Developer Experience tuyệt vời**   - 1-click MongoDB add-on   - Environment variables qua UI   - Zero config Dockerfile   - Connect GitHub → Auto deploy3. **⚡ Deployment cực kỳ đơn giản**   - ~500 hours uptime/tháng   - Đủ cho development/testing   - Không cần credit card để bắt đầu   - $5 credit/tháng miễn phí2. **💰 Free Tier hấp dẫn**   - Tự động detect và build Rails app   - MongoDB plugin tích hợp   - Template sẵn cho Rails1. **🎯 Hoàn hảo cho Rails + MongoDB**### ✅ Tại sao chọn Railway?## 🏆 PHƯƠNG ÁN ĐỀ XUẤT: RAILWAY.APP---| Fly.io | ⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐⭐⭐ | Phức tạp || DigitalOcean | ⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | Tốt || Heroku | ⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐ | Đắt || Render | ⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐ | Tốt || **Railway** | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐ | **🏆 TỐT NHẤT** ||----------|-----------|----------|---------|---------------|---------|-----------|----------|| Platform | Free Tier | Dễ setup | MongoDB | Rails Support | Ổn định | Tốc độ VN | Đề xuất |## 📊 Bảng so sánh nhanh# about methods provided by the DSL, see https://puma.io/puma/Puma/DSL.html.
#
# Puma starts a configurable number of processes (workers) and each process
# serves each request in a thread from an internal thread pool.
#
# You can control the number of workers using ENV["WEB_CONCURRENCY"]. You
# should only set this value when you want to run 2 or more workers. The
# default is already 1.
#
# The ideal number of threads per worker depends both on how much time the
# application spends waiting for IO operations and on how much you wish to
# prioritize throughput over latency.
#
# As a rule of thumb, increasing the number of threads will increase how much
# traffic a given process can handle (throughput), but due to CRuby's
# Global VM Lock (GVL) it has diminishing returns and will degrade the
# response time (latency) of the application.
#
# The default is set to 3 threads as it's deemed a decent compromise between
# throughput and latency for the average Rails application.
#
# Any libraries that use a connection pool or another resource pool should
# be configured to provide at least as many connections as the number of
# threads. This includes Active Record's `pool` parameter in `database.yml`.
threads_count = ENV.fetch("RAILS_MAX_THREADS", 3)
threads threads_count, threads_count

# Specifies the `port` that Puma will listen on to receive requests; default is 3000.
port ENV.fetch("PORT", 3000)

# Specifies the `environment` that Puma will run in.
environment ENV.fetch("RAILS_ENV") { "development" }

# Allow puma to be restarted by `bin/rails restart` command.
plugin :tmp_restart

# Specify the PID file. Defaults to tmp/pids/server.pid in development.
# In other environments, only set the PID file if requested.
pidfile ENV["PIDFILE"] if ENV["PIDFILE"]
