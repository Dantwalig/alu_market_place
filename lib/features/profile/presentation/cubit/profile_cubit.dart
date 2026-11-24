import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/app_exception.dart';
import '../../../../core/ui/ui_message.dart';
import '../../../auth/domain/entities/app_user.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/profile_repository.dart';

class ProfileState extends Equatable {
  final UserProfile? profile;
  final bool loading;
  final UiMessage? message;
  const ProfileState({this.profile, this.loading = false, this.message});

  @override
  List<Object?> get props => [profile, loading, message];
}

class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit(this._repo) : super(const ProfileState());
  final ProfileRepository _repo;
  StreamSubscription<UserProfile?>? _sub;
  String? _uid;

  Future<void> bind(AppUser? user) async {
    await _sub?.cancel();
    _uid = user?.uid;
    if (user == null) {
      emit(const ProfileState());
      return;
    }
    emit(const ProfileState(loading: true));
    try {
      await _repo.ensureProfile(user);
    } on AppException catch (e) {
      emit(ProfileState(message: UiMessage.error(e.message)));
    }
    _sub = _repo.watchProfile(user.uid).listen(
          (p) => emit(ProfileState(profile: p)),
          onError: (_) => emit(ProfileState(
              profile: state.profile,
              message: UiMessage.error('Could not load profile.'))),
        );
  }

  Future<void> updateHub(String hub) async {
    final uid = _uid;
    if (uid == null) return;
    try {
      await _repo.updateProfile(uid, hub: hub);
      emit(ProfileState(
          profile: state.profile,
          message: UiMessage.success('Trade Hub updated')));
    } on AppException catch (e) {
      emit(ProfileState(
          profile: state.profile, message: UiMessage.error(e.message)));
    }
  }

  @override
  Future<void> close() async {
    await _sub?.cancel();
    return super.close();
  }
}
