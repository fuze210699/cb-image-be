# Docker Setup for CB Image

## Yêu cầu

- Docker Desktop (macOS/Windows) hoặc Docker Engine (Linux)
- Docker Compose V2

## Cài đặt Docker

### macOS

```bash
# Tải Docker Desktop từ
https://www.docker.com/products/docker-desktop/

# Hoặc sử dụng Homebrew
brew install --cask docker
```

### Linux (Ubuntu/Debian)

```bash
# Cài đặt Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# Thêm user vào docker group
sudo usermod -aG docker $USER
newgrp docker

# Cài đặt Docker Compose
sudo apt-get install docker-compose-plugin
```

### Windows

Tải Docker Desktop từ: https://www.docker.com/products/docker-desktop/

## Cấu trúc Docker

Dự án sử dụng 3 services:

1. **mongodb** - MongoDB 7.0 database
   - Port: 27017
   - Username: admin
   - Password: admin123

2. **web** - Rails application
   - Port: 3000
   - Auto-reload khi code thay đổi

3. **mailcatcher** - Email testing tool
   - Web UI: http://localhost:1080
   - SMTP: localhost:1025

## Sử dụng

### Script helper (Khuyến nghị)

```bash
# Setup lần đầu (build images + start services + seed data)
./docker.sh setup

# Start services
./docker.sh start

# Stop services
./docker.sh stop

# Restart services
./docker.sh restart

# Xem logs
./docker.sh logs

# Mở Rails console
./docker.sh console

# Mở bash trong container
./docker.sh bash

# Seed database
./docker.sh db-seed

# Reset database
./docker.sh db-reset

# Xem containers đang chạy
./docker.sh ps

# Rebuild containers
./docker.sh rebuild

# Xóa tất cả (containers, volumes, images)
./docker.sh clean
```

### Lệnh Docker Compose trực tiếp

```bash
# Build và start services
docker-compose up -d

# Stop services
docker-compose stop

# Stop và remove containers
docker-compose down

# View logs
docker-compose logs -f web

# Rails console
docker-compose exec web bundle exec rails console

# Bash trong container
docker-compose exec web bash

# Run migrations (nếu có)
docker-compose exec web bundle exec rails db:migrate

# Seed database
docker-compose exec web bundle exec rails db:seed_data
```

## Truy cập ứng dụng

Sau khi chạy `./docker.sh setup` hoặc `docker-compose up -d`:

- **Web Application**: http://localhost:3000
- **MailCatcher UI**: http://localhost:1080
- **MongoDB**: localhost:27017

### Tài khoản đăng nhập

Sau khi seed data:

- **Admin**: admin@cbimage.com / password123
- **User**: user1@example.com / password123

## Volumes

Data được lưu trong Docker volumes:

- `mongodb_data` - MongoDB data
- `mongodb_config` - MongoDB config
- `bundle_cache` - Ruby gems
- `node_modules` - Node packages

Để xóa tất cả data:
```bash
docker-compose down -v
```

## Development Workflow

### 1. Khởi động project

```bash
./docker.sh setup
```

### 2. Làm việc với code

Code của bạn được mount vào container, mọi thay đổi sẽ được auto-reload nhờ Rails development mode.

### 3. Xem logs

```bash
./docker.sh logs
# hoặc chỉ xem logs của web service
docker-compose logs -f web
```

### 4. Chạy Rails console

```bash
./docker.sh console
```

### 5. Chạy các lệnh Rails khác

```bash
# Generate model
docker-compose exec web bundle exec rails g model Product

# Run migration
docker-compose exec web bundle exec rails db:migrate

# Generate controller
docker-compose exec web bundle exec rails g controller Products
```

### 6. Cài thêm gems

Sau khi thêm gem vào Gemfile:

```bash
# Rebuild container để install gem mới
./docker.sh rebuild

# Hoặc install trong container đang chạy
docker-compose exec web bundle install
docker-compose restart web
```

## Testing Email

