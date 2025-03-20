# Notes App

A full-stack notes application built with Flutter and NestJS.

## Features

- User authentication (login, register, logout)
- Create, read, update, and delete notes
- Real-time updates
- Secure data access with JWT
- Beautiful animations and transitions
- Error handling and loading states

## Backend (NestJS)

### Prerequisites

- Node.js 20 or higher
- PostgreSQL
- Docker (optional)

### Setup

1. Install dependencies:
```bash
cd backend
npm install
```

2. Configure environment variables:
   - Copy `.env.example` to `.env`
   - Update the values accordingly

3. Start the server:
```bash
# Development
npm run start:dev

# Production with Docker
docker-compose up
```

### API Documentation

- Swagger documentation available at `/api`
- Protected endpoints require JWT authentication
- All routes follow RESTful conventions

## Frontend (Flutter)

### Prerequisites

- Flutter SDK
- Dart SDK

### Setup

1. Install dependencies:
```bash
flutter pub get
```

2. Configure environment variables:
   - Copy `.env.example` to `.env`
   - Update Supabase configuration

3. Run the app:
```bash
flutter run
```

### Architecture

- BLoC pattern for state management
- Clean architecture principles
- Reusable widgets and components
- Error handling and loading states

## Security

- JWT-based authentication
- Row Level Security in Supabase
- Secure password hashing
- Protected API endpoints