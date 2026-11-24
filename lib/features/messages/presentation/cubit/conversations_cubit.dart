import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/app_exception.dart';
import '../../../../core/ui/ui_message.dart';
import '../../../auth/domain/entities/app_user.dart';
import '../../../listings/domain/entities/listing.dart';
import '../../domain/entities/conversation.dart';
import '../../domain/repositories/messages_repository.dart';

class ConversationsState extends Equatable {
  final List<Conversation> all;
  final String? uid;
  final String query;
  final bool unreadOnly;
  final bool loading;
  final bool offline;
  final UiMessage? message;

  const ConversationsState({
    this.all = const [],
    this.uid,
    this.query = '',
    this.unreadOnly = false,
    this.loading = false,
    this.offline = false,
    this.message,
  });

  int get unreadCount =>
      uid == null ? 0 : all.where((c) => c.isUnreadFor(uid!)).length;

  List<Conversation> get visible {
    final me = uid;
    if (me == null) return const [];
    final q = query.trim().toLowerCase();
    return all.where((c) {
      if (unreadOnly && !c.isUnreadFor(me)) return false;
      if (q.isEmpty) return true;
      return c.otherName(me).toLowerCase().contains(q) ||
          c.listingTitle.toLowerCase().contains(q);
    }).toList();
  }

  ConversationsState copyWith({
    List<Conversation>? all,
    String? query,
    bool? unreadOnly,
    bool? loading,
    bool? offline,
    UiMessage? message,
  }) =>
      ConversationsState(
        all: all ?? this.all,
        uid: uid,
        query: query ?? this.query,
        unreadOnly: unreadOnly ?? this.unreadOnly,
        loading: loading ?? this.loading,
        offline: offline ?? this.offline,
        message: message,
      );

  @override
  List<Object?> get props =>
      [all, uid, query, unreadOnly, loading, offline, message];
}

/// Inbox: live list of the user's conversations plus search / unread filters.
class ConversationsCubit extends Cubit<ConversationsState> {
  ConversationsCubit(this._repo) : super(const ConversationsState());
  final MessagesRepository _repo;
  StreamSubscription<List<Conversation>>? _sub;
  AppUser? _user;

  Future<void> bind(AppUser? user) async {
    await _sub?.cancel();
    _user = user;
    if (user == null) {
      emit(const ConversationsState());
      return;
    }
    emit(ConversationsState(uid: user.uid, loading: true));
    _sub = _repo.watchConversations(user.uid).listen(
          (items) =>
              emit(state.copyWith(all: items, loading: false, offline: false)),
          onError: (_) => emit(state.copyWith(loading: false, offline: true)),
        );
  }

  void retry() => bind(_user);
  void setQuery(String q) => emit(state.copyWith(query: q));
  void setUnreadOnly(bool v) => emit(state.copyWith(unreadOnly: v));

  /// Opens the buyer's conversation about [listing]; returns its id or null on error.
  Future<String?> startChat(Listing listing) async {
    final me = _user;
    if (me == null) return null;
    try {
      return await _repo.startConversation(
          listing: listing, buyerId: me.uid, buyerName: me.shownName);
    } on AppException catch (e) {
      emit(state.copyWith(message: UiMessage.error(e.message)));
      return null;
    }
  }

  @override
  Future<void> close() async {
    await _sub?.cancel();
    return super.close();
  }
}