MailCatcher đã được cấu hình sẵn:

1. Mọi email gửi từ app sẽ được MailCatcher bắt
2. Truy cập http://localhost:1080 để xem emails
3. SMTP server: mailcatcher:1025 (trong container)

## Troubleshooting

### Container không start

```bash
# Xem logs để biết lỗi
docker-compose logs web

# Kiểm tra MongoDB
docker-compose logs mongodb
```

### MongoDB connection error

```bash
# Restart MongoDB
docker-compose restart mongodb

# Chờ MongoDB ready
docker-compose exec mongodb mongosh --eval "db.adminCommand('ping')"
```

### Port đã được sử dụng

Nếu port 3000, 27017, hoặc 1080 đã được sử dụng:

1. Stop service đang dùng port đó
2. Hoặc thay đổi port trong `docker-compose.yml`

```yaml
# Ví dụ: Đổi port 3000 -> 3001
services:
  web:
    ports:
      - "3001:3000"  # host:container
```

### Rebuild từ đầu

```bash
# Xóa tất cả và rebuild
./docker.sh clean
./docker.sh setup
```

### Container chạy chậm (macOS)

Nếu gặp vấn đề performance trên macOS:

1. Tăng resource cho Docker Desktop (Settings > Resources)
2. Sử dụng `:cached` cho volumes (đã config sẵn)

### Xem resource usage

```bash
docker stats
```

## Production Deployment

Để deploy production, sử dụng `Dockerfile` chính (không phải `Dockerfile.dev`):

```bash
# Build production image
docker build -t cb_image_be:latest .

# Run với environment variables
docker run -d \
  -p 80:80 \
  -e RAILS_MASTER_KEY=<your-key> \
  -e MONGODB_URI=<your-mongodb-uri> \
  --name cb_image_be \
  cb_image_be:latest
```

Hoặc sử dụng Kamal (đã config sẵn):
```bash
kamal setup
kamal deploy
```

## Cleaning Up

### Xóa containers và networks

```bash
docker-compose down
```

### Xóa containers, networks và volumes

```bash
docker-compose down -v
```

### Xóa tất cả (bao gồm images)

```bash
./docker.sh clean
```

## Environment Variables

Tạo file `.env` từ `.env.example`:

```bash
cp .env.example .env
```

Chỉnh sửa các giá trị trong `.env` nếu cần.

## MongoDB GUI Tools

Để kết nối với MongoDB bằng GUI tools:

**MongoDB Compass:**
- Connection String: `mongodb://admin:admin123@localhost:27017`
- Authentication Database: admin

**Studio 3T:**
- Host: localhost
- Port: 27017
- Username: admin
- Password: admin123
- Auth DB: admin

## Backup & Restore

### Backup MongoDB

```bash
docker-compose exec mongodb mongodump \
  --username admin \
  --password admin123 \
  --authenticationDatabase admin \
  --out /data/backup

# Copy backup ra host
docker cp cb_image_mongodb:/data/backup ./mongodb_backup
```

### Restore MongoDB

```bash
# Copy backup vào container
docker cp ./mongodb_backup cb_image_mongodb:/data/backup

# Restore
docker-compose exec mongodb mongorestore \
  --username admin \
  --password admin123 \
  --authenticationDatabase admin \
  /data/backup
```

## Tips

1. **Keep containers running**: Dùng `docker-compose up -d` để chạy background
2. **View logs**: `docker-compose logs -f` để xem realtime logs
3. **Clean up**: Chạy `docker system prune` thường xuyên để dọn dẹp
4. **Monitor**: Dùng `docker stats` để theo dõi resource usage
5. **Shell access**: Dùng `./docker.sh bash` để debug trong container

## Next Steps

Sau khi setup xong:

1. Truy cập http://localhost:3000
2. Đăng nhập với tài khoản admin hoặc user
3. Test các tính năng subscription
4. Xem emails tại http://localhost:1080
5. Bắt đầu phát triển!
