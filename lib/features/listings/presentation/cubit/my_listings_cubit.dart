import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/app_exception.dart';
import '../../../../core/ui/ui_message.dart';
import '../../../auth/domain/entities/app_user.dart';
import '../../domain/entities/listing.dart';
import '../../domain/repositories/listing_repository.dart';

enum ListingFilter { all, active, sold }

class MyListingsState extends Equatable {
  final List<Listing> listings;
  final ListingFilter filter;
  final bool loading;
  final UiMessage? message;

  const MyListingsState({
    this.listings = const [],
    this.filter = ListingFilter.all,
    this.loading = false,
    this.message,
  });

  List<Listing> get active => listings.where((l) => !l.sold).toList();
  List<Listing> get sold => listings.where((l) => l.sold).toList();

  MyListingsState copyWith({
    List<Listing>? listings,
    ListingFilter? filter,
    bool? loading,
    UiMessage? message,
  }) =>
      MyListingsState(
        listings: listings ?? this.listings,
        filter: filter ?? this.filter,
        loading: loading ?? this.loading,
        message: message,
      );

  @override
  List<Object?> get props => [listings, filter, loading, message];
}

class MyListingsCubit extends Cubit<MyListingsState> {
  MyListingsCubit(this._repo) : super(const MyListingsState());
  final ListingRepository _repo;
  StreamSubscription<List<Listing>>? _sub;

  Future<void> bind(AppUser? user) async {
    await _sub?.cancel();
    if (user == null) {
      emit(const MyListingsState());
      return;
    }
    emit(state.copyWith(loading: true));
    _sub = _repo.watchMyListings(user.uid).listen(
          (items) => emit(state.copyWith(listings: items, loading: false)),
          onError: (_) => emit(state.copyWith(
              loading: false,
              message: UiMessage.error('Could not load your listings.'))),
        );
  }

  /// Tapping the selected pill again clears the filter.
  void toggleFilter(ListingFilter f) =>
      emit(state.copyWith(filter: state.filter == f ? ListingFilter.all : f));

  Future<void> edit(String id,
      {required String title, required int price}) async {
    try {
      await _repo.update(id, title: title, price: price);
      emit(state.copyWith(message: UiMessage.success('Listing updated')));
    } on AppException catch (e) {
      emit(state.copyWith(message: UiMessage.error(e.message)));
    }
  }

  Future<void> remove(String id) async {
    try {
      await _repo.delete(id);
      emit(state.copyWith(message: UiMessage.success('Listing deleted')));
    } on AppException catch (e) {
      emit(state.copyWith(message: UiMessage.error(e.message)));
    }
  }

  @override
  Future<void> close() async {
    await _sub?.cancel();
    return super.close();
  }
}
