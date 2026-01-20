# Hướng dẫn cài đặt MongoDB

## macOS

### Cách 1: Sử dụng Homebrew (Khuyến nghị)

```bash
# Tap MongoDB repository
brew tap mongodb/brew

# Cài đặt MongoDB Community Edition
brew install mongodb-community

# Khởi động MongoDB
brew services start mongodb-community

# Kiểm tra MongoDB đã chạy
brew services list | grep mongodb-community
```

### Cách 2: Sử dụng Docker

```bash
# Pull MongoDB image
docker pull mongo:latest

# Chạy MongoDB container
docker run -d \
  --name mongodb \
  -p 27017:27017 \
  -v ~/data/mongodb:/data/db \
  mongo:latest

# Kiểm tra container đang chạy
docker ps | grep mongodb
```

## Linux (Ubuntu/Debian)

```bash
# Import MongoDB public GPG key
wget -qO - https://www.mongodb.org/static/pgp/server-6.0.asc | sudo apt-key add -

# Create list file for MongoDB
echo "deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu $(lsb_release -cs)/mongodb-org/6.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-6.0.list

# Update package database
sudo apt-get update

# Install MongoDB
sudo apt-get install -y mongodb-org

# Start MongoDB
sudo systemctl start mongod

# Enable MongoDB to start on boot
sudo systemctl enable mongod

# Check status
sudo systemctl status mongod
```

## Windows

### Cách 1: Sử dụng installer

1. Tải MongoDB Community Server từ: https://www.mongodb.com/try/download/community
2. Chạy installer (.msi file)
3. Chọn "Complete" installation
4. Chọn "Install MongoDB as a Service"
5. Click Install

### Cách 2: Sử dụng Chocolatey

```powershell
# Install MongoDB
choco install mongodb

# Start MongoDB service
net start MongoDB
```

## Kiểm tra kết nối

Sau khi cài đặt và khởi động MongoDB, kiểm tra kết nối:

```bash
# Sử dụng MongoDB shell
mongosh

# Hoặc kiểm tra từ Rails console
rails console

# Trong Rails console, chạy:
Mongoid.default_client.command(ping: 1)
```

## Cấu hình MongoDB cho Rails

File `config/mongoid.yml` đã được tạo tự động với cấu hình mặc định:

```yaml
development:
  clients:
    default:
      database: cb_image_be_development
      hosts:
        - localhost:27017
```

## Troubleshooting

### Lỗi: Connection refused

**macOS:**
```bash
# Khởi động lại MongoDB
brew services restart mongodb-community
```

**Linux:**
```bash
sudo systemctl restart mongod
```

**Docker:**
```bash
docker restart mongodb
```

### Lỗi: Port 27017 already in use

Kiểm tra process nào đang sử dụng port:
```bash
# macOS/Linux
lsof -i :27017

# Kill process nếu cần
kill -9 <PID>
```

### Lỗi: Permission denied

**macOS:**
```bash
sudo chown -R $(whoami) /usr/local/var/mongodb
```

**Linux:**
```bash
sudo chown -R mongodb:mongodb /var/lib/mongodb
sudo chown mongodb:mongodb /tmp/mongodb-27017.sock
```

## Sử dụng MongoDB Atlas (Cloud)

Nếu không muốn cài đặt MongoDB local, có thể sử dụng MongoDB Atlas (free tier):

1. Đăng ký tại: https://www.mongodb.com/cloud/atlas
2. Tạo free cluster
3. Tạo database user
4. Whitelist IP address (hoặc cho phép tất cả: 0.0.0.0/0)
5. Lấy connection string

Cập nhật `config/mongoid.yml`:
```yaml
development:
  clients:
    default:
      uri: mongodb+srv://username:password@cluster.mongodb.net/cb_image_be_development?retryWrites=true&w=majority
```

## Tiếp tục cài đặt project

Sau khi MongoDB đã chạy:

```bash
# Seed sample data
rails db:seed_data

# Chạy server
rails server
```

Truy cập: http://localhost:3000

Đăng nhập với:
- Admin: admin@cbimage.com / password123
- User: user1@example.com / password123
