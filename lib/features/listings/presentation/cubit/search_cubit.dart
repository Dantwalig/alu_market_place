import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/ui/ui_message.dart';
import '../../../auth/domain/entities/app_user.dart';
import '../../domain/entities/listing.dart';
import '../../domain/repositories/listing_repository.dart';

class SearchState extends Equatable {
  final List<Listing> all;
  final String? uid;
  final String query;

  final String? category;
  final bool loading;
  final UiMessage? message;

  const SearchState({
    this.all = const [],
    this.uid,
    this.query = '',
    this.category,
    this.loading = false,
    this.message,
  });

  List<Listing> get results {
    final q = query.trim().toLowerCase();
    return all.where((l) {
      if (l.sellerId == uid) return false;
      if (category != null && l.category != category) return false;
      if (q.isEmpty) return true;
      return l.title.toLowerCase().contains(q) ||
          l.sellerName.toLowerCase().contains(q) ||
          l.hub.toLowerCase().contains(q);
    }).toList();
  }

  SearchState copyWith(
          {String? query, String? category, bool clearCategory = false}) =>
      SearchState(
        all: all,
        uid: uid,
        query: query ?? this.query,
        category: clearCategory ? null : (category ?? this.category),
        loading: loading,
        message: message,
      );

  @override
  List<Object?> get props => [all, uid, query, category, loading, message];
}

/// Search tab: filters the live list of active listings by text and category.
/// Filtering happens on the device, so no extra Firestore index is needed.
class SearchCubit extends Cubit<SearchState> {
  SearchCubit(this._repo) : super(const SearchState());
  final ListingRepository _repo;
  StreamSubscription<List<Listing>>? _sub;

  Future<void> bind(AppUser? user) async {
    await _sub?.cancel();
    if (user == null) {
      emit(const SearchState());
      return;
    }
    emit(SearchState(uid: user.uid, loading: true));
    _sub = _repo.watchActiveListings().listen(
          (items) => emit(SearchState(
              all: items,
              uid: user.uid,
              query: state.query,
              category: state.category)),
          onError: (_) => emit(SearchState(
              uid: user.uid,
              query: state.query,
              category: state.category,
              message: UiMessage.error('Could not load listings.'))),
        );
  }

  void setQuery(String value) => emit(state.copyWith(query: value));

  /// Tapping the selected category again clears the filter.
  void toggleCategory(String category) => emit(state.category == category
      ? state.copyWith(clearCategory: true)
      : state.copyWith(category: category));

  @override
  Future<void> close() async {
    await _sub?.cancel();
    return super.close();
  }
}
