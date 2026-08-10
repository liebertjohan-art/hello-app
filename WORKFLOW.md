# 🛠️ Development & Build Process Workflow

This document describes the end-to-end process for developing, building, and deploying the Flutter app.

---

## 📌 Workflow Overview

```
+---------------------+        +--------------------+        +---------------------+
| Local Development   |  --->  | GitHub Repository  |  --->  | GitHub Actions CI   |
| (Code in lib/)      |        | (git push)         |        | (Cloud APK Build)   |
+---------------------+        +--------------------+        +---------------------+
                                                                        |
+---------------------+        +--------------------+                   v
| Local Device        |  <---  | Release APK        |  <---  +---------------------+
| (adb install)       |        | (gh download)      |        | GitHub Release Asset|
+---------------------+        +--------------------+        +---------------------+
```

---

## 📑 Detailed Steps

### Step 1: Local Development
- Perform all coding, testing, and UI updates locally inside the project workspace (`lib/main.dart`, components, assets).
- Maintain clean code and commit history.

### Step 2: Push Code to GitHub
Push your commits to the `main` branch of the GitHub repository:
```bash
git add .
git commit -m "Your commit message"
git push origin main
```

### Step 3: Automated Cloud Build (GitHub Actions)
- The push automatically triggers the `.github/workflows/build-release.yml` pipeline.
- GitHub Actions provisions an `ubuntu-latest` runner, sets up Java 17 & Flutter, installs dependencies (`flutter pub get`), and builds the release APK (`flutter build apk --release`).

### Step 4: GitHub Release Creation
- Upon a successful build, the workflow generates a new Release tag (e.g., `v1.0.X`).
- The generated `app-release.apk` artifact is automatically attached to the GitHub Release assets.

### Step 5: Download Release APK Locally
Using the GitHub CLI (`gh`), fetch the latest release asset:
```bash
mkdir -p downloads
gh release download --dir downloads/ --clobber
```

### Step 6: Deploy & Install via ADB
Install the downloaded release APK onto your connected Android emulator or physical device:
```bash
adb install -r downloads/app-release.apk
```

To launch the app immediately after installation:
```bash
adb shell monkey -p com.example.hello_app -c android.intent.category.LAUNCHER 1
```

---

## ⚙️ CI/CD Workflow File Location
The GitHub Actions workflow configuration is located at:
`[build-release.yml](file://.github/workflows/build-release.yml)`
