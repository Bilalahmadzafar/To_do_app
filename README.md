# ✅ TaskZen – A Beautiful To-Do List App in Flutter

TaskZen is a clean, fast, and modern Flutter to-do list app built with local storage using Hive, scalable architecture (MVVM), and state management via Provider. It includes a logo splash screen and persistent task data.

---

## 🧱 Architecture

- **Model**: Represents task structure using Hive
- **View**: UI screens (Splash, Home)
- **ViewModel**: Logic and task management
- **Repository**: Abstract interface with Hive-based implementation

---

## 📁 Folder Structure

lib/
├── main.dart
├── models/ # TodoModel with Hive adapter
├── repositories/ # Abstract + Hive Repository
├── view_models/ # ViewModel using ChangeNotifier
├── views/ # Home and Splash Screens
└── assets/ # Logo (temp_logo.png)



---

## 🚀 Features

- Add, remove, and toggle task status
- Persistent local storage with Hive
- Custom splash screen with logo
- Clean MVVM structure
- Provider for state management
- Material 3 design

---

## 📦 Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter
  provider: ^6.1.0
  hive: ^2.2.3
  hive_flutter: ^1.1.0

dev_dependencies:
  build_runner: ^2.4.7
  hive_generator: ^2.0.1

 -- Setup --

git clone <repo_url>
cd to_do_list
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs


