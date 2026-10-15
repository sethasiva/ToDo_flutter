# Todo App

## Features
- Five-second logo splash screen
- Add, edit and delete tasks with title, description and two statuses
- Total and status counts; tap a count to filter tasks
- Green pending, blue completed
- Task and profile persistence using SharedPreferences
- Local profile name and email; no login required
- Bell opens a task summary (scheduled reminders are not included)
- Delete confirmation and save/load error handling

## Run
flutter pub get
flutter run

## Checks
flutter analyze
flutter test
flutter build apk --debug

All Dart source files stay below 300 lines. The logo is a bundled PNG asset.

