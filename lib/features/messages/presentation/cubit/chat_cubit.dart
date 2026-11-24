import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/app_exception.dart';
import '../../../../core/ui/ui_message.dart';
import '../../../auth/domain/entities/app_user.dart';
import '../../../listings/domain/entities/listing.dart';
import '../../../listings/domain/repositories/listing_repository.dart';
import '../../domain/entities/conversation.dart';
import '../../domain/entities/message.dart';
import '../../domain/repositories/messages_repository.dart';

class ChatState extends Equatable {
  final Conversation? conversation;
  final Listing? listing;
  final List<Message> messages;
  final bool busy;
  final UiMessage? message;

  const ChatState(
      {this.conversation,
      this.listing,
      this.messages = const [],
      this.busy = false,
      this.message});

  bool get sold => listing?.sold ?? false;

  ChatState copyWith({
    Conversation? conversation,
    Listing? listing,
    List<Message>? messages,
    bool? busy,
    UiMessage? message,
  }) =>
      ChatState(
        conversation: conversation ?? this.conversation,
        listing: listing ?? this.listing,
        messages: messages ?? this.messages,
        busy: busy ?? this.busy,
        message: message,
      );

  @override
  List<Object?> get props => [conversation, listing, messages, busy, message];
}

/// One open chat: live messages + conversation + the listing it is about.
class ChatCubit extends Cubit<ChatState> {
  ChatCubit(this._messages, this._listings, this.me, this.conversationId)
      : super(const ChatState());

  final MessagesRepository _messages;
  final ListingRepository _listings;
  final AppUser me;
  final String conversationId;

  StreamSubscription<Conversation?>? _convSub;
  StreamSubscription<List<Message>>? _msgSub;
  StreamSubscription<Listing?>? _listingSub;
  String? _listingId;

  void start() {
    _convSub = _messages.watchConversation(conversationId).listen((c) {
      if (c == null) return;
      emit(state.copyWith(conversation: c));
      if (c.isUnreadFor(me.uid))
        _messages.markRead(conversationId, me.uid).catchError((_) {});
      if (_listingId != c.listingId) {
        _listingId = c.listingId;
        _listingSub?.cancel();
        _listingSub = _listings
            .watchListing(c.listingId)
            .listen((l) => emit(state.copyWith(listing: l)));
      }
    },
        onError: (_) => emit(state.copyWith(
            message: UiMessage.error('Could not load this chat.'))));

    _msgSub = _messages.watchMessages(conversationId).listen(
          (m) => emit(state.copyWith(messages: m)),
          onError: (_) => emit(state.copyWith(
              message: UiMessage.error('Could not load messages.'))),
        );
  }

  Future<void> send(String text) async {
    final t = text.trim();
    final c = state.conversation;
    if (t.isEmpty || c == null) return;
    await _run(() => _messages.sendMessage(
          conversationId: conversationId,
          senderId: me.uid,
          otherUid: c.otherId(me.uid),
          text: t,
        ));
  }

  Future<void> confirmMeetup() async {
    final l = state.listing;
    if (l == null) return;
    await _run(
      () => _messages.setMeetup(
          conversationId, 'Meetup agreed · ${l.hub} · Public handoff'),
      success: 'Meetup confirmed',
    );
  }

  Future<void> markSold() async {
    final l = state.listing;
    final c = state.conversation;
    if (l == null || c == null) return;
    await _run(
      () => _listings.markSold(l.id, buyerName: c.otherName(me.uid)),
      success: '${l.title} marked as sold',
    );
  }

  Future<void> report(String reason) async {
    final c = state.conversation;
    if (c == null) return;
    await _run(
      () => _messages.reportUser(
        reporterId: me.uid,
        reportedUid: c.otherId(me.uid),
        conversationId: conversationId,
        reason: reason,
      ),
      success: 'Report sent. Thanks for keeping the hub safe.',
    );
  }

  Future<void> _run(Future<void> Function() action, {String? success}) async {
    try {
      await action();
      if (success != null)
        emit(state.copyWith(message: UiMessage.success(success)));
    } on AppException catch (e) {
      emit(state.copyWith(message: UiMessage.error(e.message)));
    }
  }

  @override
  Future<void> close() async {
    await _convSub?.cancel();
    await _msgSub?.cancel();
    await _listingSub?.cancel();
    return super.close();
  }
}
