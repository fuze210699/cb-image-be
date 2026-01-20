# API Documentation

## Base URL
```
http://localhost:3000/api/v1
```

## Authentication API

### 1. Login
**Endpoint:** `POST /api/v1/login`

**Request Headers:**
```
Content-Type: application/json
```

**Request Body:**
```json
{
  "email": "longpc.cbimage@wano.com",
  "password": "LongPC123456789"
}
```

**Success Response (200):**
```json
{
  "success": true,
  "message": "Logged in successfully",
  "data": {
    "id": "679abcdef1234567890",
    "email": "longpc.cbimage@wano.com",
    "role": "super_user",
    "is_admin": false,
    "is_super_user": true,
    "has_active_subscription": true,
    "subscription": null,
    "sign_in_count": 5,
    "current_sign_in_at": "2026-01-20T10:30:00.000Z",
    "last_sign_in_at": "2026-01-19T15:20:00.000Z",
    "created_at": "2026-01-15T08:00:00.000Z",
    "updated_at": "2026-01-20T10:30:00.000Z"
  }
}
```

**Error Response (401):**
```json
{
  "error": "Invalid email or password"
}
```

---

### 2. Get Current User Info
**Endpoint:** `GET /api/v1/me`

**Request Headers:**
```
Cookie: _cb_image_session=<session-cookie>
```

**Success Response (200):**
```json
{
  "success": true,
  "data": {
    "id": "679abcdef1234567890",
    "email": "longpc.cbimage@wano.com",
    "role": "super_user",
    "is_admin": false,
    "is_super_user": true,
    "has_active_subscription": true,
    "subscription": null,
    "sign_in_count": 5,
    "current_sign_in_at": "2026-01-20T10:30:00.000Z",
    "last_sign_in_at": "2026-01-19T15:20:00.000Z",
    "created_at": "2026-01-15T08:00:00.000Z",
    "updated_at": "2026-01-20T10:30:00.000Z"
  }
}
```

**Error Response (401):**
```json
{
  "error": "You need to sign in or sign up before continuing."
}
```

---

### 3. Logout
**Endpoint:** `DELETE /api/v1/logout`

**Request Headers:**
```
Cookie: _cb_image_session=<session-cookie>
```

**Success Response (200):**
```json
{
  "success": true,
  "message": "Logged out successfully",
  "data": null
}
```

---

## Response Examples for Different User Types

### Regular User (với subscription)
```json
{
  "success": true,
  "message": "Logged in successfully",
  "data": {
    "id": "679abcdef1234567891",
    "email": "user1@example.com",
    "role": "user",
    "is_admin": false,
    "is_super_user": false,
    "has_active_subscription": true,
    "subscription": {
      "id": "679xyz123456789",
      "subscription_type": "monthly",
      "start_date": "2026-01-01T00:00:00.000Z",
      "end_date": "2026-02-01T00:00:00.000Z",
      "status": "active",
      "auto_renew": true,
      "price": 9.99,
      "days_remaining": 12,
      "is_active": true,
      "is_expired": false
    },
    "sign_in_count": 3,
    "current_sign_in_at": "2026-01-20T09:15:00.000Z",
    "last_sign_in_at": "2026-01-18T14:30:00.000Z",
    "created_at": "2025-12-20T08:00:00.000Z",
    "updated_at": "2026-01-20T09:15:00.000Z"
  }
}
```

### Admin User
```json
{
  "success": true,
  "message": "Logged in successfully",
  "data": {
    "id": "679admin123456789",
    "email": "admin@cbimage.com",
    "role": "admin",
    "is_admin": true,
    "is_super_user": false,
    "has_active_subscription": false,
    "subscription": null,
    "sign_in_count": 50,
    "current_sign_in_at": "2026-01-20T11:00:00.000Z",
    "last_sign_in_at": "2026-01-20T08:30:00.000Z",
    "created_at": "2025-12-01T00:00:00.000Z",
    "updated_at": "2026-01-20T11:00:00.000Z"
  }
}
```

