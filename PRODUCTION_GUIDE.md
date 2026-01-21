# 🚀 CB Image API - Production Guide

## 📋 Thông tin Deploy

### Production Environment
- **Platform:** Railway.app
- **URL:** https://cb-image-be-production.up.railway.app
- **Database:** MongoDB Atlas (Cluster0 - Singapore)
- **Region:** Singapore
- **Plan:** Hobby ($5/month)

### Trạng thái
- ✅ App deployed và đang chạy
- ✅ MongoDB connected
- ✅ Session management (24-hour expiry)
- ✅ CORS configured
- ✅ Database seeded

---

## 🌐 API Documentation

### Base URL
```
Production: https://cb-image-be-production.up.railway.app
Development: http://localhost:3000
```

### Authentication Endpoints

#### 1. Login
```http
POST /api/v1/login
Content-Type: application/json

{
  "email": "user@example.com",
  "password": "password123"
}
```

**Success Response (200):**
```json
{
  "success": true,
  "message": "Logged in successfully",
  "data": {
    "id": "67...",
    "email": "longpc.cbimage@wano.com",
    "role": "super_user",
    "is_super_user": true,
    "has_active_subscription": true,
    "created_at": "2026-01-20T..."
  }
}
```

**Error Response (401):**
```json
{
  "success": false,
  "message": "Invalid email or password"
}
```

#### 2. Ping (Session Check)
```http
GET /api/v1/ping
```

**Success Response (200):**
```json
{
  "success": true,
  "message": "Session is valid",
  "data": {
    "valid": true,
    "user": {
      "id": "67...",
      "email": "longpc.cbimage@wano.com",
      "role": "super_user"
    },
    "expires_at": "2026-01-22T10:00:00Z"
  }
}
```

**Error Response (401):**
```json
{
  "success": false,
  "message": "Not authenticated"
}
```

#### 3. Get Current User
```http
GET /api/v1/me
```

**Success Response (200):**
```json
{
  "success": true,
  "data": {
    "id": "67...",
    "email": "user@example.com",
    "role": "user",
    "has_active_subscription": true,
    "created_at": "2026-01-20T..."
  }
}
```

#### 4. Logout
```http
DELETE /api/v1/logout
```

**Success Response (200):**
```json
{
  "success": true,
  "message": "Logged out successfully"
}
```

---

## 🔐 Session Management

### Cấu hình
- **Type:** Cookie-based session
- **Expiry:** 24 hours từ lúc login
- **Cookie name:** `_cb_image_be_session`
- **Secure:** true (production only)
- **SameSite:** Lax
- **HttpOnly:** true

### Session Flow
1. User login → Server tạo session và set cookie
2. Cookie được gửi kèm với mọi request tiếp theo
3. Server check session validity và expiry time
4. Sau 24 giờ → session expired → user cần login lại

### Frontend Implementation

#### Check Session on App Load
```javascript
async function checkSession() {
  try {
    const response = await fetch('https://cb-image-be-production.up.railway.app/api/v1/ping', {
      credentials: 'include'
    });
    
    if (response.ok) {
      const data = await response.json();
      if (data.data.valid) {
        // Session valid
        return data.data.user;
      }
    }
    // Session invalid → redirect to login
    window.location.href = '/login';
  } catch (error) {
    console.error('Session check failed:', error);
  }
}
```

#### Periodic Session Check (every 5 minutes)
```javascript
setInterval(async () => {
  const response = await fetch('https://cb-image-be-production.up.railway.app/api/v1/ping', {
    credentials: 'include'
  });
  
  if (!response.ok) {
    // Session expired → redirect to login
    window.location.href = '/login';
  }
}, 5 * 60 * 1000); // 5 minutes
```

---

## 💻 Frontend Integration

### JavaScript/Fetch API

```javascript
const API_URL = 'https://cb-image-be-production.up.railway.app';

// Login
async function login(email, password) {
  const response = await fetch(`${API_URL}/api/v1/login`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    credentials: 'include', // Important!
    body: JSON.stringify({ email, password })
  });
  
  if (!response.ok) {
    const error = await response.json();
    throw new Error(error.message || 'Login failed');
  }
  
  return await response.json();
}

// Get current user
async function getCurrentUser() {
  const response = await fetch(`${API_URL}/api/v1/me`, {
    credentials: 'include' // Important!
  });
  
  if (!response.ok) throw new Error('Not authenticated');
  
  return await response.json();
}

// Logout
async function logout() {
  await fetch(`${API_URL}/api/v1/logout`, {
    method: 'DELETE',
    credentials: 'include'
  });
}
```

### Axios Setup

