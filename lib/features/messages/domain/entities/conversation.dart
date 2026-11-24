import 'package:equatable/equatable.dart';

class Conversation extends Equatable {
  final String id;
  final String listingId;
  final String
      listingTitle; // copied from the listing so the inbox needs no extra reads
  final String sellerId;
  final String sellerName;
  final String buyerId;
  final String buyerName;
  final String lastMessage;
  final DateTime? lastMessageAt;
  final String? meetup;
  final List<String> unreadBy;

  const Conversation({
    required this.id,
    required this.listingId,
    required this.listingTitle,
    required this.sellerId,
    required this.sellerName,
    required this.buyerId,
    required this.buyerName,
    this.lastMessage = '',
    this.lastMessageAt,
    this.meetup,
    this.unreadBy = const [],
  });

  String otherId(String me) => me == sellerId ? buyerId : sellerId;
  String otherName(String me) => me == sellerId ? buyerName : sellerName;
  bool isUnreadFor(String me) => unreadBy.contains(me);

  @override
  List<Object?> get props => [
        id,
        listingId,
        listingTitle,
        sellerId,
        sellerName,
        buyerId,
        buyerName,
        lastMessage,
        lastMessageAt,
        meetup,
        unreadBy,
      ];
}
