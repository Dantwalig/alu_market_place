import 'package:equatable/equatable.dart';

class Listing extends Equatable {
  final String id;
  final String sellerId;
  final String sellerName;
  final String title;
  final String category;
  final String hub;
  final int price;
  final int photoCount;

  /// Base64 encoded JPEG photos. The first one is the cover.
  final List<String> photos;
  final bool sold;
  final String? soldToName;
  final DateTime? soldAt;
  final DateTime? createdAt;

  const Listing({
    required this.id,
    required this.sellerId,
    required this.sellerName,
    required this.title,
    required this.category,
    required this.hub,
    required this.price,
    this.photoCount = 1,
    this.photos = const [],
    this.sold = false,
    this.soldToName,
    this.soldAt,
    this.createdAt,
  });

  @override
  List<Object?> get props => [
        id,
        sellerId,
        sellerName,
        title,
        category,
        hub,
        price,
        photoCount,
        photos,
        sold,
        soldToName,
        soldAt,
        createdAt
      ];
}