```javascript
import axios from 'axios';

const api = axios.create({
  baseURL: 'https://cb-image-be-production.up.railway.app',
  withCredentials: true, // Important!
  headers: { 'Content-Type': 'application/json' }
});

// Login
export const login = async (email, password) => {
  const { data } = await api.post('/api/v1/login', { email, password });
  return data;
};

// Ping
export const ping = async () => {
  const { data } = await api.get('/api/v1/ping');
  return data;
};

// Get current user
export const getCurrentUser = async () => {
  const { data } = await api.get('/api/v1/me');
  return data;
};

// Logout
export const logout = async () => {
  const { data } = await api.delete('/api/v1/logout');
  return data;
};

// Interceptor for handling 401 errors
api.interceptors.response.use(
  response => response,
  error => {
    if (error.response?.status === 401) {
      window.location.href = '/login';
    }
    return Promise.reject(error);
  }
);
```

### React Example Component

```jsx
import { useState, useEffect } from 'react';

function App() {
  const [user, setUser] = useState(null);
  const [loading, setLoading] = useState(true);

  const API_URL = 'https://cb-image-be-production.up.railway.app';

  useEffect(() => {
    checkAuth();
    
    // Periodic session check (every 5 minutes)
    const interval = setInterval(checkAuth, 5 * 60 * 1000);
    return () => clearInterval(interval);
  }, []);

  const checkAuth = async () => {
    try {
      const response = await fetch(`${API_URL}/api/v1/ping`, {
        credentials: 'include'
      });
      
      if (response.ok) {
        const data = await response.json();
        if (data.data.valid) {
          setUser(data.data.user);
        } else {
          setUser(null);
        }
      } else {
        setUser(null);
      }
    } catch (error) {
      console.error('Auth check failed:', error);
      setUser(null);
    } finally {
      setLoading(false);
    }
  };

  const handleLogin = async (email, password) => {
    try {
      const response = await fetch(`${API_URL}/api/v1/login`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        credentials: 'include',
        body: JSON.stringify({ email, password })
      });

      if (!response.ok) {
        const error = await response.json();
        throw new Error(error.message);
      }

      const data = await response.json();
      setUser(data.data);
    } catch (error) {
      alert(error.message);
    }
  };

  const handleLogout = async () => {
    await fetch(`${API_URL}/api/v1/logout`, {
      method: 'DELETE',
      credentials: 'include'
    });
    setUser(null);
  };

  if (loading) return <div>Loading...</div>;

  if (!user) {
    return <LoginForm onLogin={handleLogin} />;
  }

  return (
    <div>
      <h1>Welcome, {user.email}!</h1>
      <p>Role: {user.role}</p>
      <button onClick={handleLogout}>Logout</button>
    </div>
  );
}
```

---

## 🔧 CORS Configuration

API đã được cấu hình CORS cho:
- `http://localhost:5173` (Development)
- `https://cb-image.com` (Production)
- `https://www.cb-image.com` (Production)

**Important:** Luôn sử dụng `credentials: 'include'` hoặc `withCredentials: true` để gửi cookies!

---

## 👤 Test Accounts

### Super User (Permanent Subscription)
```
Email: longpc.cbimage@wano.com
Password: LongPC123456789
Role: super_user
```

### Admin Account
```
Email: admin@cbimage.com
Password: password123
Role: admin
```

### Regular Users
```
Email: user1@example.com, user2@example.com, ... user5@example.com
Password: User123456789
Role: user
```

---

## 🛠️ Railway Management

### Railway CLI

```bash
# Install
npm install -g @railway/cli

# Login
railway login

# Link to project
railway link

# View logs
railway logs

# Run commands
railway run rails console
railway run rails db:seed_data

# SSH into container
railway run bash
```

### Environment Variables

Đã được set:
```env
RAILS_ENV=production
RAILS_MASTER_KEY=64c1768021a5a96843c24e82389716cf
MONGODB_URI=mongodb+srv://cbimage_admin:ESVfBoOZ40Yqnc3K@cluster0.h9edu47.mongodb.net/cb_image_be_production
PORT=3000
RAILS_LOG_TO_STDOUT=true
RAILS_SERVE_STATIC_FILES=true
```

### View Logs

Railway Dashboard → Service → Deployments → View Logs

hoặc:
```bash
railway logs --tail 100
```

### Restart Service

```bash
railway restart
```

### Redeploy

```bash
# Push to GitHub main branch
git push origin master

# Railway auto-deploys
```

---

## 🗄️ Database Management

### Seed Database

```bash
# Via Railway CLI
railway run rails super_user:create
railway run rails db:seed_data

# Verify
railway run rails runner "puts 'Users: ' + User.count.to_s"
```

### MongoDB Access

**Connection String:**
```
mongodb+srv://cbimage_admin:ESVfBoOZ40Yqnc3K@cluster0.h9edu47.mongodb.net/cb_image_be_production
```

