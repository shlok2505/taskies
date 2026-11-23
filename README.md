# Taskies

A task management app for gig workers, built with Flutter and Firebase.
Create, track and prioritise your work in a clean dark UI.

## Features
- Email/password authentication (Firebase Auth) with clear error messages
- Create, edit, delete and view tasks (real-time sync with Cloud Firestore)
- Task fields: title, description, due date and time, priority (Low / Medium / High)
- Mark tasks complete or incomplete
- Filter by status (All / Incomplete / Completed) and by priority
- Tasks sorted by due date, earliest first; overdue tasks are highlighted
- "Due today" summary on the home screen
- Swipe left to delete
- Per-user data isolation enforced with Firestore security rules
- Works on Android and iOS (tested on Android)

## Screenshots
<p>
    <img src="ss\login_page.jpg"> width="200" />
    <img src="ss\home_page.jpg"> width="200" />
    <img src="ss\create_task.jpg"> width="200" />
    <img src="ss\sort_task.jpg"> width="200" />
## Tech stack
- Flutter (Material 3), Dart
- Firebase Authentication, Cloud Firestore

## Project structure
```
lib/
  main.dart                  app entry + auth gate
  firebase_options.dart      generated Firebase config
  models/task.dart           Task model + Priority enum
  services/auth_service.dart auth logic
  services/task_service.dart Firestore CRUD
  screens/                   auth, home, task form
  widgets/                   task card, background
  theme/app_theme.dart       colours and theme
  utils/format.dart          date helpers
```

## Data model
`users/{uid}/tasks/{taskId}` with fields: title, description, priority,
dueDate (Timestamp), isCompleted.

## Security rules
```
match /users/{userId}/tasks/{taskId} {
  allow read, write: if request.auth != null && request.auth.uid == userId;
}
```

## Setup
1. Install Flutter and clone this repo
2. `flutter pub get`
3. Create a Firebase project, enable Email/Password auth and Firestore
4. Run `flutterfire configure` to generate `lib/firebase_options.dart`
5. `flutter run`

## Design decisions
- StreamBuilder + service classes keep the UI reactive with minimal boilerplate
- Filtering is done client-side on the per-user list to avoid composite indexes
- Auth state drives navigation, so sessions persist across restarts

## Possible improvements
- Due-date reminder notifications
- Stats screen (completion by priority)
- Unit and widget tests
- Pagination for very large task lists

## Author
Shlok - [https://github.com/shlok2505] - [LinkedIn link:https://www.linkedin.com/in/shloksing-h2505/]