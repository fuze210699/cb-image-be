# Tài liệu API và Hướng dẫn phát triển

## Cấu trúc dự án

### Models

#### User Model
```ruby
# Attributes:
- email: String (unique, required)
- encrypted_password: String
- role: String ('user' | 'admin')
- sign_in_count: Integer
- current_sign_in_at: Time
- last_sign_in_at: Time

# Methods:
- admin? -> Boolean
- has_active_subscription? -> Boolean
```

#### UserSubscription Model
```ruby
# Attributes:
- subscription_type: String ('monthly' | 'yearly')
- start_date: DateTime
- end_date: DateTime
- status: String ('active' | 'expired' | 'cancelled')
- auto_renew: Boolean
- price: Float

# Methods:
- active? -> Boolean
- expired? -> Boolean
- cancel! -> Boolean
- renew!(duration) -> Boolean
```

#### UserPurchaseHistory Model
```ruby
# Attributes:
- purchase_type: String
- amount: Float
- currency: String (default: 'USD')
- payment_method: String
- transaction_id: String
- status: String ('completed' | 'pending' | 'failed' | 'refunded')
- description: String
- purchased_at: DateTime

# Methods:
- refund! -> Boolean
- failed! -> Boolean
```

#### Promotion Model
```ruby
# Attributes:
- code: String (unique)
- description: String
- discount_type: String ('percentage' | 'fixed')
- discount_value: Float
- start_date: DateTime
- end_date: DateTime
- max_uses: Integer
- current_uses: Integer
- active: Boolean
- min_purchase_amount: Float

# Methods:
- valid? -> Boolean
- apply_discount(amount) -> Float
- use! -> Boolean
- deactivate! -> Boolean
```

## Controllers

### ApplicationController
Base controller cho tất cả controllers.

**Methods:**
- `require_active_subscription`: Before action để check subscription

### HomeController
Quản lý trang chủ.

**Actions:**
- `index`: Hiển thị trang chủ và promotions đang active

### DashboardController
Dashboard của user (yêu cầu đăng nhập).

**Actions:**
- `index`: Trang dashboard chính
- `profile`: Trang profile
- `update_profile`: Cập nhật thông tin profile

### SubscriptionsController
Quản lý subscriptions.

**Actions:**
- `show`: Xem subscription hiện tại
- `new`: Form tạo subscription mới
- `create`: Tạo subscription
- `cancel`: Hủy subscription

### Admin::BaseController
Base controller cho admin area.

**Before Actions:**
- `authenticate_user!`
- `check_admin`: Kiểm tra quyền admin

### Admin::DashboardController
Dashboard cho admin.

**Actions:**
- `index`: Thống kê tổng quan

### Admin::UsersController
Quản lý users (admin only).

**Actions:**
- `index`: Danh sách users
- `show`: Chi tiết user
- `edit`: Form chỉnh sửa
- `update`: Cập nhật user
- `destroy`: Xóa user

### Admin::PromotionsController
Quản lý promotions (admin only).

**Actions:**
- `index`: Danh sách promotions
- `new`: Form tạo promotion
- `create`: Tạo promotion
- `edit`: Form chỉnh sửa
- `update`: Cập nhật promotion
- `destroy`: Xóa promotion
- `toggle_active`: Bật/tắt promotion

## Mailers

### UserMailer
Gửi email cho users.

**Methods:**
- `welcome_email(user)`: Email chào mừng
- `subscription_activated(user, subscription)`: Thông báo subscription active
- `subscription_expiring_soon(user, subscription)`: Cảnh báo sắp hết hạn
- `subscription_expired(user, subscription)`: Thông báo hết hạn
- `purchase_confirmation(user, purchase)`: Xác nhận mua hàng

## Authorization (CanCanCan)

File: `app/models/ability.rb`

### Admin abilities:
```ruby
can :manage, :all
```

### User abilities:
```ruby
can :read, :all
can :manage, User, id: user.id
can :manage, UserSubscription, user_id: user.id
can :read, UserPurchaseHistory, user_id: user.id
can :read, Promotion
```

## Sử dụng trong code

### Kiểm tra subscription
```ruby
# Trong controller
class PremiumFeaturesController < ApplicationController
  before_action :require_active_subscription
  
  def index
    # Premium content
  end
end

# Trong view
<% if current_user.has_active_subscription? %>
  <%= link_to "Premium Feature", premium_path %>
<% else %>
  <%= link_to "Subscribe Now", new_subscription_path %>
<% end %>
```

