import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

import 'package:alu_market_place/core/errors/app_exception.dart';
import 'package:alu_market_place/core/ui/ui_message.dart';
import 'package:alu_market_place/features/auth/domain/entities/app_user.dart';
import 'package:alu_market_place/features/listings/domain/entities/listing.dart';
import 'package:alu_market_place/features/listings/domain/repositories/listing_repository.dart';
import 'package:alu_market_place/features/listings/presentation/cubit/my_listings_cubit.dart';

class MockListingRepository extends Mock implements ListingRepository {}

void main() {
  late MockListingRepository repo;

  final listings = [
    Listing(
      id: 'L1',
      sellerId: 'U1',
      sellerName: 'Alice',
      title: 'Desk lamp',
      category: 'Furniture',
      hub: 'Kigali Campus Hub',
      price: 12000,
      sold: false,
    ),
    Listing(
      id: 'L2',
      sellerId: 'U1',
      sellerName: 'Alice',
      title: 'Textbook',
      category: 'Books',
      hub: 'Library Entrance',
      price: 8000,
      sold: true,
    ),
  ];

  setUp(() {
    repo = MockListingRepository();
  });

  group('MyListingsCubit', () {
    test('bind loads my listings and sets loading false', () async {
      when(() => repo.watchMyListings('U1')).thenAnswer((_) async* {
        yield listings;
      });

      final cubit = MyListingsCubit(repo);
      await cubit.bind(const AppUser(uid: 'U1', email: 'a@b.c'));
      await Future.delayed(Duration.zero);

      expect(cubit.state.listings, equals(listings));
      expect(cubit.state.loading, false);
      expect(cubit.state.active.length, 1);
      expect(cubit.state.sold.length, 1);
      await cubit.close();
    });

    test('bind with null user resets state', () async {
      when(() => repo.watchMyListings(any()))
          .thenAnswer((_) => Stream.value([]));
      final cubit = MyListingsCubit(repo);
      await cubit.bind(const AppUser(uid: 'U1', email: 'a@b.c'));
      await cubit.bind(null);

      expect(cubit.state.listings, isEmpty);
      expect(cubit.state.loading, false);
      await cubit.close();
    });

    test('toggleFilter cycles between filter and all', () {
      final cubit = MyListingsCubit(repo);
      cubit.emit(const MyListingsState(filter: ListingFilter.all));
      cubit.toggleFilter(ListingFilter.active);
      expect(cubit.state.filter, ListingFilter.active);
      cubit.toggleFilter(ListingFilter.active);
      expect(cubit.state.filter, ListingFilter.all);
      cubit.close();
    });

    test('edit success emits success message and updates repo', () async {
      when(() => repo.update('L1', title: 'New title', price: 15000))
          .thenAnswer((_) async => null);
      final cubit = MyListingsCubit(repo);

      await cubit.edit('L1', title: 'New title', price: 15000);

      verify(() => repo.update('L1', title: 'New title', price: 15000))
          .called(1);
      expect(cubit.state.message, isNotNull);
      expect(cubit.state.message!.isError, false);
      cubit.close();
    });

    test('edit failure emits error message', () async {
      when(() => repo.update('L1', title: 'x', price: 1))
          .thenThrow(const AppException('Update failed.'));
      final cubit = MyListingsCubit(repo);

      await cubit.edit('L1', title: 'x', price: 1);

      expect(cubit.state.message, isNotNull);
      expect(cubit.state.message!.isError, true);
      expect(cubit.state.message!.text, 'Update failed.');
      cubit.close();
    });

    test('remove success deletes from repo and emits success', () async {
      when(() => repo.delete('L1')).thenAnswer((_) async => null);
      final cubit = MyListingsCubit(repo);

      await cubit.remove('L1');

      verify(() => repo.delete('L1')).called(1);
      expect(cubit.state.message!.isError, false);
      cubit.close();
    });

    test('remove failure emits error message', () async {
      when(() => repo.delete('L1'))
          .thenThrow(const AppException('Delete failed.'));
      final cubit = MyListingsCubit(repo);

      await cubit.remove('L1');

      expect(cubit.state.message!.isError, true);
      expect(cubit.state.message!.text, 'Delete failed.');
      cubit.close();
    });
  });
}
