# Auth API - مستندات کامل احراز هویت

## 1. Check Phone (بررسی وجود شماره)

### Endpoint
```
POST /api/v1/auth/check-phone
```

### Request Body
```typescript
{
  "phone": string  // مثال: "09123456789"
}
```

### Validation Rules
- phone: required, string, regex: `^09[0-9]{9}$`

### Response Success (200)
```json
{
  "success": true,
  "message": "بررسی انجام شد",
  "data": {
    "exists": boolean
  },
  "timestamp": "2025-11-16T12:00:00.000Z"
}
```

### Response Errors
- `400` - شماره موبایل نامعتبر است
- `429` - Too Many Requests

### Backend Implementation Checklist:
- [x] DTO: `CheckPhoneDto` در `backend/src/modules/auth/dto/check-phone.dto.ts`
- [x] Service method: `checkPhone()` در `AuthService`
- [x] Controller: `@Post('check-phone')` در `AuthController`

### Flutter Implementation Checklist:
- [x] API Service: `@POST('/auth/check-phone')` در `auth_api_service.dart`
- [x] Repository: `checkPhone()` در `auth_repository.dart`
- [x] Use Case: `CheckPhoneUseCase` در `auth_usecases.dart`
- [x] BLoC Event: `CheckPhoneEvent` در `auth_event.dart`
- [x] BLoC State: `AuthPhoneExists`, `AuthPhoneNotExists` در `auth_state.dart`

---

## 2. Register (ثبت‌نام)

### Endpoint
```
POST /api/v1/auth/register
```

### Request Body
```typescript
{
  "fullName": string,  // مثال: "علی محمدی" - حداقل 3 کاراکتر
  "phone": string,     // مثال: "09123456789"
  "email": string,     // اختیاری - مثال: "ali@example.com"
  "password": string   // حداقل 8 کاراکتر، شامل حروف بزرگ، کوچک و عدد
}
```

### Validation Rules
- fullName: required, string, minLength: 3, maxLength: 100
- phone: required, string, regex: `^09[0-9]{9}$`
- email: optional, string, valid email format
- password: required, string, minLength: 8, maxLength: 50, must contain uppercase, lowercase and digit

### Response Success (201)
```json
{
  "success": true,
  "message": "ثبت‌نام با موفقیت انجام شد. کد تأیید به شماره موبایل شما ارسال شد",
  "data": {
    "user": {
      "id": "uuid",
      "fullName": "علی محمدی",
      "phone": "09123456789",
      "email": "ali@example.com",
      "status": "pendingVerification",
      "avatar": null,
      "phoneVerified": false,
      "emailVerified": false,
      "createdAt": "2025-11-16T12:00:00.000Z",
      "updatedAt": "2025-11-16T12:00:00.000Z"
    },
    "tokens": {
      "accessToken": "jwt_token_here",
      "refreshToken": "refresh_token_here"
    }
  },
  "timestamp": "2025-11-16T12:00:00.000Z"
}
```

### Response Errors
- `400` - اطلاعات نامعتبر است
- `409` - این شماره موبایل قبلاً ثبت شده است
- `429` - Too Many Requests

### Backend Implementation Checklist:
- [x] DTO: `RegisterDto` در `backend/src/modules/auth/dto/register.dto.ts`
- [x] Service method: `register()` در `AuthService`
- [x] Controller: `@Post('register')` در `AuthController`

### Flutter Implementation Checklist:
- [x] API Service: `@POST('/auth/register')` در `auth_api_service.dart`
- [x] Repository: `register()` در `auth_repository.dart`
- [x] Use Case: `RegisterUseCase` در `auth_usecases.dart`
- [x] BLoC Event: `RegisterEvent` در `auth_event.dart`
- [x] BLoC State: `AuthRegistrationSuccess` در `auth_state.dart`

---

## 3. Login (ورود)

### Endpoint
```
POST /api/v1/auth/login
```

### Request Body
```typescript
{
  "phone": string,     // مثال: "09123456789"
  "password": string
}
```

### Validation Rules
- phone: required, string, regex: `^09[0-9]{9}$`
- password: required, string

### Response Success (200)
```json
{
  "success": true,
  "message": "ورود با موفقیت انجام شد",
  "data": {
    "user": {
      "id": "uuid",
      "fullName": "علی احمدی",
      "phone": "09123456789",
      "email": "ali@example.com",
      "status": "active",
      "avatar": null,
      "phoneVerified": true,
      "emailVerified": false,
      "createdAt": "2025-11-16T12:00:00.000Z",
      "updatedAt": "2025-11-16T12:00:00.000Z"
    },
    "tokens": {
      "accessToken": "jwt_token_here",
      "refreshToken": "refresh_token_here"
    }
  },
  "timestamp": "2025-11-16T12:00:00.000Z"
}
```

