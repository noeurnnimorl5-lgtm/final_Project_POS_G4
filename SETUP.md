# POS System - Setup Guide

## Requirements
- PHP 8.2+
- Composer
- XAMPP (for local) or any PHP server

## Setup Steps

### 1. Clone the repository
```bash
git clone https://github.com/soklie123/POS_SYSTEM.git
cd POS_SYSTEM/backend
```

### 2. Install dependencies
```bash
composer install
```

### 3. Setup environment
```bash
cp .env.example .env
php artisan key:generate
```

### 4. Run migrations
```bash
php artisan migrate
```

### 5. Create test user
```bash
php artisan tinker
```
```php
\App\Models\User::create([
    'name' => 'Cashier',
    'email' => 'cashier@test.com',
    'password' => bcrypt('password123'),
]);
```

### 6. Start server
```bash
php artisan serve
```

### 7. Test API
```
POST http://localhost:8000/api/login
Body: { "email": "cashier@test.com", "password": "password123" }
```

## Database
Using Railway MySQL (already configured in .env.example)
No need to create local database ✅

## Flutter Setup
```bash
cd ../cashier_mobile
flutter pub get
flutter run
