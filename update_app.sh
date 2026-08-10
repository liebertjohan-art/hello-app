#!/bin/bash
set -e

echo "Downloading latest release APK from GitHub..."
gh release download --dir downloads/ --clobber --pattern '*.apk'

echo "Installing APK to connected device..."
adb install -r downloads/app-release.apk

echo "Update complete! ✅"
