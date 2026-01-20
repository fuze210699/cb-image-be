# CB Image - Quick Start Guide 🚀

## Cài đặt nhanh với Docker (3 bước)

### Bước 1: Cài Docker Desktop
- macOS/Windows: Tải từ https://www.docker.com/products/docker-desktop/
- Linux: `curl -fsSL https://get.docker.com -o get-docker.sh && sudo sh get-docker.sh`

### Bước 2: Clone và Setup
```bash
git clone <repository-url>
cd cb_image_be
./docker.sh setup
```

### Bước 3: Truy cập
- **App**: http://localhost:3000
- **Email**: http://localhost:1080
- **Admin**: admin@cbimage.com / password123
- **User**: user1@example.com / password123

## Các lệnh thường dùng

```bash
./docker.sh start      # Khởi động
./docker.sh stop       # Dừng lại
./docker.sh logs       # Xem logs
./docker.sh console    # Rails console
./docker.sh bash       # Terminal trong container
```

## Tính năng chính

✅ Đăng ký / Đăng nhập (Devise)
✅ Phân quyền Admin / User
✅ Quản lý Subscription (monthly/yearly)
✅ Mã khuyến mãi
✅ Lịch sử mua hàng
✅ Email notifications
✅ MongoDB database

## Tài liệu chi tiết

- [README.md](README.md) - Hướng dẫn đầy đủ
- [DOCKER.md](DOCKER.md) - Docker chi tiết
- [DEVELOPMENT.md](DEVELOPMENT.md) - API & Development
- [MONGODB_SETUP.md](MONGODB_SETUP.md) - Cài MongoDB manual

## Cấu trúc database

### User
- Email, password, role (admin/user)
- Tracking: sign_in_count, current_sign_in_at

### UserSubscription
- subscription_type (monthly/yearly)
- start_date, end_date, status
- auto_renew, price

### UserPurchaseHistory
- purchase_type, amount, status
- payment_method, transaction_id

### Promotion
- code, discount_type, discount_value
- start_date, end_date, max_uses

## Routes chính

### Public
- `GET /` - Home
- `GET /users/sign_in` - Login
- `GET /users/sign_up` - Register

### User (cần login)
- `GET /dashboard` - User dashboard
- `GET /subscription` - Subscription
- `POST /subscription` - Tạo subscription

### Admin (chỉ admin)
- `GET /admin` - Admin dashboard
- `GET /admin/users` - Quản lý users
- `GET /admin/promotions` - Quản lý promotions

## Troubleshooting

### Container không start
```bash
./docker.sh logs  # Xem lỗi
docker ps         # Check containers
```

### Port bị chiếm
Đổi port trong `docker-compose.yml`:
```yaml
ports:
  - "3001:3000"  # Đổi 3000 -> 3001
```

### Reset toàn bộ
```bash
./docker.sh clean
./docker.sh setup
```

## Development

Mọi thay đổi code sẽ tự động reload.

**Thêm gem mới:**
```bash
# Thêm vào Gemfile
./docker.sh rebuild
```

**Rails commands:**
```bash
./docker.sh bash
# Trong container:
rails g model Product
rails g controller Products
```

## Production

```bash
# Build production image
docker build -t cb_image_be:latest .

# Deploy với Kamal
kamal setup
kamal deploy
```

## Cần giúp đỡ?

- Xem logs: `./docker.sh logs`
- Rails console: `./docker.sh console`
- Bash: `./docker.sh bash`
- Reset DB: `./docker.sh db-reset`

Happy coding! 🎉
