import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/constants/hubs.dart';
import '../../../../core/utils/firestore_guard.dart';
import '../../../auth/domain/entities/app_user.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/profile_repository.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  ProfileRepositoryImpl(this._db);
  final FirebaseFirestore _db;

  DocumentReference<Map<String, dynamic>> _doc(String uid) =>
      _db.collection('users').doc(uid);

  @override
  Stream<UserProfile?> watchProfile(String uid) =>
      _doc(uid).snapshots().map((d) {
        final m = d.data();
        if (m == null) return null;
        return UserProfile(
          uid: d.id,
          name: m['name'] as String? ?? '',
          email: m['email'] as String? ?? '',
          year: m['year'] as String? ?? 'First year',
          hub: m['hub'] as String? ?? defaultHub,
        );
      });

  @override
  Future<void> ensureProfile(AppUser user) => guardFirestore(() async {
        final ref = _doc(user.uid);
        final snap = await ref.get();
        if (snap.exists) return;
        await ref.set({
          'name': user.shownName,
          'email': user.email,
          'year': 'First year',
          'hub': defaultHub,
          'createdAt': FieldValue.serverTimestamp(),
        });
      });

  @override
  Future<void> updateProfile(String uid, {String? hub, String? year}) {
    final data = <String, Object?>{
      if (hub != null) 'hub': hub,
      if (year != null) 'year': year,
    };
    if (data.isEmpty) return Future.value();
    return guardFirestore(() => _doc(uid).update(data));
  }
}
