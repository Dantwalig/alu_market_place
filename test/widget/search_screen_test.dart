import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:alu_market_place/features/listings/domain/entities/listing.dart';
import 'package:alu_market_place/features/listings/domain/repositories/listing_repository.dart';
import 'package:alu_market_place/features/listings/presentation/cubit/search_cubit.dart';
import 'package:alu_market_place/features/listings/presentation/pages/search_screen.dart';

class MockListingRepository extends Mock implements ListingRepository {}

void main() {
  late MockListingRepository mockListingRepo;
  late SearchCubit searchCubit;

  final listings = [
    const Listing(
      id: 'L1',
      sellerId: 'U2',
      sellerName: 'Bob',
      title: 'Desk lamp',
      category: 'Furniture',
      hub: 'Kigali Campus Hub',
      price: 12000,
    ),
    const Listing(
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
    mockListingRepo = MockListingRepository();
    searchCubit = SearchCubit(mockListingRepo);

    // Pre-populate search state with listings
    searchCubit.emit(SearchState(
      all: listings,
      uid: 'U1',
      query: '',
      category: null,
    ));
  });

  tearDown(() {
    searchCubit.close();
  });

  Widget buildTestableWidget() => MultiBlocProvider(
        providers: [
          BlocProvider<SearchCubit>.value(value: searchCubit),
        ],
        child: const MaterialApp(home: SearchScreen()),
      );

  group('SearchScreen', () {
    testWidgets('renders search field and category pills',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget());
      await tester.pumpAndSettle();

      expect(find.byType(TextField), findsOneWidget);
      // Furniture and Books also appear as tags on the listing cards, so
      // they match more than one widget. Electronics has no listing.
      expect(find.text('Furniture'), findsWidgets);
      expect(find.text('Books'), findsWidgets);
      expect(find.text('Electronics'), findsOneWidget);
    });

    testWidgets('renders listing cards when results exist',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget());

      expect(find.text('Desk lamp'), findsOneWidget);
      expect(find.text('Textbook'), findsOneWidget);
      expect(find.text('RWF 12,000'), findsOneWidget);
      expect(find.text('RWF 8,000'), findsOneWidget);
      expect(find.text('Message seller'), findsNWidgets(2));
    });

    testWidgets('shows "No matching listings" when results are empty',
        (WidgetTester tester) async {
      searchCubit.emit(const SearchState(
        all: [],
        uid: 'U1',
        query: '',
        category: null,
      ));
      await tester.pumpWidget(buildTestableWidget());

      expect(find.text('No matching listings'), findsOneWidget);
    });

    testWidgets('filtering by query updates results',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget());

      // Type into the search field
      await tester.enterText(find.byType(TextField), 'lamp');
      await tester.pump();

      // Only 'Desk lamp' should match
      expect(find.text('Desk lamp'), findsOneWidget);
      expect(find.text('Textbook'), findsNothing);
    });
  });
}
