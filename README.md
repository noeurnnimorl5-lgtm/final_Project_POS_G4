# 🛒 POS System

A full-stack Point of Sale system built with **Flutter** (Web + Mobile) and **Laravel REST API**.

- 🖥️ **Admin Web** — Flutter Web dashboard for managing products, categories, and orders
- 📱 **Cashier Mobile** — Flutter Android app with **offline mode** and auto-sync
- ⚙️ **Backend** — Laravel 13 REST API with Sanctum authentication and role-based access

---

## 📁 Project Structure

```
pos-system/
├── backend/          # Laravel REST API
├── admin_web/        # Flutter Web (Admin Dashboard)
└── cashier_mobile/   # Flutter Mobile (Cashier App)
```

---

## ✅ Prerequisites

Make sure the following are installed before setup:

| Tool | Version | Download |
|------|---------|----------|
| PHP | 8.1+ | https://www.php.net |
| Composer | Latest | https://getcomposer.org |
| MySQL | 8.0+ | https://www.mysql.com (or XAMPP/Laragon) |
| Flutter | 3.x | https://flutter.dev |
| Android Studio | Latest | https://developer.android.com/studio |
| Chrome Browser | Latest | For Flutter Web |

---

## 🚀 Setup Guide

### Step 1 — Create Project Structure

```cmd
mkdir D:\pos-system
cd D:\pos-system
```

---

### Step 2 — Backend Setup (Laravel)

#### 2.1 Install Laravel

```cmd
cd D:\pos-system
composer create-project laravel/laravel backend
cd backend
```

#### 2.2 Install Required Packages

```cmd
composer require laravel/sanctum spatie/laravel-permission
```

#### 2.3 Publish & Migrate

```cmd
php artisan vendor:publish --provider="Laravel\Sanctum\SanctumServiceProvider"
php artisan vendor:publish --provider="Spatie\Permission\PermissionServiceProvider"
php artisan migrate
```

#### 2.4 Configure Environment

Open `.env` and update the database settings:

```env
DB_CONNECTION=mysql
DB_HOST=127.0.0.1
DB_PORT=3306
DB_DATABASE=pos_db
DB_USERNAME=root
DB_PASSWORD=your_password
```

> 💡 Make sure MySQL is running and `pos_db` database is created first.

#### 2.5 Generate Models & Controllers

```cmd
php artisan make:model Category -m
php artisan make:model Product -m
php artisan make:model Order -m
php artisan make:model OrderItem -m

php artisan make:controller Api/AuthController
php artisan make:controller Api/CategoryController --api
php artisan make:controller Api/ProductController --api
php artisan make:controller Api/OrderController --api
php artisan make:controller Api/SyncController

php artisan make:request LoginRequest
php artisan make:request StoreOrderRequest
```

#### 2.6 Run Fresh Migration

```cmd
php artisan migrate:fresh --seed
```

#### 2.7 Start Laravel Server

```cmd
php artisan serve
```

> API running at: `http://127.0.0.1:8000`

---

### Step 3 — Admin Web Setup (Flutter Web)

#### 3.1 Create Flutter Project

```cmd
cd D:\pos-system
flutter create admin_web
cd admin_web
```

#### 3.2 Enable Web & Install Dependencies

```cmd
flutter config --enable-web
flutter pub add dio provider go_router shared_preferences fl_chart
flutter pub get
```

#### 3.3 Run Admin Web

```cmd
flutter run -d chrome
```

---

### Step 4 — Cashier Mobile Setup (Flutter Android)

#### 4.1 Create Flutter Project

```cmd
cd D:\pos-system
flutter create cashier_mobile
cd cashier_mobile
```

#### 4.2 Install Dependencies

```cmd
flutter pub add dio provider sqflite connectivity_plus shared_preferences path uuid
flutter pub get
```

#### 4.3 Run on Android Device/Emulator

```cmd
flutter run
```

> 💡 Make sure an Android emulator is running or a physical device is connected.

---

## 🔌 API Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/api/auth/login` | Login (Admin/Cashier) |
| POST | `/api/auth/logout` | Logout |
| GET | `/api/products` | List all products |
| POST | `/api/products` | Create product |
| PUT | `/api/products/{id}` | Update product |
| DELETE | `/api/products/{id}` | Delete product |
| GET | `/api/categories` | List all categories |
| GET | `/api/orders` | List all orders |
| POST | `/api/orders` | Create order |
| POST | `/api/sync` | Sync offline orders |

---

## 📶 Offline Mode (Cashier Mobile)

The cashier app supports **offline ordering**:

1. Orders placed without internet are saved locally to **SQLite**
2. When connection is restored, orders are **automatically synced** to the server via `/api/sync`
3. Sync status is shown in real-time to the cashier

---

## 🔐 Authentication

- Uses **Laravel Sanctum** for API token authentication
- Two roles managed by **Spatie Permission**: `admin` and `cashier`
- Tokens are stored securely using `shared_preferences` on the Flutter side

---

## 🛠️ Tech Stack

| Layer | Technology |
|-------|-----------|
| Backend API | Laravel 13 |
| Authentication | Laravel Sanctum |
| Authorization | Spatie Laravel Permission |
| Admin Frontend | Flutter Web |
| Mobile App | Flutter Android |
| Local Database | SQLite (sqflite) |
| HTTP Client | Dio |
| State Management | Provider |
| Offline Detection | connectivity_plus |

---

## ⚠️ Common Issues

### Permission Denied (Windows + Composer)
Run Command Prompt as **Administrator** before running composer commands.

### Flutter Visual Studio Warning
The Visual Studio C++ warning can be safely ignored — it is only required for Windows desktop apps, not web or Android.

### CORS Error (Flutter → Laravel)
In `config/cors.php`, set:
```php
'allowed_origins' => ['*'],
```

---

## 📄 License

MIT License — Free to use and modify.