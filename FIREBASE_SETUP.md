# 🔥 Quiz Master App — Firebase Setup Guide (FREE)

## Step 1: Create a Free Firebase Project

1. Go to **https://console.firebase.google.com/**
2. Click **"Add Project"** → Enter name: `QuizMasterApp`
3. Disable Google Analytics (optional) → Click **"Create Project"**

---

## Step 2: Add Android App to Firebase

1. In Firebase Console, click the **Android icon** (Add App)
2. Enter your Android package name:
   - Default Flutter: `com.example.quiz_app`
   - ⚠️ Must match `applicationId` in `android/app/build.gradle`
3. Enter app nickname: `Quiz Master`
4. Click **"Register App"**

---

## Step 3: Download google-services.json

1. After registering, Firebase will offer a **`google-services.json`** file
2. Download it
3. Place it in: **`android/app/google-services.json`**

   ```
   quiz_app/
   └── android/
       └── app/
           └── google-services.json  ← HERE
   ```

---

## Step 4: Update Android Gradle Files

### `android/build.gradle` — Add Google Services:
```gradle
buildscript {
    dependencies {
        // ... existing dependencies
        classpath 'com.google.gms:google-services:4.4.2'
    }
}
```

### `android/app/build.gradle` — Apply plugin at bottom:
```gradle
apply plugin: 'com.google.gms.google-services'
```

Also ensure `minSdkVersion` is at least **21**:
```gradle
android {
    defaultConfig {
        minSdkVersion 21
        targetSdkVersion 34
    }
}
```

---

## Step 5: Enable Firebase Authentication

1. In Firebase Console → **Authentication** → **Get Started**
2. Click **"Email/Password"** → Toggle **Enable** → Save

---

## Step 6: Set Up Firestore Database (Free Tier)

1. Firebase Console → **Firestore Database** → **Create Database**
2. Choose **"Start in test mode"** (allows read/write for 30 days)
3. Select a region (e.g., `asia-south1` for India) → **Enable**

### Firestore Security Rules (after testing, apply these):
```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can only read/write their own profile
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    // Anyone authenticated can read quizzes
    match /quizzes/{quizId} {
      allow read: if request.auth != null;
      match /questions/{questionId} {
        allow read: if request.auth != null;
      }
    }
    // Authenticated users can write their results
    match /quiz_results/{resultId} {
      allow read, write: if request.auth != null;
    }
  }
}
```

---

## Step 7: Set Up Firebase Storage (for Profile Photos)

1. Firebase Console → **Storage** → **Get Started**
2. Start in test mode → Choose region → **Done**

### Storage Security Rules:
```
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /profile_photos/{userId}.jpg {
      allow read: if request.auth != null;
      allow write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

---

## Step 8: Seed Quiz Data to Firestore

In your app, add a temporary admin button or run this once from Dart DevTools:

```dart
// Add this button anywhere temporarily (e.g., HomeScreen)
ElevatedButton(
  onPressed: () async {
    await FirestoreService.seedSampleData();
    print('Quiz data seeded!');
  },
  child: Text('Seed Data (Run Once)'),
)
```

This populates 5 quizzes × 5 questions each.  
**Remove this button after running it once!**

---

## Step 9: Run the App

```bash
flutter pub get
flutter run
```

---

## Free Firebase Limits (Spark Plan — Free Forever)

| Feature | Free Limit |
|---|---|
| Authentication | 10,000 users/month |
| Firestore Reads | 50,000/day |
| Firestore Writes | 20,000/day |
| Firestore Storage | 1 GB |
| File Storage | 5 GB |
| Storage Downloads | 1 GB/day |

**This is more than enough for a student quiz app!** 🚀

---

## Project Structure

```
quiz_app/
├── lib/
│   ├── main.dart                    # App entry point
│   ├── firebase/
│   │   ├── firebase_init.dart       # Firebase initialization
│   │   ├── auth_service.dart        # Login / Signup / Logout
│   │   └── firestore_service.dart   # Quiz & result data
│   ├── models/
│   │   ├── user_model.dart
│   │   ├── quiz_model.dart
│   │   └── question_model.dart
│   ├── screens/
│   │   ├── splash_screen.dart       # Auto-login check
│   │   ├── login_screen.dart        # Login with popup
│   │   ├── signup_screen.dart       # Signup with popup
│   │   ├── home_screen.dart         # Dashboard
│   │   ├── profile_screen.dart      # Edit profile + photo
│   │   ├── quiz_list_screen.dart    # 5 quiz cards
│   │   ├── quiz_screen.dart         # Pre-form + questions
│   │   └── result_screen.dart       # Score + PASS/FAIL
│   ├── widgets/
│   │   ├── custom_button.dart
│   │   ├── quiz_tile.dart
│   │   └── loading_widget.dart
│   ├── utils/
│   │   ├── theme.dart               # Dark mode theme
│   │   └── constants.dart
│   └── routes/
│       └── app_routes.dart          # Navigation
├── android/
│   └── app/
│       ├── google-services.json     # ← YOU ADD THIS
│       └── src/main/AndroidManifest.xml
└── pubspec.yaml
```
