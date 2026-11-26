import '../entities/listing.dart';

abstract class ListingRepository {
  /// Listings created by [sellerId], newest first.
  Stream<List<Listing>> watchMyListings(String sellerId);

  /// All listings that are still for sale, newest first.
  Stream<List<Listing>> watchActiveListings();

  Stream<Listing?> watchListing(String id);

  Future<Listing> create({
    required String sellerId,
    required String sellerName,
    required String title,
    required String category,
    required String hub,
    required int price,
    required List<String> photos,
  });

  /// Update (only the provided fields change).
  Future<void> update(String id,
      {String? title, int? price, String? category, String? hub});

  Future<void> delete(String id);

  Future<void> markSold(String id, {required String buyerName});
}
