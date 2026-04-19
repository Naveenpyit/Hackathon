# SmartApp - Development Agent Specification

## Overview
This document defines the development workflow, standards, and specifications for the SmartApp project. All agents must follow **Spec Driven Development (SDD)** and **Test Driven Development (TDD)**.

---

## Technology Stack

| Layer | Technology |
|-------|------------|
| Frontend | Flutter (Dart) |
| Backend | Deno (TypeScript) |
| Web Framework | Oak v12.6.1 |
| Database | Supabase (PostgreSQL) |
| Authentication | Supabase Auth (JWT) |

### Current Versions
- Deno: 1.x
- Oak: v12.6.1
- Supabase JS: 2.38.4
- Flutter: 3.x

---

## Project Structure

```
Smartapp/
├── backend/                 # Deno + Oak API
│   ├── src/
│   │   ├── main.ts          # Entry point
│   │   ├── config/          # Supabase client
│   │   ├── controllers/     # Request handlers
│   │   ├── services/       # Business logic
│   │   ├── routers/        # Route definitions
│   │   ├── middleware/     # Auth & validation
│   │   └── types/         # TypeScript interfaces
│   ├── deno.json           # Deno config
│   └── .env              # Environment variables
├── frontend/
│   └── smart_app/          # Flutter app
│       └── lib/
│           └── frontend/
│               ├── core/    # Services, network, utils
│               ├── config/ # Theme, strings
│               └── presentation/ # Screens, widgets
└── AGENTS.md              # This file
```

---

## API Specification

All APIs follow this response format:
```json
{
  "status": 1,        // 1 = success, 0 = error
  "message": "...",
  "data": {}
}
```

### Base URL
```
http://172.31.99.85:8000
```

### Authentication Endpoints

| Method | Endpoint | Auth | Description |
|--------|----------|------|-------------|
| POST | `/api/auth/signup` | No | Register new user |
| POST | `/api/auth/signin` | No | Login user |
| POST | `/api/auth/refresh` | No | Refresh access token |
| GET | `/api/auth/me` | Yes | Get current user |
| GET | `/api/auth/confirm` | No | Email confirmation (dev) |

### Designation Endpoints

| Method | Endpoint | Auth | Description |
|--------|----------|------|-------------|
| GET | `/api/designations` | No | Get all designations |

### Chat WebSocket Endpoints

| Method | Endpoint | Auth | Description |
|--------|----------|------|-------------|
| WS | `/ws/chat?token=<jwt>` | Yes | WebSocket chat connection |

---

## Database Schema

### Tables (Supabase)

#### `user_details`
| Column | Type | Constraints |
|--------|------|-------------|
| id | uuid | PRIMARY KEY |
| user_id | uuid | NOT NULL, UNIQUE |
| user_name | text | NOT NULL |
| email | text | NOT NULL |
| designation | integer | NULLABLE, FK → designation(id) |
| status | text | DEFAULT 'active' |
| shift_time | text | DEFAULT '9.30 to 6.30' |
| created_at | timestamp | DEFAULT NOW() |

#### `designation`
| Column | Type | Constraints |
|--------|------|-------------|
| id | integer | PRIMARY KEY, AUTO INCREMENT |
| name | text | NOT NULL |
| created_at | timestamp | DEFAULT NOW() |

#### `conversations`
| Column | Type | Constraints |
|--------|------|-------------|
| id | uuid | PRIMARY KEY |
| created_at | timestamp | DEFAULT NOW() |
| updated_at | timestamp | DEFAULT NOW() |

#### `conversation_participants`
| Column | Type | Constraints |
|--------|------|-------------|
| id | uuid | PRIMARY KEY |
| conversation_id | uuid | FK → conversations(id) |
| user_id | uuid | FK → user_details(id) |
| joined_at | timestamp | DEFAULT NOW() |

#### `messages`
| Column | Type | Constraints |
|--------|------|-------------|
| id | uuid | PRIMARY KEY |
| conversation_id | uuid | FK → conversations(id) |
| sender_id | uuid | FK → user_details(id) |
| content | text | NOT NULL |
| message_type | text | DEFAULT 'text' |
| is_read | boolean | DEFAULT false |
| created_at | timestamp | DEFAULT NOW() |

#### `user_sessions`
| Column | Type | Constraints |
|--------|------|-------------|
| id | uuid | PRIMARY KEY |
| user_id | uuid | FK → user_details(id) |
| socket_id | text | UNIQUE |
| connected_at | timestamp | DEFAULT NOW() |
| disconnected_at | timestamp | NULLABLE |

---

## Development Workflow

