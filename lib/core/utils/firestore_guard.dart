import 'dart:async';

import 'package:firebase_core/firebase_core.dart';

import '../errors/app_exception.dart';

/// Runs a Firestore call, adds a timeout (offline writes would otherwise wait
/// forever) and converts low-level errors into [AppException]s.
Future<T> guardFirestore<T>(Future<T> Function() action) async {
  try {
    return await action().timeout(const Duration(seconds: 15));
  } on TimeoutException {
    throw const AppException(
        'Request timed out. Check your connection and try again.');
  } on FirebaseException catch (e) {
    throw AppException(firestoreMessage(e.code));
  }
}

String firestoreMessage(String code) {
  switch (code) {
    case 'permission-denied':
      return 'You do not have permission to do that.';
    case 'unavailable':
      return 'No internet connection. Please try again.';
    case 'not-found':
      return 'That item no longer exists.';
    default:
      return 'Something went wrong. Please try again.';
  }
}