### Áp dụng promotion
```ruby
promotion = Promotion.find_by(code: params[:code])
if promotion&.valid?
  discounted_price = promotion.apply_discount(original_price)
  promotion.use!
end
```

### Gửi email
```ruby
# Sau khi tạo subscription
UserMailer.subscription_activated(user, subscription).deliver_later

# Sau khi mua hàng
UserMailer.purchase_confirmation(user, purchase).deliver_later
```

### Kiểm tra quyền admin
```ruby
# Trong controller
if current_user.admin?
  # Admin features
end

# Sử dụng CanCanCan
authorize! :manage, @user
```

## Rake Tasks

### Seed sample data
```bash
rails db:seed_data
```

Tạo:
- 1 admin user (admin@cbimage.com / password123)
- 5 regular users (user1@example.com ... user5@example.com / password123)
- 2 sample promotions (WELCOME20, SAVE10)

## Background Jobs (Future Implementation)

Các background jobs nên được thêm vào:

1. **SubscriptionRenewalJob**: Tự động gia hạn subscription
2. **SubscriptionExpirationCheckJob**: Kiểm tra và gửi email cảnh báo
3. **ExpiredSubscriptionJob**: Cập nhật status của subscription hết hạn

Example:
```ruby
# app/jobs/subscription_expiration_check_job.rb
class SubscriptionExpirationCheckJob < ApplicationJob
  queue_as :default

  def perform
    # Find subscriptions expiring in 7 days
    expiring_soon = UserSubscription.where(
      :end_date.gte => Time.current,
      :end_date.lte => Time.current + 7.days,
      status: 'active'
    )

    expiring_soon.each do |subscription|
      UserMailer.subscription_expiring_soon(
        subscription.user,
        subscription
      ).deliver_later
    end
  end
end
```

## Testing

### Model Tests
```ruby
# test/models/user_test.rb
require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "admin? returns true for admin users" do
    user = User.new(role: 'admin')
    assert user.admin?
  end

  test "has_active_subscription? returns false without subscription" do
    user = User.create(email: 'test@example.com', password: 'password123')
    assert_not user.has_active_subscription?
  end
end
```

### Controller Tests
```ruby
# test/controllers/subscriptions_controller_test.rb
require "test_helper"

class SubscriptionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    sign_in @user
  end

  test "should get new" do
    get new_subscription_url
    assert_response :success
  end
end
```

## API Endpoints (Future)

Nếu cần xây dựng API:

### Authentication
```
POST /api/v1/auth/login
POST /api/v1/auth/signup
DELETE /api/v1/auth/logout
```

### Users
```
GET /api/v1/users/me
PATCH /api/v1/users/me
```

### Subscriptions
```
GET /api/v1/subscriptions
POST /api/v1/subscriptions
DELETE /api/v1/subscriptions/:id
```

### Promotions
```
GET /api/v1/promotions
POST /api/v1/promotions/validate
```

## Security Considerations

1. **CSRF Protection**: Enabled by default in Rails
2. **Strong Parameters**: Sử dụng trong tất cả controllers
3. **Password Encryption**: Devise tự động mã hóa
4. **Authorization**: CanCanCan check permissions
5. **SQL Injection**: MongoDB driver tự động escape

## Performance Optimization

### Indexes
Các indexes quan trọng đã được tạo:
- User: email, role
- UserSubscription: user_id, status, end_date
- UserPurchaseHistory: user_id, purchased_at, status
- Promotion: code, active, start_date + end_date

### Caching (Future)
```ruby
# Cache promotions
@promotions = Rails.cache.fetch('active_promotions', expires_in: 1.hour) do
  Promotion.active.valid_now.to_a
end
```

## Monitoring (Future)

Recommend installing:
- **New Relic**: Application monitoring
- **Sentry**: Error tracking
- **LogRocket**: Session replay

## Environment Variables

### Development
```
MONGODB_URI=mongodb://localhost:27017/cb_image_be_development
```

### Production
```
MONGODB_URI=mongodb+srv://user:pass@cluster.mongodb.net/cb_image_be_production
SMTP_USERNAME=your_smtp_username
SMTP_PASSWORD=your_smtp_password
SECRET_KEY_BASE=your_secret_key_base
```
