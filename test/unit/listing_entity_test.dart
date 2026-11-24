import 'package:flutter_test/flutter_test.dart';

import 'package:alu_market_place/features/listings/domain/entities/listing.dart';

void main() {
  group('Listing', () {
    final listing = Listing(
      id: 'L1',
      sellerId: 'U1',
      sellerName: 'Alice',
      title: 'Desk lamp',
      category: 'Furniture',
      hub: 'Kigali Campus Hub',
      price: 12000,
      photoCount: 3,
      sold: false,
      createdAt: DateTime(2024, 6, 10),
    );

    test('props include all fields', () {
      expect(listing.props, [
        'L1',
        'U1',
        'Alice',
        'Desk lamp',
        'Furniture',
        'Kigali Campus Hub',
        12000,
        3,
        false,
        null,
        null,
        DateTime(2024, 6, 10),
      ]);
    });

    test('equatable equality works for identical instances', () {
      final other = Listing(
        id: 'L1',
        sellerId: 'U1',
        sellerName: 'Alice',
        title: 'Desk lamp',
        category: 'Furniture',
        hub: 'Kigali Campus Hub',
        price: 12000,
        photoCount: 3,
        sold: false,
        createdAt: DateTime(2024, 6, 10),
      );
      expect(listing == other, true);
    });

    test('different id means not equal', () {
      const other = Listing(
        id: 'L2',
        sellerId: 'U1',
        sellerName: 'Alice',
        title: 'Desk lamp',
        category: 'Furniture',
        hub: 'Kigali Campus Hub',
        price: 12000,
      );
      expect(listing == other, false);
    });

    test('different price means not equal', () {
      const other = Listing(
        id: 'L1',
        sellerId: 'U1',
        sellerName: 'Alice',
        title: 'Desk lamp',
        category: 'Furniture',
        hub: 'Kigali Campus Hub',
        price: 15000,
      );
      expect(listing == other, false);
    });
  });
}
