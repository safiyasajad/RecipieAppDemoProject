# Recipe App Demo Project

A Flutter recipe and meal-planning app with Firebase Authentication, Cloud Firestore role-based access, Spoonacular-powered meal plans, admin-managed recipes, and user favorite meals.

The app supports two roles:

- **User**: search meal plans, view recipes, save favorite meals, and view recipes added by admins.
- **Admin**: use the same meal planner, add/edit/delete custom recipes, view all users, and change user roles.

## Features

### Authentication

- Email/password login with Firebase Authentication.
- Signup creates a matching Firestore user document.
- Forgot password flow using Firebase password reset emails.
- Wrapper screen automatically redirects:
  - unauthenticated users to Login
  - users with `role: "user"` to the user meal planner
  - users with `role: "admin"` to the admin meal planner

### Meal Planner

- Search for generated meal plans by:
  - target calories
  - diet type
- Shows total nutrients for the generated plan:
  - calories
  - fat
  - protein
  - carbs
- Meal cards open full recipe pages in a WebView.

### User Favorites

- Users can favorite meals from the meal results screen.
- Favorites are saved under each user's Firestore document.
- Users can view and remove favorite meals from the floating action button menu.

### Admin Recipes

- Admins can add custom recipes with:
  - recipe name
  - image URL
  - calories
  - protein
  - carbs
  - fat
  - diet
  - recipe details
- Admin recipes are viewable by all logged-in users.
- Recipe cards expand when tapped to show details.
- Admins can edit or delete recipe cards.

### Admin User Management

- Admins can view all registered users.
- Admins can change each user's role using a dropdown:
  - `user`
  - `admin`

### Persistent Floating Button

Most authenticated pages include a bottom-right floating action button.

Normal users see:

- Search Meals
- Admin Recipes
- Favorite Meals
- Logout

Admins see:

- Search Meals
- Add Recipe
- Admin Recipes
- Favorite Meals
- See Users
- Logout

The floating button is intentionally not shown on as it is role based access:

- Login
- Signup
- Forgot Password

## Tech Stack

- Flutter
- Dart
- Firebase Authentication
- Cloud Firestore
- Spoonacular API via `http`
- `webview_flutter` for opening recipe pages
- `get` for navigation in auth screens

## Project Structure

```text
lib/
  main.dart
  wrapper.dart
  login.dart
  signup.dart
  forgot.dart
  admin.dart
  homepage.dart
  user.dart

  models/
    meal_model.dart
    meal_plan_model.dart
    recipie_model.dart

  screens/
    search_screen.dart
    meals_screen.dart
    recipie_screen.dart
    admin_recipes_screen.dart
    favorite_meals_screen.dart

  services/
    api_service.dart

  widgets/
    auth_floating_button.dart
```

## Important Files

### `main.dart`

Initializes Firebase and starts the app. Also defines named routes:

```dart
'/admin-recipes'
'/favorite-meals'
```

### `wrapper.dart`

Controls the startup flow:

1. Checks Firebase login state.
2. Reads the logged-in user's Firestore role.
3. Sends admins to `AdminPage`.
4. Sends normal users to `SearchScreen`.
5. Sends logged-out users to `Login`.

### `search_screen.dart`

Normal user's meal planner page. Lets users choose calories and diet, then generates a meal plan.

### `admin.dart`

Admin version of the meal planner. Admins get the same meal-planning experience, plus admin controls through the floating action button.

### `meals_screen.dart`

Displays generated meal plans and allows users to favorite meals.

### `admin_recipes_screen.dart`

Displays admin-added recipes. Cards can expand to show nutrition and recipe details. Admins can edit and delete recipes.

### `favorite_meals_screen.dart`

Displays the current user's saved favorite meals.

### `auth_floating_button.dart`

Shared floating action button used across authenticated pages. It detects the user's role and shows the correct options.

## Firestore Data Model

### `users`

Each user has a document:

```text
users/{uid}
```

Example:

```json
{
  "uid": "firebase-auth-uid",
  "email": "safiya@gmail.com",
  "role": "user",
  "createdAt": "server timestamp"
}
```

Admin users must have:

```json
{
  "role": "admin"
}
```

### `admin_recipes`

Admin-created recipes are stored here:

```text
admin_recipes/{recipeId}
```

Example:

```json
{
  "title": "Chicken Rice Bowl",
  "imageUrl": "https://example.com/image.jpg",
  "calories": 550,
  "protein": 35,
  "carbs": 60,
  "fat": 15,
  "diet": "None",
  "description": "Cook chicken, rice, and vegetables together.",
  "createdAt": "server timestamp"
}
```

### `favorite_meals`

Each user's favorite meals are stored as a subcollection:

```text
users/{uid}/favorite_meals/{mealId}
```

## Setup Instructions

### 1. Clone the repository

```bash
git clone https://github.com/your-username/RecipieAppDemoProject.git
cd RecipieAppDemoProject
```

### 2. Install dependencies

```bash
flutter pub get
```

### 3. Configure Firebase

This project uses Firebase Authentication and Cloud Firestore.

You need to:

1. Create a Firebase project.
2. Enable Email/Password authentication.
3. Enable Cloud Firestore.
4. Add your platform apps in Firebase.
5. Place the Firebase config files in the correct folders.

For Android, the project already expects:

```text
android/app/google-services.json
```

If you create a new Firebase project, replace this file with your own.

### 4. Add Firestore rules

Paste the rules from the **Firebase Rules Example** section into:

```text
Firebase Console -> Firestore Database -> Rules
```

Then publish the rules.

### 5. Configure the Spoonacular API

Meal plan generation and recipe details are handled by `lib/services/api_service.dart`.

Open that file and make sure the API key/base URL values match your Spoonacular setup.

### 6. Run the app

```bash
flutter run
```

## Typical User Flow

1. User signs up or logs in.
2. User selects calories and diet.
3. User taps Search.
4. App displays a generated meal plan.
5. User can tap meals to view full recipe pages.
6. User can favorite meals using the heart icon.
7. User can open Favorite Meals from the floating button.
8. User can view Admin Recipes from the floating button.

## Typical Admin Flow

1. Admin logs in.
2. Admin sees the meal planner.
3. Admin opens the floating action button.
4. Admin can:
   - add recipes
   - view admin recipes
   - edit/delete admin recipes
   - see all users
   - change user roles
   - logout

## Notes

- The project currently uses network images for backgrounds and recipe cards.
- Some files may still show Flutter analyzer info warnings for deprecated `withOpacity`; these do not stop the app from running.
- Firestore permissions are required for role checks, admin recipes, and favorite meals.
- Recipe and meal data from Spoonacular requires internet access.