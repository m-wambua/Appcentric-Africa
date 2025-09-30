Features
Backend – Laravel REST API

Database Structure

Migrations for subjects, papers, questions, and answers

Proper relationships between entities

Models

Eloquent models with relationships

Built-in search capabilities

API Controllers

Subject listing

Paper filtering by subject/year with search

Paper details with structured questions and answers

JWT authentication using Laravel Sanctum

Other Backend Features

Rate limiting: 50 requests/min per authenticated user

Pagination support for large datasets

Seeder with sample data: 5 subjects, multiple years, and questions

Frontend – Flutter Mobile App
Screens

Login Screen

Email/password validation

Secure token storage

Loading states

Paper List Screen

Searchable paper list

Filter by subject and year

Infinite scroll pagination

Pull-to-refresh

Loading indicators

Question Detail Screen

Interactive quiz format

Multiple choice answers

Score tracking

SQLite caching for offline access

Beautiful card-based UI

Key Features

SQLite Caching – last viewed papers available offline

Loading Spinners – smooth async experience

Rate Limiting – 50 requests/min, enforced at backend

Search & Pagination – efficient dataset handling

Secure Authentication – token-based with secure storage

🛠️ Tech Stack

Backend: Laravel, Sanctum (JWT), MySQL/PostgreSQL

Frontend: Flutter, SQLite, Provider/Bloc (state management)

Tools: Postman (API testing), Git, Docker (optional)

Backend (Laravel API)

Clone the repo:


cd backend/appcenctric-app



Install dependencies:
composer install

Configure .env:

Database connection

Sanctum/JWT settings

Run migrations & seeders:
php artisan migrate --seed



Start server:
php artisan serve


Frontend (Flutter App)


cd appcentricafrica

Get dependencies:
flutter pub get

Update API base URL in lib/config.dart.

Run app:
flutter run

Default Test Credentials

Email: test@example.com

Password: password123


