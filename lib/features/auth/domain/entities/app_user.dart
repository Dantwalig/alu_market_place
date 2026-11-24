import 'package:equatable/equatable.dart';

/// Authenticated user as seen by the rest of the app (no Firebase types).
class AppUser extends Equatable {
  final String uid;
  final String email;
  final String? displayName;
  final bool emailVerified;

  const AppUser({
    required this.uid,
    required this.email,
    this.displayName,
    this.emailVerified = false,
  });

  String get shownName {
    final n = displayName?.trim() ?? '';
    return n.isNotEmpty ? n : email.split('@').first;
  }

  @override
  List<Object?> get props => [uid, email, displayName, emailVerified];
}
