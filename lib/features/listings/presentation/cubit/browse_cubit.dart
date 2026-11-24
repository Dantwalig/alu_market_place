import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/ui/ui_message.dart';
import '../../../auth/domain/entities/app_user.dart';
import '../../domain/entities/listing.dart';
import '../../domain/repositories/listing_repository.dart';

class BrowseState extends Equatable {
  final List<Listing> all;
  final String? uid;
  final bool loading;
  final UiMessage? message;
  const BrowseState(
      {this.all = const [], this.uid, this.loading = false, this.message});

  List<Listing> get visible => all.where((l) => l.sellerId != uid).toList();

  @override
  List<Object?> get props => [all, uid, loading, message];
}

class BrowseCubit extends Cubit<BrowseState> {
  BrowseCubit(this._repo) : super(const BrowseState());
  final ListingRepository _repo;
  StreamSubscription<List<Listing>>? _sub;

  Future<void> bind(AppUser? user) async {
    await _sub?.cancel();
    if (user == null) {
      emit(const BrowseState());
      return;
    }
    emit(BrowseState(uid: user.uid, loading: true));
    _sub = _repo.watchActiveListings().listen(
          (items) => emit(BrowseState(all: items, uid: user.uid)),
          onError: (_) => emit(BrowseState(
              uid: user.uid,
              message: UiMessage.error('Could not load listings.'))),
        );
  }

  @override
  Future<void> close() async {
    await _sub?.cancel();
    return super.close();
  }
}
