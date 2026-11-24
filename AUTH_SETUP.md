# Authentication setup (Step 6)

Code lives in `lib/features/auth` (domain / data / presentation + AuthBloc).

## One-time Firebase setup
1. In the Firebase console create a project, then **Authentication > Sign-in method**: enable **Email/Password** and **Google**.
2. Android only: if this folder has no `android/` directory, run `flutter create --platforms=android,ios .` once.
3. Register the Android app (package name = `applicationId` in `android/app/build.gradle`) and download `google-services.json` into `android/app/`.
4. **Add your debug SHA-1** (needed for Google sign-in): `cd android && ./gradlew signingReport`, copy the SHA-1 into Project settings > Your apps. Re-download `google-services.json` afterwards.
5. Add the Google Services Gradle plugin:
   - `android/settings.gradle(.kts)` plugins block: `id("com.google.gms.google-services") version "4.4.2" apply false`
   - `android/app/build.gradle(.kts)` plugins block: `id("com.google.gms.google-services")`
   - Android `minSdk` must be 23 or higher.
6. (Optional) `dart pub global activate flutterfire_cli && flutterfire configure` is an alternative; if you use it, pass `options: DefaultFirebaseOptions.currentPlatform` to `Firebase.initializeApp` in `main.dart`.
7. `flutter pub get && flutter run` on an emulator or phone (not Chrome).

## What it does
- Email/password register, login, logout, password reset, email verification gate.
- Google sign-in.
- Session persists across restarts (`authStateChanges`).
- Validation: email format, password 8+ chars with letter and number, matching confirmation.
- Friendly error messages (wrong password, email in use, no internet, too many attempts).

## Firestore (Step 7)
1. Firebase console > Firestore Database > Create database (production mode).
2. Rules tab: paste the contents of `firestore.rules` and Publish.
3. Because rules require `email_verified`, users must verify their email before data loads.
