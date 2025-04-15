# QuickList

A modern task and shopping list management app to help you organize your life
effortlessly.

## 📱 Overview

QuickList is a cross-platform mobile application built with React Native and
Expo that provides intuitive tools to manage your tasks and shopping lists in
one place. The app features a clean user interface, real-time updates via
Supabase, and a seamless user experience.

## ✨ Features

- **Task Management**: Create, complete, and track tasks
- **Shopping Lists**: Maintain and check off shopping items with quantities
- **Real-time Updates**: Changes sync instantly across devices
- **User Authentication**: Secure sign-up and sign-in functionality
- **Dark/Light Theme**: Support for system preference and manual theme switching
- **Responsive Design**: Works on various screen sizes

## 🛠️ Tech Stack

- **Frontend**:

  - [React Native](https://reactnative.dev/) - Cross-platform mobile app
    framework
  - [Expo](https://expo.dev/) - Development platform for React Native
  - [Expo Router](https://docs.expo.dev/router/introduction/) - File-based
    routing for Expo apps
  - [React Navigation](https://reactnavigation.org/) - Navigation library for
    React Native

- **Backend**:

  - [Supabase](https://supabase.com/) - Open source Firebase alternative
  - PostgreSQL - Database for data storage

- **Development Tools**:
  - TypeScript - Type checking
  - Zod - Schema validation

## 📋 Prerequisites

- Node.js (v14 or later)
- npm or yarn
- Expo CLI
- iOS Simulator (macOS) or Android Emulator

## 🚀 Getting Started

1. **Clone the repository**

```bash
git clone https://github.com/iamfrerot/Quicklist
cd Quicklist
```

2. **Install dependencies**

```bash
npm install
# or
yarn install
```

3. **Set up environment variables**

   Create a `.env` file in the root directory with your Supabase credentials:

```
EXPO_PUBLIC_SUPABASE_URL=your_supabase_url
EXPO_PUBLIC_SUPABASE_ANON_KEY=your_supabase_anon_key
```

4. **Start the development server**

```bash
npm start
# or
yarn start
```

5. **Run on a simulator or device**

Press `i` to open in iOS simulator, `a` for Android emulator, or scan the QR
code with the Expo Go app on your device.

## 📁 Project Structure

```
app/                  # App screens using Expo Router
  (tabs)/             # Tab-based navigation
  auth/               # Authentication screens
components/           # Reusable UI components
  forms/              # Form-related components
  layout/             # Layout components
  list/               # List-related components
  ui/                 # Generic UI components
lib/                  # Utility functions and services
  supabase.ts         # Supabase client configuration
  ThemeContext.tsx    # Theme management
supabase/             # Supabase configuration
  functions/          # Edge functions
  migrations/         # Database migrations
types/                # TypeScript type definitions
```

## 📝 Database Schema

The app uses the following main tables:

- `tasks` - For managing user tasks
- `shopping_items` - For tracking shopping list items
- Users are managed through Supabase Auth

## 🧩 Key Features Implementation

- **Real-time updates**: Using Supabase Realtime for instant data
  synchronization
- **Theme support**: Context API for maintaining app-wide theming
- **Navigation**: File-based routing with Expo Router
- **Form handling**: Custom components for consistent form styling and behavior

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for
details.
