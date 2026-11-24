import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:alu_market_place/features/auth/domain/entities/app_user.dart';
import 'package:alu_market_place/features/listings/domain/entities/listing.dart';
import 'package:alu_market_place/features/listings/domain/repositories/listing_repository.dart';
import 'package:alu_market_place/features/listings/presentation/cubit/search_cubit.dart';
import 'package:alu_market_place/features/listings/presentation/pages/search_screen.dart';
import 'package:alu_market_place/features/messages/presentation/cubit/conversations_cubit.dart';

class MockListingRepository extends Mock implements ListingRepository {}

class MockConversationsCubit extends Mock implements ConversationsCubit {}

void main() {
  late MockListingRepository mockListingRepo;
  late SearchCubit searchCubit;
  late MockConversationsCubit mockConversationsCubit;

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
    mockListingRepo = MockListingRepository();
    searchCubit = SearchCubit(mockListingRepo);
    mockConversationsCubit = MockConversationsCubit();

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
          BlocProvider<ConversationsCubit>.value(value: mockConversationsCubit),
        ],
        child: MaterialApp(home: SearchScreen()),
      );

  group('SearchScreen', () {
    testWidgets('renders search field and category pills',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget());

      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('Furniture'), findsOneWidget);
      expect(find.text('Books'), findsOneWidget);
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
      searchCubit.emit(SearchState(
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

    testWidgets('message seller calls startChat on ConversationsCubit',
        (WidgetTester tester) async {
      when(() => mockConversationsCubit.startChat(any()))
          .thenAnswer((_) async => 'C1');
      await tester.pumpWidget(buildTestableWidget());

      await tester.tap(find.text('Message seller').first);
      await tester.pump();

      verify(() => mockConversationsCubit.startChat(any())).called(1);
    });
  });
}
