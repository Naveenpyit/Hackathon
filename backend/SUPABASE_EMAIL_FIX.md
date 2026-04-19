# Supabase Email Confirmation Fix

## Problem
The signin endpoint returns "Email not confirmed" error because Supabase has email confirmation enabled by default.

## Solutions

### 1. Disable Email Confirmation in Supabase Dashboard (Recommended for Development)
1. Go to your Supabase Dashboard
2. Navigate to Authentication > Providers > Email
3. Disable "Confirm email" option
4. Save changes

### 2. Auto-confirm emails programmatically
Add to your `.env` file:
```
SUPABASE_SERVICE_KEY=your-service-role-key-here
```

The service role key can be found in:
- Supabase Dashboard > Settings > API > Service role key

### 3. Manually confirm user email via SQL
Run this in Supabase SQL editor:
```sql
UPDATE auth.users 
SET email_confirmed_at = now() 
WHERE email = '76612@thescmsilk.com';
```

### 4. Use Magic Link instead of Password
This bypasses the email confirmation requirement.

## Current Workaround
The API has been updated to handle this error gracefully, but for proper functionality, you should implement one of the solutions above.