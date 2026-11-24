// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;

/// Firebase options for the web build only. Android keeps using
/// android/app/google-services.json.
///
/// Fill these values in from the Firebase console:
/// Project settings > Your apps > Web app > SDK setup and configuration.
class DefaultFirebaseOptions {
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'PASTE_API_KEY',
    appId: 'PASTE_APP_ID',
    messagingSenderId: 'PASTE_MESSAGING_SENDER_ID',
    projectId: 'PASTE_PROJECT_ID',
    authDomain: 'PASTE_AUTH_DOMAIN',
    storageBucket: 'PASTE_STORAGE_BUCKET',
  );
}