### Response Errors
- `400` - اطلاعات نامعتبر است
- `401` - شماره موبایل یا رمز عبور اشتباه است
- `403` - شماره موبایل تأیید نشده است
- `429` - Too Many Requests

### Backend Implementation Checklist:
- [x] DTO: `LoginDto` در `backend/src/modules/auth/dto/login.dto.ts`
- [x] Service method: `login()` در `AuthService`
- [x] Controller: `@Post('login')` در `AuthController`

### Flutter Implementation Checklist:
- [x] API Service: `@POST('/auth/login')` در `auth_api_service.dart`
- [x] Repository: `login()` در `auth_repository.dart`
- [x] Use Case: `LoginUseCase` در `auth_usecases.dart`
- [x] BLoC Event: `LoginEvent` در `auth_event.dart`
- [x] BLoC State: `AuthAuthenticated` در `auth_state.dart`

---

## 4. Verify Phone (تأیید شماره موبایل)

### Endpoint
```
POST /api/v1/auth/verify-phone
```

### Request Body
```typescript
{
  "phone": string,  // مثال: "09123456789"
  "code": string    // مثال: "123456"
}
```

### Validation Rules
- phone: required, string, regex: `^09[0-9]{9}$`
- code: required, string, length: 6, regex: `^[0-9]{6}$`

### Response Success (200)
```json
{
  "success": true,
  "message": "شماره موبایل با موفقیت تأیید شد",
  "data": {
    "user": {
      "id": "uuid",
      "fullName": "علی احمدی",
      "phone": "09123456789",
      "email": "ali@example.com",
      "status": "active",
      "avatar": null,
      "phoneVerified": true,
      "emailVerified": false,
      "createdAt": "2025-11-16T12:00:00.000Z",
      "updatedAt": "2025-11-16T12:00:00.000Z"
    },
    "tokens": {
      "accessToken": "jwt_token_here",
      "refreshToken": "refresh_token_here"
    }
  },
  "timestamp": "2025-11-16T12:00:00.000Z"
}
```

### Response Errors
- `400` - کد تأیید نامعتبر است
- `401` - کد تأیید اشتباه است یا منقضی شده
- `404` - کاربری با این شماره یافت نشد
- `429` - Too Many Requests

---

## 5. Resend Verification Code (ارسال مجدد کد)

### Endpoint
```
POST /api/v1/auth/resend-code
```

### Request Body
```typescript
{
  "phone": string  // مثال: "09123456789"
}
```

### Response Success (200)
```json
{
  "success": true,
  "message": "کد تأیید مجدداً ارسال شد",
  "data": {
    "codeSent": true
  },
  "timestamp": "2025-11-16T12:00:00.000Z"
}
```

### Response Errors
- `400` - شماره موبایل نامعتبر است
- `404` - کاربری با این شماره یافت نشد
- `429` - Too Many Requests (حداکثر 3 بار در 10 دقیقه)

---

## 6. Refresh Token (تمدید توکن)

### Endpoint
```
POST /api/v1/auth/refresh
```

### Request Body
```typescript
{
  "refreshToken": string
}
```

### Response Success (200)
```json
{
  "success": true,
  "message": "توکن با موفقیت تمدید شد",
  "data": {
    "accessToken": "new_jwt_token_here",
    "refreshToken": "new_refresh_token_here"
  },
  "timestamp": "2025-11-16T12:00:00.000Z"
}
```

### Response Errors
- `401` - توکن نامعتبر یا منقضی شده است

---

## 7. Logout (خروج)

### Endpoint
```
POST /api/v1/auth/logout
```

### Headers
```
Authorization: Bearer {access_token}
```

### Response Success (200)
```json
{
  "success": true,
  "message": "خروج با موفقیت انجام شد",
  "data": null,
  "timestamp": "2025-11-16T12:00:00.000Z"
}
```

---

## 8. Get Current User (دریافت اطلاعات کاربر)

### Endpoint
```
GET /api/v1/auth/me
```

### Headers
```
Authorization: Bearer {access_token}
```

### Response Success (200)
```json
{
  "success": true,
  "message": "اطلاعات کاربر دریافت شد",
  "data": {
    "id": "uuid",
    "fullName": "علی احمدی",
    "phone": "09123456789",
    "email": "ali@example.com",
    "status": "active",
    "avatar": null,
    "phoneVerified": true,
    "emailVerified": false,
    "createdAt": "2025-11-16T12:00:00.000Z",
    "updatedAt": "2025-11-16T12:00:00.000Z"
  },
  "timestamp": "2025-11-16T12:00:00.000Z"
}
```

### Response Errors
- `401` - توکن نامعتبر یا منقضی شده است
