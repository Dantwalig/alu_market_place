import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

import 'package:alu_market_place/core/ui/ui_message.dart';
import 'package:alu_market_place/features/auth/domain/entities/app_user.dart';
import 'package:alu_market_place/features/listings/domain/entities/listing.dart';
import 'package:alu_market_place/features/listings/domain/repositories/listing_repository.dart';
import 'package:alu_market_place/features/listings/presentation/cubit/search_cubit.dart';

class MockListingRepository extends Mock implements ListingRepository {}

void main() {
  late MockListingRepository repo;

  final listings = [
    Listing(
      id: 'L1',
      sellerId: 'U2',
      sellerName: 'Bob',
      title: 'Desk lamp',
      category: 'Furniture',
      hub: 'Kigali Campus Hub',
      price: 12000,
    ),
    Listing(
      id: 'L2',
      sellerId: 'U2',
      sellerName: 'Bob',
      title: 'Textbook',
      category: 'Books',
      hub: 'Library Entrance',
      price: 8000,
    ),
  ];

  setUp(() {
    repo = MockListingRepository();
  });

  group('SearchCubit', () {
    test('bind loads active listings and sets uid', () async {
      when(() => repo.watchActiveListings()).thenAnswer((_) async* {
        yield listings;
      });

      final cubit = SearchCubit(repo);
      await cubit.bind(const AppUser(uid: 'U1', email: 'a@b.c'));

      expect(cubit.state.uid, 'U1');
      expect(cubit.state.all, equals(listings));
      expect(cubit.state.loading, false);

      await cubit.close();
    });

    test('bind with null user resets state', () async {
      final cubit = SearchCubit(repo);
      await cubit.bind(const AppUser(uid: 'U1', email: 'a@b.c'));
      await cubit.bind(null);

      expect(cubit.state.uid, isNull);
      expect(cubit.state.all, isEmpty);

      await cubit.close();
    });

    test('setQuery updates the query', () {
      final cubit = SearchCubit(repo);
      cubit.setQuery('lamp');
      expect(cubit.state.query, 'lamp');
      cubit.close();
    });

    test('toggleCategory selects and clears the same category', () {
      final cubit = SearchCubit(repo);
      cubit.toggleCategory('Furniture');
      expect(cubit.state.category, 'Furniture');
      cubit.toggleCategory('Furniture');
      expect(cubit.state.category, isNull);
      cubit.close();
    });

    test('results exclude own listings and apply filters', () {
      final cubit = SearchCubit(repo);
      // Manually emit a state with listings and a uid
      cubit.emit(SearchState(
        all: listings,
        uid: 'U1',
        query: '',
        category: null,
      ));

      // No filter: excludes own (U1) but both are U2 -> 2 results
      expect(cubit.state.results.length, 2);

      // Filter by Furniture -> 1 result
      cubit.emit(cubit.state.copyWith(category: 'Furniture'));
      expect(cubit.state.results.length, 1);
      expect(cubit.state.results.first.title, 'Desk lamp');

      // Query filter
      cubit.emit(cubit.state.copyWith(query: 'text', category: null));
      expect(cubit.state.results.length, 1);
      expect(cubit.state.results.first.title, 'Textbook');

      cubit.close();
    });

    test('loading state is reflected', () {
      final cubit = SearchCubit(repo);
      cubit.emit(const SearchState(loading: true));
      expect(cubit.state.loading, true);
      cubit.close();
    });

    test('error message is stored in state', () {
      final cubit = SearchCubit(repo);
      cubit.emit(SearchState(
        message: UiMessage.error('Could not load listings.'),
      ));
      expect(cubit.state.message, isNotNull);
      expect(cubit.state.message!.isError, true);
      cubit.close();
    });
  });
}