**Via Railway:**
```bash
railway run rails console

# In console:
User.count
Promotion.all.to_a
```

---

## 🧪 Testing API

### Test with cURL

```bash
# Health check
curl https://cb-image-be-production.up.railway.app/

# Login
curl -X POST https://cb-image-be-production.up.railway.app/api/v1/login \
  -H "Content-Type: application/json" \
  -d '{"email":"longpc.cbimage@wano.com","password":"LongPC123456789"}' \
  -c cookies.txt -v

# Ping (session check)
curl https://cb-image-be-production.up.railway.app/api/v1/ping \
  -b cookies.txt

# Get current user
curl https://cb-image-be-production.up.railway.app/api/v1/me \
  -b cookies.txt

# Logout
curl -X DELETE https://cb-image-be-production.up.railway.app/api/v1/logout \
  -b cookies.txt
```

---

## 📊 Models & Database Schema

### User Model
```ruby
# Attributes:
- email: String (unique, required)
- encrypted_password: String
- role: String ('user' | 'admin' | 'super_user')
- sign_in_count: Integer
- current_sign_in_at: Time
- last_sign_in_at: Time

# Methods:
- admin? -> Boolean
- is_super_user? -> Boolean
- has_active_subscription? -> Boolean
```

### UserSubscription Model
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
```

### UserPurchaseHistory Model
```ruby
# Attributes:
- purchase_type: String
- amount: Float
- currency: String (default: 'USD')
- payment_method: String
- transaction_id: String
- status: String ('completed' | 'pending' | 'failed' | 'refunded')
```

### Promotion Model
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
```

---

## 🔐 Security

- **CSRF Protection:** Disabled for API endpoints
- **Password Encryption:** Devise bcrypt
- **Session Security:** HttpOnly, Secure (production), SameSite=Lax
- **CORS:** Configured for specific origins
- **Authorization:** CanCanCan for role-based permissions

---

## 💰 Pricing

### Railway Hobby Plan
- **Cost:** $5/month
- **Includes:** $5 credit
- **Usage-based pricing:**
  - CPU: $0.000463/vCPU-hour
  - RAM: $0.000231/GB-hour

### MongoDB Atlas Free Tier
- **Cost:** Free
- **Storage:** Up to 512MB
- **Cluster:** M0 (Shared)

### Estimated Monthly Cost
- Rails App (1GB RAM 24/7): ~$5/month
- MongoDB Atlas: Free
- **Total: ~$5/month**

---

## 🚨 Troubleshooting

### API không response
```bash
# Check logs
railway logs

# Check service status
railway status
```

### Session không work
- Đảm bảo `credentials: 'include'` hoặc `withCredentials: true`
- Check CORS origin có đúng không
- Verify cookie được set (Chrome DevTools → Application → Cookies)

### 401 Unauthorized
- Session đã hết hạn (24h)
- Cookie không được gửi kèm request
- User chưa login

### MongoDB connection failed
```bash
# Check env vars
railway variables

# Test connection
railway run rails runner "puts Mongoid.default_client.cluster.summary"
```

---

## 📚 Local Development

### Requirements
- Ruby 3.3.6
- MongoDB 7.0+
- Rails 8.0.4

### Setup

```bash
# Install dependencies
bundle install

# Start MongoDB
brew services start mongodb-community

# Setup database
rails super_user:create
rails db:seed_data

# Start server
rails server
```

### Environment Variables (.env)

```env
MONGODB_URI=mongodb://localhost:27017/cb_image_be_development
RAILS_ENV=development
```

---

## 📞 Support & Resources

- **Railway Docs:** https://docs.railway.app
- **Railway Discord:** https://discord.gg/railway
- **MongoDB Atlas:** https://cloud.mongodb.com
- **Rails Guides:** https://guides.rubyonrails.org

---

## ✅ Frontend Integration Checklist

- [ ] Set `credentials: 'include'` trong tất cả API calls
- [ ] Implement session check khi app load
- [ ] Setup periodic ping mỗi 5 phút
- [ ] Handle 401 errors → redirect to login
- [ ] Test login flow với test account
- [ ] Update base URL cho production build
- [ ] Test session expiry (sau 24h)
- [ ] Implement logout functionality

---

## 🎉 Summary

**Production URL:** https://cb-image-be-production.up.railway.app

**Key Features:**
- ✅ Session-based authentication
- ✅ 24-hour session expiry
- ✅ Ping endpoint for session validation
- ✅ CORS configured for frontend
- ✅ MongoDB Atlas connected
- ✅ Auto-deploy from GitHub
- ✅ Test accounts seeded

**Ready for frontend integration!** 🚀
