import '../../../auth/domain/entities/app_user.dart';
import '../entities/user_profile.dart';

abstract class ProfileRepository {
  Stream<UserProfile?> watchProfile(String uid);

  /// Creates `users/{uid}` on first sign-in; does nothing if it exists.
  Future<void> ensureProfile(AppUser user);

  Future<void> updateProfile(String uid, {String? hub, String? year});
}
