import '../../../listings/domain/entities/listing.dart';
import '../entities/conversation.dart';
import '../entities/message.dart';

abstract class MessagesRepository {
  Stream<List<Conversation>> watchConversations(String uid);
  Stream<Conversation?> watchConversation(String id);
  Stream<List<Message>> watchMessages(String conversationId);

  /// Opens (or creates) the one conversation between [buyerId] and the seller
  /// of [listing]. Returns its id.
  Future<String> startConversation({
    required Listing listing,
    required String buyerId,
    required String buyerName,
  });

  Future<void> sendMessage({
    required String conversationId,
    required String senderId,
    required String otherUid,
    required String text,
  });

  Future<void> markRead(String conversationId, String uid);
  Future<void> setMeetup(String conversationId, String meetup);

  Future<void> reportUser({
    required String reporterId,
    required String reportedUid,
    required String conversationId,
    required String reason,
  });
}
