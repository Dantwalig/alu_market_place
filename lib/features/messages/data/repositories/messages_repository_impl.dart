import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/utils/firestore_guard.dart';
import '../../../listings/domain/entities/listing.dart';
import '../../domain/entities/conversation.dart';
import '../../domain/entities/message.dart';
import '../../domain/repositories/messages_repository.dart';

/// Firestore: `conversations/{listingId_buyerId}` with a `messages` subcollection,
/// plus top-level `reports/{id}`.
class MessagesRepositoryImpl implements MessagesRepository {
  MessagesRepositoryImpl(this._db);
  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> get _convs =>
      _db.collection('conversations');

  static DateTime? _ts(dynamic v) => v is Timestamp ? v.toDate() : null;

  static Conversation _fromDoc(DocumentSnapshot<Map<String, dynamic>> d) {
    final m = d.data() ?? {};
    return Conversation(
      id: d.id,
      listingId: m['listingId'] as String? ?? '',
      listingTitle: m['listingTitle'] as String? ?? '',
      sellerId: m['sellerId'] as String? ?? '',
      sellerName: m['sellerName'] as String? ?? '',
      buyerId: m['buyerId'] as String? ?? '',
      buyerName: m['buyerName'] as String? ?? '',
      lastMessage: m['lastMessage'] as String? ?? '',
      lastMessageAt: _ts(m['lastMessageAt']),
      meetup: m['meetup'] as String?,
      unreadBy: List<String>.from(m['unreadBy'] as List? ?? const []),
    );
  }

  @override
  Stream<List<Conversation>> watchConversations(String uid) =>
      _convs.where('participantIds', arrayContains: uid).snapshots().map((s) {
        final list = s.docs.map(_fromDoc).toList();
        final now = DateTime.now();
        list.sort((a, b) =>
            (b.lastMessageAt ?? now).compareTo(a.lastMessageAt ?? now));
        return list;
      });

  @override
  Stream<Conversation?> watchConversation(String id) =>
      _convs.doc(id).snapshots().map((d) => d.exists ? _fromDoc(d) : null);

  @override
  Stream<List<Message>> watchMessages(String conversationId) => _convs
      .doc(conversationId)
      .collection('messages')
      .orderBy('createdAt')
      .snapshots()
      .map((s) => s.docs.map((d) {
            final m = d.data();
            return Message(
              id: d.id,
              senderId: m['senderId'] as String? ?? '',
              text: m['text'] as String? ?? '',
              createdAt: _ts(m['createdAt']) ?? DateTime.now(),
            );
          }).toList());

  @override
  Future<String> startConversation({
    required Listing listing,
    required String buyerId,
    required String buyerName,
  }) {
    final id = '${listing.id}_$buyerId';
    return guardFirestore(() async {
      final ref = _convs.doc(id);
      final existing = await ref.get();
      if (!existing.exists) {
        await ref.set({
          'participantIds': [listing.sellerId, buyerId],
          'listingId': listing.id,
          'listingTitle': listing.title,
          'sellerId': listing.sellerId,
          'sellerName': listing.sellerName,
          'buyerId': buyerId,
          'buyerName': buyerName,
          'lastMessage': '',
          'lastMessageAt': FieldValue.serverTimestamp(),
          'unreadBy': <String>[],
        });
      }
      return id;
    });
  }

  @override
  Future<void> sendMessage({
    required String conversationId,
    required String senderId,
    required String otherUid,
    required String text,
  }) {
    final conv = _convs.doc(conversationId);
    final batch = _db.batch()
      ..set(conv.collection('messages').doc(), {
        'senderId': senderId,
        'text': text,
        'createdAt': FieldValue.serverTimestamp(),
      })
      ..update(conv, {
        'lastMessage': text,
        'lastMessageAt': FieldValue.serverTimestamp(),
        'unreadBy': [otherUid],
      });
    return guardFirestore(batch.commit);
  }

  @override
  Future<void> markRead(String conversationId, String uid) =>
      guardFirestore(() => _convs.doc(conversationId).update({
            'unreadBy': FieldValue.arrayRemove([uid]),
          }));

  @override
  Future<void> setMeetup(String conversationId, String meetup) =>
      guardFirestore(
          () => _convs.doc(conversationId).update({'meetup': meetup}));

  @override
  Future<void> reportUser({
    required String reporterId,
    required String reportedUid,
    required String conversationId,
    required String reason,
  }) =>
      guardFirestore(() => _db.collection('reports').add({
            'reporterId': reporterId,
            'reportedUid': reportedUid,
            'conversationId': conversationId,
            'reason': reason,
            'createdAt': FieldValue.serverTimestamp(),
          }));
}
