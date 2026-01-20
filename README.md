# CB Image - Subscription Management Platform

Hệ thống quản lý đăng ký và thanh toán người dùng được xây dựng bằng Ruby on Rails và MongoDB.

## Tổng quan

Ứng dụng quản lý người dùng, subscription (đăng ký gói dịch vụ), lịch sử mua hàng và các chương trình khuyến mãi. Hệ thống hỗ trợ:

- Đăng ký, đăng nhập, quản lý tài khoản người dùng
- Phân quyền: Admin và User thường
- Quản lý subscription (monthly/yearly)
- Lịch sử mua hàng
- Hệ thống khuyến mãi với mã giảm giá
- Gửi email thông báo

## Công nghệ sử dụng

- **Ruby**: 3.3.6
- **Rails**: 8.0.3
- **Database**: MongoDB (via Mongoid 9.0)
- **Authentication**: Devise 4.9
- **Authorization**: CanCanCan 3.5
- **Email**: ActionMailer

## Cấu trúc Database

### Models

#### User
- Email, password (Devise authentication)
- Role: `admin` hoặc `user`
- Tracking: sign_in_count, current_sign_in_at, last_sign_in_at
- Relationships: has_one :user_subscription, has_many :user_purchase_histories

#### UserSubscription
- subscription_type: `monthly` hoặc `yearly`
- start_date, end_date
- status: `active`, `expired`, `cancelled`
- auto_renew: tự động gia hạn
- price: giá subscription
- Relationships: belongs_to :user, belongs_to :promotion (optional)

#### UserPurchaseHistory
- purchase_type, amount, currency
- payment_method, transaction_id
- status: `completed`, `pending`, `failed`, `refunded`
- description, purchased_at
- Relationships: belongs_to :user, belongs_to :promotion (optional)

#### Promotion
- code: mã khuyến mãi (unique)
- discount_type: `percentage` hoặc `fixed`
- discount_value: giá trị giảm
- start_date, end_date: thời gian có hiệu lực
- max_uses, current_uses: số lần sử dụng
- active: kích hoạt/vô hiệu hóa
- min_purchase_amount: giá trị đơn hàng tối thiểu

## Cài đặt

### Yêu cầu hệ thống

- Ruby 3.3.6 hoặc cao hơn
- Rails 8.0.3
- MongoDB 4.4 hoặc cao hơn
- Docker và Docker Compose (tùy chọn, khuyến nghị)

### Cách 1: Cài đặt với Docker (Khuyến nghị) 🐳

**Nhanh nhất và dễ nhất - Chỉ cần Docker!**

```bash
# 1. Clone repository
git clone <repository-url>
cd cb_image_be

# 2. Setup và chạy (một lệnh duy nhất!)
./docker.sh setup

# Xong! Truy cập http://localhost:3000
```

Xem chi tiết tại [DOCKER.md](DOCKER.md)

**Services được khởi động:**
- Rails app: http://localhost:3000
- MailCatcher: http://localhost:1080
- MongoDB: localhost:27017

**Tài khoản đăng nhập:**
- Admin: admin@cbimage.com / password123
- User: user1@example.com / password123

### Cách 2: Cài đặt thủ công

#### Các bước cài đặt

1. **Clone repository**
```bash
git clone <repository-url>
cd cb_image_be
```

2. **Cài đặt dependencies**
```bash
bundle install
```

3. **Cài đặt MongoDB**

macOS (sử dụng Homebrew):
```bash
brew tap mongodb/brew
brew install mongodb-community
brew services start mongodb-community
```

Linux (Ubuntu/Debian):
```bash
wget -qO - https://www.mongodb.org/static/pgp/server-6.0.asc | sudo apt-key add -
echo "deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu $(lsb_release -cs)/mongodb-org/6.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-6.0.list
sudo apt-get update
sudo apt-get install -y mongodb-org
sudo systemctl start mongod
```

4. **Cấu hình database**

File `config/mongoid.yml` đã được tạo tự động. Mặc định kết nối đến:
- Host: localhost:27017
- Database: cb_image_be_development (development)

5. **Tạo admin user đầu tiên**

Mở Rails console:
```bash
rails console
```

Tạo admin user:
```ruby
User.create(
  email: 'admin@cbimage.com',
  password: 'password123',
  password_confirmation: 'password123',
  role: 'admin'
)
```

6. **Chạy server**
```bash
rails server
```

Ứng dụng sẽ chạy tại: http://localhost:3000

## Docker Usage 🐳

Xem hướng dẫn chi tiết tại [DOCKER.md](DOCKER.md)

**Quick Commands:**