### Super User (permanent subscription)
```json
{
  "success": true,
  "message": "Logged in successfully",
  "data": {
    "id": "679super123456789",
    "email": "longpc.cbimage@wano.com",
    "role": "super_user",
    "is_admin": false,
    "is_super_user": true,
    "has_active_subscription": true,
    "subscription": null,
    "sign_in_count": 10,
    "current_sign_in_at": "2026-01-20T10:30:00.000Z",
    "last_sign_in_at": "2026-01-19T15:20:00.000Z",
    "created_at": "2026-01-15T08:00:00.000Z",
    "updated_at": "2026-01-20T10:30:00.000Z"
  }
}
```

### User without subscription
```json
{
  "success": true,
  "message": "Logged in successfully",
  "data": {
    "id": "679user999",
    "email": "newuser@example.com",
    "role": "user",
    "is_admin": false,
    "is_super_user": false,
    "has_active_subscription": false,
    "subscription": null,
    "sign_in_count": 1,
    "current_sign_in_at": "2026-01-20T12:00:00.000Z",
    "last_sign_in_at": null,
    "created_at": "2026-01-20T12:00:00.000Z",
    "updated_at": "2026-01-20T12:00:00.000Z"
  }
}
```

---

## Frontend Integration (Vite/React Example)

### Login Function
```javascript
// api/auth.js
const API_URL = 'http://localhost:3000/api/v1';

export const login = async (email, password) => {
  const response = await fetch(`${API_URL}/login`, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
    },
    credentials: 'include', // Important: include cookies
    body: JSON.stringify({ email, password })
  });

  const data = await response.json();
  
  if (!response.ok) {
    throw new Error(data.error || 'Login failed');
  }
  
  return data;
};

export const getCurrentUser = async () => {
  const response = await fetch(`${API_URL}/me`, {
    credentials: 'include'
  });

  const data = await response.json();
  
  if (!response.ok) {
    throw new Error(data.error || 'Failed to get user info');
  }
  
  return data;
};

export const logout = async () => {
  const response = await fetch(`${API_URL}/logout`, {
    method: 'DELETE',
    credentials: 'include'
  });

  const data = await response.json();
  
  if (!response.ok) {
    throw new Error(data.error || 'Logout failed');
  }
  
  return data;
};
```

### Usage in Component
```javascript
// Login.jsx
import { useState } from 'react';
import { login } from './api/auth';

function Login() {
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [error, setError] = useState('');

  const handleSubmit = async (e) => {
    e.preventDefault();
    setError('');
    
    try {
      const response = await login(email, password);
      console.log('User:', response.data);
      
      // Store user data or redirect
      localStorage.setItem('user', JSON.stringify(response.data));
      
      // Check subscription
      if (response.data.has_active_subscription) {
        console.log('User has active subscription!');
      }
      
      // Redirect based on role
      if (response.data.is_admin) {
        window.location.href = '/admin';
      } else if (response.data.is_super_user) {
        console.log('Welcome Super User!');
        window.location.href = '/dashboard';
      } else {
        window.location.href = '/dashboard';
      }
      
    } catch (err) {
      setError(err.message);
    }
  };

  return (
    <form onSubmit={handleSubmit}>
      <input
        type="email"
        value={email}
        onChange={(e) => setEmail(e.target.value)}
        placeholder="Email"
        required
      />
      <input
        type="password"
        value={password}
        onChange={(e) => setPassword(e.target.value)}
        placeholder="Password"
        required
      />
      {error && <div className="error">{error}</div>}
      <button type="submit">Login</button>
    </form>
  );
}

export default Login;
```

---

## Testing with cURL

### Login
```bash
curl -X POST http://localhost:3000/api/v1/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "longpc.cbimage@wano.com",
    "password": "LongPC123456789"
  }' \
  -c cookies.txt
```

### Get Current User
```bash
curl -X GET http://localhost:3000/api/v1/me \
  -b cookies.txt
```

### Logout
```bash
curl -X DELETE http://localhost:3000/api/v1/logout \
  -b cookies.txt
```

---

## Important Notes

1. **Credentials:** Set `credentials: 'include'` in fetch để cookies được gửi kèm
2. **CORS:** Đã cấu hình cho `localhost:5173`
3. **Session-based:** Sử dụng cookies, không cần token
4. **Super User:** `has_active_subscription` luôn `true`, `subscription` là `null`
5. **Response Format:** Luôn có `success`, `data`, và `message` (optional)
