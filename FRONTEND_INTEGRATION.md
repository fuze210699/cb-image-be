# Frontend Integration Guide

## 🌐 API Base URL

**Production:** `https://cb-image-api.fly.dev`
**Development:** `http://localhost:3000`

## 📋 Available Endpoints

### Authentication

#### 1. Login
```javascript
POST /api/v1/login
Content-Type: application/json

// Request Body
{
  "user": {
    "email": "user@example.com",
    "password": "password123"
  }
}

// Success Response (200 OK)
{
  "message": "Logged in successfully",
  "user": {
    "id": "507f1f77bcf86cd799439011",
    "email": "user@example.com",
    "role": "user", // or "admin" or "super_user"
    "created_at": "2026-01-20T10:00:00.000Z"
  }
}

// Error Response (401 Unauthorized)
{
  "error": "Invalid email or password"
}
```

#### 2. Logout
```javascript
DELETE /api/v1/logout

// Success Response (200 OK)
{
  "message": "Logged out successfully"
}
```

#### 3. Get Current User
```javascript
GET /api/v1/me

// Success Response (200 OK)
{
  "id": "507f1f77bcf86cd799439011",
  "email": "user@example.com",
  "role": "user",
  "has_active_subscription": true,
  "created_at": "2026-01-20T10:00:00.000Z"
}

// Error Response (401 Unauthorized)
{
  "error": "Not authenticated"
}
```

## 🔧 Frontend Setup (JavaScript/TypeScript)

### Using Fetch API

```javascript
const API_BASE_URL = 'https://cb-image-api.fly.dev';

// Login function
async function login(email, password) {
  const response = await fetch(`${API_BASE_URL}/api/v1/login`, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
    },
    credentials: 'include', // Important: Include cookies
    body: JSON.stringify({
      user: { email, password }
    })
  });

  if (!response.ok) {
    const error = await response.json();
    throw new Error(error.error || 'Login failed');
  }

  return await response.json();
}

// Get current user
async function getCurrentUser() {
  const response = await fetch(`${API_BASE_URL}/api/v1/me`, {
    method: 'GET',
    credentials: 'include', // Important: Include cookies
  });

  if (!response.ok) {
    throw new Error('Not authenticated');
  }

  return await response.json();
}

// Logout
async function logout() {
  const response = await fetch(`${API_BASE_URL}/api/v1/logout`, {
    method: 'DELETE',
    credentials: 'include', // Important: Include cookies
  });

  return await response.json();
}
```

### Using Axios

```javascript
import axios from 'axios';

const api = axios.create({
  baseURL: 'https://cb-image-api.fly.dev',
  withCredentials: true, // Important: Include cookies
  headers: {
    'Content-Type': 'application/json',
  }
});

// Login
export const login = async (email, password) => {
  try {
    const { data } = await api.post('/api/v1/login', {
      user: { email, password }
    });
    return data;
  } catch (error) {
    throw error.response?.data?.error || 'Login failed';
  }
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
```

## 🔐 CORS Configuration

The API is configured to accept requests from:
- `http://localhost:5173` (Development)
- `https://cb-image.com` (Production)
- `https://www.cb-image.com` (Production)

**Important:** Always use `credentials: 'include'` or `withCredentials: true` to send cookies with requests.

## 👤 Test Accounts

### Super User (Permanent Subscription)
```
Email: longpc.cbimage@wano.com
Password: LongPC123456789
Role: super_user
```

### Admin Account
```
Email: admin@example.com
Password: Admin123456789
Role: admin
```

### Regular Users
```
Email: user1@example.com - user5@example.com
Password: User123456789
Role: user
```

## 📊 User Roles

1. **user** - Regular user with basic permissions
2. **admin** - Administrator with full permissions
3. **super_user** - Special user with permanent active subscription

## ✅ Deployment Status

- ✅ App deployed: `https://cb-image-api.fly.dev`
- ✅ Health check: `https://cb-image-api.fly.dev/up`
- ✅ Region: Singapore (sin)
- ✅ Status: Running
- ✅ MongoDB: Connected to Atlas

## 🚀 React Example Component

```jsx
import { useState, useEffect } from 'react';

function LoginForm() {
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [user, setUser] = useState(null);
  const [error, setError] = useState('');

  const API_URL = 'https://cb-image-api.fly.dev';

  useEffect(() => {
    // Check if user is already logged in
    checkAuth();
  }, []);

  const checkAuth = async () => {
    try {
      const response = await fetch(`${API_URL}/api/v1/me`, {
        credentials: 'include'
      });
      if (response.ok) {
        const data = await response.json();
        setUser(data);
      }
    } catch (err) {
      // Not logged in
    }
  };

  const handleLogin = async (e) => {
    e.preventDefault();
    setError('');

    try {
      const response = await fetch(`${API_URL}/api/v1/login`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        credentials: 'include',
        body: JSON.stringify({ user: { email, password } })
      });

      if (!response.ok) {
        const data = await response.json();
        throw new Error(data.error);
      }

      const data = await response.json();
      setUser(data.user);
      setEmail('');
      setPassword('');
    } catch (err) {
      setError(err.message);
    }
  };

  const handleLogout = async () => {
    try {
      await fetch(`${API_URL}/api/v1/logout`, {
        method: 'DELETE',
        credentials: 'include'
      });
      setUser(null);
    } catch (err) {
      setError('Logout failed');
    }
  };

  if (user) {
    return (
      <div>
        <h2>Welcome, {user.email}!</h2>
        <p>Role: {user.role}</p>
        <p>Active Subscription: {user.has_active_subscription ? 'Yes' : 'No'}</p>
        <button onClick={handleLogout}>Logout</button>
      </div>
    );
  }

  return (
    <form onSubmit={handleLogin}>
      <h2>Login</h2>
      {error && <p style={{color: 'red'}}>{error}</p>}
      <input
        type="email"
        placeholder="Email"
        value={email}
        onChange={(e) => setEmail(e.target.value)}
        required
      />
      <input
        type="password"
        placeholder="Password"
        value={password}
        onChange={(e) => setPassword(e.target.value)}
        required
      />
      <button type="submit">Login</button>
    </form>
  );
}

export default LoginForm;
```

## 🔍 Testing the API

```bash
# Health check
curl https://cb-image-api.fly.dev/up

# Login
curl -X POST https://cb-image-api.fly.dev/api/v1/login \
  -H "Content-Type: application/json" \
  -d '{"user":{"email":"longpc.cbimage@wano.com","password":"LongPC123456789"}}' \
  -c cookies.txt

# Get current user
curl https://cb-image-api.fly.dev/api/v1/me \
  -b cookies.txt

# Logout
curl -X DELETE https://cb-image-api.fly.dev/api/v1/logout \
  -b cookies.txt
```

## 📝 Notes

- Session is managed via HTTP-only cookies (secure)
- CSRF protection is disabled for API endpoints
- All passwords must be at least 6 characters
- Email must be unique and valid format
