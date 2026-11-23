import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/utils/firestore_guard.dart';
import '../../domain/entities/listing.dart';
import '../../domain/repositories/listing_repository.dart';

class ListingRepositoryImpl implements ListingRepository {
  ListingRepositoryImpl(this._db);
  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> get _col =>
      _db.collection('listings');

  static DateTime? _ts(dynamic v) => v is Timestamp ? v.toDate() : null;

  static Listing _fromDoc(DocumentSnapshot<Map<String, dynamic>> d) {
    final m = d.data() ?? {};
    return Listing(
      id: d.id,
      sellerId: m['sellerId'] as String? ?? '',
      sellerName: m['sellerName'] as String? ?? '',
      title: m['title'] as String? ?? '',
      category: m['category'] as String? ?? 'Other',
      hub: m['hub'] as String? ?? '',
      price: (m['price'] as num?)?.toInt() ?? 0,
      photoCount: (m['photoCount'] as num?)?.toInt() ?? 1,
      sold: m['status'] == 'sold',
      soldToName: m['soldToName'] as String?,
      soldAt: _ts(m['soldAt']),
      createdAt: _ts(m['createdAt']),
    );
  }

  /// Newest first. Sorted on the device so no composite index is needed.
  static List<Listing> _sorted(QuerySnapshot<Map<String, dynamic>> s) {
    final list = s.docs.map(_fromDoc).toList();
    // Pending server timestamps are null: treat them as "now" (newest).
    list.sort((a, b) => (b.createdAt ?? DateTime.now())
        .compareTo(a.createdAt ?? DateTime.now()));
    return list;
  }

  @override
  Stream<List<Listing>> watchMyListings(String sellerId) =>
      _col.where('sellerId', isEqualTo: sellerId).snapshots().map(_sorted);

  @override
  Stream<List<Listing>> watchActiveListings() =>
      _col.where('status', isEqualTo: 'active').snapshots().map(_sorted);

  @override
  Stream<Listing?> watchListing(String id) =>
      _col.doc(id).snapshots().map((d) => d.exists ? _fromDoc(d) : null);

  @override
  Future<Listing> create({
    required String sellerId,
    required String sellerName,
    required String title,
    required String category,
    required String hub,
    required int price,
    required int photoCount,
  }) async {
    final ref = _col.doc();
    await guardFirestore(() => ref.set({
          'sellerId': sellerId,
          'sellerName': sellerName,
          'title': title,
          'category': category,
          'hub': hub,
          'price': price,
          'photoCount': photoCount,
          'status': 'active',
          'createdAt': FieldValue.serverTimestamp(),
        }));
    return Listing(
      id: ref.id,
      sellerId: sellerId,
      sellerName: sellerName,
      title: title,
      category: category,
      hub: hub,
      price: price,
      photoCount: photoCount,
      createdAt: DateTime.now(),
    );
  }

  @override
  Future<void> update(String id,
      {String? title, int? price, String? category, String? hub}) {
    final data = <String, Object?>{
      if (title != null) 'title': title,
      if (price != null) 'price': price,
      if (category != null) 'category': category,
      if (hub != null) 'hub': hub,
    };
    if (data.isEmpty) return Future.value();
    return guardFirestore(() => _col.doc(id).update(data));
  }

  @override
  Future<void> delete(String id) => guardFirestore(() => _col.doc(id).delete());

  @override
  Future<void> markSold(String id, {required String buyerName}) =>
      guardFirestore(() => _col.doc(id).update({
            'status': 'sold',
            'soldToName': buyerName,
            'soldAt': FieldValue.serverTimestamp(),
          }));
}