### 1. Spec Driven Development (SDD)
Before writing any code:
1. Define API specification in this AGENTS.md
2. Document request/response schemas
3. Define validation rules
4. Document error cases

### 2. Test Driven Development (TDD)
After spec is defined:
1. **Write integration tests FIRST** for all APIs
2. Run tests (should fail initially)
3. Implement code to pass tests
4. Refactor if needed
5. Ensure all tests pass

---

## Testing Requirements

### Backend Tests
- All API endpoints MUST have integration tests
- Tests located in: `backend/tests/`
- Run tests: `deno test --allow-all`

### Test Structure
```typescript
// backend/tests/auth_api_test.ts
import { assertEquals } from "https://deno.land/std@0.208.0/assert/mod.ts";

Deno.test("POST /api/auth/signin - valid credentials", async () => {
  const response = await fetch("http://localhost:8000/api/auth/signin", {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({
      email: "test@example.com",
      password: "Test1234",
    }),
  });

  const data = await response.json();
  assertEquals(response.status, 200);
  assertEquals(data.status, 1);
});
```

### Required Tests Per Endpoint

#### Auth APIs
- [ ] POST `/api/auth/signin` - valid credentials
- [ ] POST `/api/auth/signin` - invalid password
- [ ] POST `/api/auth/signin` - non-existent user
- [ ] POST `/api/auth/signup` - valid data
- [ ] POST `/api/auth/signup` - duplicate email
- [ ] POST `/api/auth/signup` - weak password
- [ ] POST `/api/auth/signup` - invalid email format
- [ ] POST `/api/auth/refresh` - valid refresh token
- [ ] POST `/api/auth/refresh` - invalid refresh token
- [ ] GET `/api/auth/me` - with valid token
- [ ] GET `/api/auth/me` - without token (401)

#### Designation APIs
- [ ] GET `/api/designations` - success
- [ ] GET `/api/designations` - empty table

---

## Validation Rules

### signup
| Field | Type | Required | Validation |
|-------|------|----------|------------|
| email | string | Yes | Valid email format |
| password | string | Yes | Min 8 chars, 1 upper, 1 lower, 1 number |
| user_name | string | Yes | Non-empty string |
| designation_id | number | No | Must exist in designation table |
| status | string | No | Default: 'active' |
| shift_time | string | No | Default: '9.30 to 6.30' |

### signin
| Field | Type | Required | Validation |
|-------|------|----------|------------|
| email | string | Yes | Valid email format |
| password | string | Yes | Non-empty |

### refresh
| Field | Type | Required | Validation |
|-------|------|----------|------------|
| refresh_token | string | Yes | Valid Supabase refresh token |

---

## Security Constraints

1. **Password Requirements**
   - Minimum 8 characters
   - At least 1 uppercase letter
   - At least 1 lowercase letter
   - At least 1 number

2. **Token Handling**
   - Access tokens stored securely on client
   - Refresh tokens for session persistence
   - Bearer token required for protected routes

3. **CORS**
   - Allows all origins (`*`) for development
   - Should be restricted in production

4. **Environment Variables**
   - Never commit `.env` to version control
   - Use `.env.example` as template

---

## Frontend API Integration

### Flutter Service Layer
- Base URL: `http://172.31.99.85:8000`
- Content-Type: `application/json`
- Timeout: 15 seconds

### Error Handling
```dart
class SignupResult {
  final bool success;
  final String message;
  final SignupData? data;
}
```

---

## Common Error Responses

| Status Code | Message | Cause |
|------------|---------|-------|
| 400 | Invalid email format | Email validation failed |
| 400 | Password must be at least 8 characters | Weak password |
| 400 | Email already exists | Duplicate email |
| 401 | Invalid email or password | Auth failure |
| 401 | Authorization token missing | No Bearer token |
| 401 | Invalid or expired token | Token validation failed |
| 404 | Route not found | Unknown endpoint |
| 500 | Internal server error | Server exception |

---

## Development Commands

### Backend
```bash
# Run development server (with watch)
deno task dev

# Run production server
deno task start

# Run tests
deno test --allow-all

# Type check
deno check src/main.ts
```

### Frontend
```bash
# Run Flutter
cd frontend/smart_app
flutter run

# Run tests
flutter test
```

---

## Workflow Checklist

Before delivering code:

- [ ] API spec documented in AGENTS.md
- [ ] Integration tests written for all endpoints
- [ ] All tests passing
- [ ] No type errors (`deno check`)
- [ ] Error cases handled
- [ ] Validation rules implemented
- [ ] CORS configured
- [ ] Health check endpoint responding

---

## Future Additions

When adding new features:
1. Document in AGENTS.md
2. Add to API specification table
3. Write tests first
4. Implement feature
5. Run tests
6. Deliver