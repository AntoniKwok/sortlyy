# Platform Setup

Required one-time configuration before the app will build and run.

## 1. Credentials (`.env.json`)

Credentials are **never hardcoded**. They are injected at build time via
`--dart-define-from-file`. The file is gitignored — it lives only on your
machine and in your CI secrets.

Copy the example and fill in your values:
```bash
cp .env.json.example .env.json
```

`.env.json`:
```json
{
  "SUPABASE_URL": "https://YOUR_PROJECT_ID.supabase.co",
  "SUPABASE_ANON_KEY": "YOUR_ANON_KEY",
  "REVENUECAT_IOS_KEY": "appl_XXXX",
  "REVENUECAT_ANDROID_KEY": "goog_XXXX"
}
```

Get RevenueCat keys from: **app.revenuecat.com → Project → API Keys**
- iOS key starts with `appl_`
- Android key starts with `goog_`

Then run the app with:
```bash
flutter run --dart-define-from-file=.env.json
```

For release builds:
```bash
flutter build ios --dart-define-from-file=.env.json
flutter build apk --dart-define-from-file=.env.json
```

For CI/CD (GitHub Actions etc.), pass them as `--dart-define` flags directly
using repository secrets — no file needed.

> **Tip:** Add a launch config to VS Code / Android Studio so you don't have to
> type the flag every time. See `SETUP.md` bottom section.

In Supabase Dashboard → Authentication → Providers:
- Enable **Google** (paste the Web Client ID from Google Cloud Console)
- Enable **Apple** (paste your Apple Team ID + Service ID)

## 2. Google Sign-In

### iOS
1. Download `GoogleService-Info.plist` from Firebase or Google Cloud Console
2. Add it to `ios/Runner/` in Xcode (drag into the Runner group, **Copy if needed**)
3. In `lib/core/di/injection_container.dart`, set `clientId` in the `GoogleSignIn` constructor to your iOS client ID from `GoogleService-Info.plist`

### Android
1. Download `google-services.json` from Firebase Console
2. Place it in `android/app/`
3. In `android/app/build.gradle`, add at the bottom:
   ```groovy
   apply plugin: 'com.google.gms.google-services'
   ```
4. In `android/build.gradle` (project-level), add to `dependencies`:
   ```groovy
   classpath 'com.google.gms:google-services:4.4.0'
   ```
5. In `injection_container.dart`, set `serverClientId` to the **Web application** OAuth client ID

## 3. Apple Sign-In (iOS only)

1. In Xcode → Runner → Signing & Capabilities → **+ Capability** → **Sign In with Apple**
2. In Apple Developer Portal → Certificates, Identifiers & Profiles:
   - Enable **Sign In with Apple** for your App ID
   - Create a **Services ID** for the web redirect URL (needed by Supabase)
3. Configure the **Apple** provider in Supabase Dashboard with your Team ID, Bundle ID, Key ID, and private key

## 4. Photo Library (iOS)

Add to `ios/Runner/Info.plist`:
```xml
<key>NSPhotoLibraryUsageDescription</key>
<string>Sortly needs access to your photos to help you clean your camera roll.</string>
```

## 5. Photo / Media permissions (Android)

Already handled by `permission_handler`. For Android 13+, `READ_MEDIA_IMAGES` is used automatically by `photo_manager`.

## 6. Run the app

```bash
# Get deps (already done)
flutter pub get

# Regenerate Freezed/JSON code (run after any annotation changes)
flutter packages pub run build_runner build --delete-conflicting-outputs

# Run
flutter run
```
