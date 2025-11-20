# Common Types - تایپ‌های مشترک

## Base URL
```
http://localhost:3000/api/v1
```

**توجه:** تمام endpointها بدون `/v1` اضافی هستند.  
مثال: `POST /api/v1/auth/check-phone` (نه `/api/v1/v1/auth/check-phone`)

## Response Wrapper
تمام پاسخ‌های موفق در این ساختار هستند:

```typescript
{
  "success": boolean,
  "message": string,
  "data": T | null,
  "timestamp": string (ISO 8601)
}
```

### مثال پاسخ موفق:
```json
{
  "success": true,
  "message": "عملیات با موفقیت انجام شد",
  "data": { ... },
  "timestamp": "2025-11-16T12:00:00.000Z"
}
```

## Error Response
تمام خطاها در این ساختار هستند:

```typescript
{
  "message": string | string[],
  "error": string,
  "statusCode": number
}
```

### مثال پاسخ خطا:
```json
{
  "message": "شماره موبایل نامعتبر است",
  "error": "Bad Request",
  "statusCode": 400
}
```

## Common Status Codes
- `200` - OK
- `201` - Created
- `400` - Bad Request
- `401` - Unauthorized
- `403` - Forbidden
- `404` - Not Found
- `409` - Conflict
- `422` - Unprocessable Entity
- `429` - Too Many Requests
- `500` - Internal Server Error

## Headers
### Request Headers:
```
Content-Type: application/json
Authorization: Bearer {access_token}  // برای endpointهای محافظت شده
```

### Response Headers:
```
Content-Type: application/json
```

## Phone Format
```
شماره موبایل باید با فرمت ایرانی باشد: 09xxxxxxxxx
طول: 11 کاراکتر
شروع با: 09
```

## Date/Time Format
تمام تاریخ‌ها به فرمت ISO 8601:
```
2025-11-16T12:00:00.000Z
```

## Pagination (برای لیست‌ها)
```typescript
{
  "items": T[],
  "total": number,
  "page": number,
  "limit": number,
  "totalPages": number
}
```

## User Entity (مدل کاربر)
```typescript
{
  "id": string (uuid),
  "fullName": string,
  "phone": string,
  "email": string | null,
  "status": "active" | "inactive" | "suspended" | "pendingVerification",
  "avatar": string | null,
  "phoneVerified": boolean,
  "emailVerified": boolean,
  "createdAt": string (ISO 8601),
  "updatedAt": string (ISO 8601)
}
```

**توجه:** 
- فیلد `role` دیگر در User وجود ندارد
- نقش‌ها از طریق `UserBusiness` مدیریت می‌شوند
- فرمت status به camelCase تغییر کرد (`pendingVerification` به جای `pending_verification`)