```bash
# Setup lần đầu
./docker.sh setup

# Start/Stop
./docker.sh start
./docker.sh stop

# View logs
./docker.sh logs

# Rails console
./docker.sh console

# Seed data
./docker.sh db-seed
```

## Cấu hình Email

### Development

Trong môi trường development, email được cấu hình để sử dụng SMTP local (port 1025).

Để test email, bạn có thể sử dụng MailCatcher:
```bash
gem install mailcatcher
mailcatcher
```

Truy cập http://localhost:1080 để xem email.

### Production

Chỉnh sửa `config/environments/production.rb` và cấu hình SMTP settings:
```ruby
config.action_mailer.smtp_settings = {
  address: 'smtp.gmail.com',
  port: 587,
  user_name: ENV['SMTP_USERNAME'],
  password: ENV['SMTP_PASSWORD'],
  authentication: 'plain',
  enable_starttls_auto: true
}
```

## Routes

### Public Routes
- `GET /` - Trang chủ
- `GET /users/sign_in` - Đăng nhập
- `GET /users/sign_up` - Đăng ký
- `DELETE /users/sign_out` - Đăng xuất

### User Routes (yêu cầu đăng nhập)
- `GET /dashboard` - Dashboard người dùng
- `GET /dashboard/profile` - Trang profile
- `PATCH /dashboard/update_profile` - Cập nhật profile

### Subscription Routes
- `GET /subscription` - Xem subscription hiện tại
- `GET /subscription/new` - Tạo subscription mới
- `POST /subscription` - Lưu subscription
- `POST /subscription/cancel` - Hủy subscription

### Admin Routes (chỉ admin)
- `GET /admin` - Admin dashboard
- `GET /admin/users` - Danh sách users
- `GET /admin/users/:id` - Chi tiết user
- `GET /admin/promotions` - Quản lý khuyến mãi
- `POST /admin/promotions/:id/toggle_active` - Bật/tắt khuyến mãi

## Sử dụng

### Tạo subscription cho user

1. User đăng nhập
2. Truy cập `/subscription/new`
3. Chọn loại subscription (monthly/yearly)
4. Nhập mã khuyến mãi (nếu có)
5. Submit form

### Tạo promotion (Admin)

1. Đăng nhập với tài khoản admin
2. Truy cập `/admin/promotions`
3. Click "New Promotion"
4. Điền thông tin:
   - Code: mã khuyến mãi (unique)
   - Discount type: percentage hoặc fixed
   - Discount value: giá trị giảm
   - Start/End date: thời gian hiệu lực
5. Submit form

### Kiểm tra subscription của user

```ruby
# Trong controller hoặc view
if current_user.has_active_subscription?
  # Cho phép truy cập tính năng premium
else
  # Chuyển hướng đến trang subscription
end
```

Hoặc sử dụng before_action:
```ruby
class PremiumController < ApplicationController
  before_action :require_active_subscription
  
  def index
    # Chỉ user có subscription mới truy cập được
  end
end
```

## Email Notifications

Hệ thống tự động gửi email trong các trường hợp:

- Welcome email khi user đăng ký
- Subscription activated
- Subscription expiring soon (7 ngày trước khi hết hạn)
- Subscription expired
- Purchase confirmation

## Authorization (CanCanCan)

Phân quyền được định nghĩa trong `app/models/ability.rb`:

**Admin:**
- Có thể quản lý tất cả resources

**User:**
- Quản lý thông tin cá nhân của mình
- Quản lý subscription của mình
- Xem lịch sử mua hàng của mình
- Xem danh sách promotions

## Testing

Chạy test suite:
```bash
rails test
```

## Deployment

### Sử dụng Kamal (đã cấu hình)

Project đã được cấu hình sẵn với Kamal để deploy dễ dàng. Xem file `config/deploy.yml` để biết chi tiết.

### Environment Variables

Cần thiết lập các biến môi trường sau cho production:

```bash
RAILS_MASTER_KEY=<your-master-key>
MONGODB_URI=<your-mongodb-uri>
SMTP_USERNAME=<your-smtp-username>
SMTP_PASSWORD=<your-smtp-password>
```

## Troubleshooting

### MongoDB connection error

Kiểm tra MongoDB đã chạy:
```bash
# macOS
brew services list | grep mongodb

# Linux
sudo systemctl status mongod
```

Khởi động lại MongoDB:
```bash
# macOS
brew services restart mongodb-community

# Linux
sudo systemctl restart mongod
```

### Devise error

Nếu gặp lỗi với Devise, chạy:
```bash
rails g devise:install
rails g devise User
```

## Contributing

1. Fork repository
2. Tạo feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to branch (`git push origin feature/AmazingFeature`)
5. Tạo Pull Request

## License

Dự án này được phát hành theo giấy phép MIT.
