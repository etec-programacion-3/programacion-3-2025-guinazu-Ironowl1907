# Workout Tracker

A **Flutter-based mobile app** built **for serious lifters** who want total control over their training data — **no internet, no fluff, just pure lifting and tracking**.

Everything runs **completely offline** using **SQLite**, letting you build your own workouts, exercises, and routines exactly how *you* train.

---

## ⚙️ Features at a Glance

* **Custom Workouts** – Create, edit, and track personalized training sessions
* **Custom Muscle Groups** – Organize your lifts however you like
* **Custom Exercises** – Build your own exercise library
* **Routine Management** – Save and reuse your training templates
* **Progress Analytics** – Visualize gains with detailed stats and charts
* **100% Offline** – Data stored locally with SQLite, no sign-ins or servers
* **Material Design** – Clean, intuitive UI that feels native and smooth

> 🧩 Built for lifters who *know what they’re doing* — full control, zero hand-holding.

---

## 🧰 Tech Stack

* **Framework:** Flutter 3.38
* **Language:** Dart
* **Database:** SQLite + sqflite ORM
* **Design:** Google’s Material Design

---

## 🚀 Getting Started

### 🧑‍💻 Prerequisites

Before running the app, make sure you have:

* [Flutter SDK 3.38](https://docs.flutter.dev/get-started/install)
* [Android SDK](https://developer.android.com/studio)
* Dart (included with Flutter)

---

### 🧩 Installation Steps

1. **Clone the repo**

   ```bash
   git clone https://github.com/etec-programacion-3/programacion-3-2025-guinazu-Ironowl1907.git
   cd programacion-3-2025-guinazu-Ironowl1907
   ```

2. **Install dependencies**

   ```bash
   flutter pub get
   ```

3. **Check your setup**

   ```bash
   flutter doctor
   ```

---

## Running the App

### 🖥️ On Linux

```bash
flutter run -d linux
```

### 🤖 On Android

Connect your Android device or emulator:

```bash
flutter run -d <your connected device>
```

---

## 📦 Building for Production

**Generate a release APK:**

```bash
flutter build apk --release
```

Your APK will be at:
`build/app/outputs/flutter-apk/app-release.apk`

---

## 📊 Database Overview

Workout Tracker uses **SQLite** (via `sqflite`) for local data storage.
The app starts with an **empty database** — you build your own structure over time with:

* Custom muscle groups
* Your exercise library
* Personalized workout routines

> 💾 Everything stays on your device — your data, your control.

---

### 🏋️‍♂️ Built for lifters, by lifters.

**Own your training. Track your progress. Stay offline.**

