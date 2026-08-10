# 🛠️ Development & Build Process Workflow

> [!WARNING]
> **⚠️ IMPORTANT: Do NOT run `flutter` or `dart` commands locally. This is a proot/Termux environment — local Flutter builds will crash. All builds happen in the cloud via GitHub Actions.**

This document describes the end-to-end process for developing, building, and deploying the Tic Tac Toe Flutter app.

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
- Do NOT run Flutter or Dart tools locally.

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

### Step 4: Monitor Cloud Build
Track the progress of your GitHub Actions workflows:
- List recent workflow runs:
  ```bash
  gh run list
  ```
- Watch a run until completion:
  ```bash
  gh run watch <id> --exit-status
  ```
- Inspect failure logs if a run fails:
  ```bash
  gh run view <id> --log-failed
  ```

### Step 5: GitHub Release Creation
- Upon a successful build, the workflow generates a new Release tag (e.g., `v1.0.X`).
- The generated APK artifact is automatically attached to the GitHub Release assets.

### Step 6: Download Release APK Locally
Using the GitHub CLI (`gh`), fetch the latest release asset:
```bash
mkdir -p downloads
gh release download --dir downloads/ --clobber --pattern '*.apk'
```

### Step 7: Deploy & Install via ADB
Install the downloaded release APK onto your connected Android emulator or physical device:
```bash
adb install -r downloads/app-release.apk
```

To launch the app immediately after installation:
```bash
adb shell monkey -p com.example.hello_app -c android.intent.category.LAUNCHER 1
```

---

## 🔍 Troubleshooting

### `INSTALL_FAILED_UPDATE_INCOMPATIBLE`
If you encounter an installation failure due to signature mismatch or existing incompatible installation:
```bash
adb uninstall com.example.hello_app
adb install -r downloads/app-release.apk
```

### Build Failed
If the GitHub Actions workflow build fails, view the failure details with:
```bash
gh run view <id> --log-failed
```

---

## ⚙️ CI/CD Workflow File Location
The GitHub Actions workflow configuration is located at:
`[build-release.yml](file://.github/workflows/build-release.yml)`
