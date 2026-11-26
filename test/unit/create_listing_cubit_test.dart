import 'dart:typed_data';

import 'package:mocktail/mocktail.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:alu_market_place/core/errors/app_exception.dart';
import 'package:alu_market_place/features/auth/domain/entities/app_user.dart';
import 'package:alu_market_place/features/listings/domain/entities/listing.dart';
import 'package:alu_market_place/features/listings/domain/repositories/listing_repository.dart';
import 'package:alu_market_place/features/listings/presentation/cubit/create_listing_cubit.dart';

class MockListingRepository extends Mock implements ListingRepository {}

void main() {
  late MockListingRepository repo;
  late AppUser user;

  setUp(() {
    repo = MockListingRepository();
    user =
        const AppUser(uid: 'U1', email: 'alice@alu.edu', displayName: 'Alice');
  });

  group('CreateListingCubit', () {
    test('initial state has step 0 and default hub', () {
      final cubit = CreateListingCubit(repo, user, 'Kigali Campus Hub');
      expect(cubit.state.step, 0);
      expect(cubit.state.hub, 'Kigali Campus Hub');
      expect(cubit.state.photos, 0);
      expect(cubit.state.title, '');
      expect(cubit.state.essentialsValid, false);
      cubit.close();
    });

    test('setTitle updates title', () {
      final cubit = CreateListingCubit(repo, user, 'Hub');
      cubit.setTitle('Desk lamp');
      expect(cubit.state.title, 'Desk lamp');
      cubit.close();
    });

    test('setPrice updates price text', () {
      final cubit = CreateListingCubit(repo, user, 'Hub');
      cubit.setPrice('12000');
      expect(cubit.state.priceText, '12000');
      expect(cubit.state.priceValue, 12000);
      cubit.close();
    });

    test('setCategory updates category', () {
      final cubit = CreateListingCubit(repo, user, 'Hub');
      cubit.setCategory('Furniture');
      expect(cubit.state.category, 'Furniture');
      cubit.close();
    });

    test('addPhotos adds photos up to max 5', () {
      final cubit = CreateListingCubit(repo, user, 'Hub');
      cubit.addPhotos([Uint8List.fromList([1, 2, 3])]);
      cubit.addPhotos([Uint8List.fromList([1, 2, 3])]);
      expect(cubit.state.photos, 2);
      for (var i = 0; i < 4; i++) {
        cubit.addPhotos([Uint8List.fromList([1, 2, 3])]);
      }
      expect(cubit.state.photos, 5);
      cubit.close();
    });

    test('essentialsValid is true only when all fields are complete', () {
      final cubit = CreateListingCubit(repo, user, 'Hub');
      expect(cubit.state.essentialsValid, false);

      cubit.setTitle('Desk lamp');
      expect(cubit.state.essentialsValid, false);

      cubit.setPrice('12000');
      expect(cubit.state.essentialsValid, false);

      cubit.setCategory('Furniture');
      expect(cubit.state.essentialsValid, false); // no photos yet

      cubit.addPhotos([Uint8List.fromList([1, 2, 3])]);
      expect(cubit.state.essentialsValid, true);
      cubit.close();
    });

    test('next on step 0 with invalid essentials shows errors', () {
      final cubit = CreateListingCubit(repo, user, 'Hub');
      cubit.next(); // empty form
      expect(cubit.state.step, 0);
      expect(cubit.state.showErrors, true);
      expect(cubit.state.titleError, 'Enter a title');
      expect(cubit.state.priceError, 'Enter a price in RWF');
      expect(cubit.state.categoryError, 'Choose a category');
      expect(cubit.state.photoError, 'Add at least one photo');
      cubit.close();
    });

    test('next on step 0 with valid essentials advances to step 1', () {
      final cubit = CreateListingCubit(repo, user, 'Hub');
      cubit.setTitle('Desk lamp');
      cubit.setPrice('12000');
      cubit.setCategory('Furniture');
      cubit.addPhotos([Uint8List.fromList([1, 2, 3])]);
      cubit.next();
      expect(cubit.state.step, 1);
      expect(cubit.state.showErrors, false);
      cubit.close();
    });

    test('next on step 1 advances to step 2', () {
      final cubit = CreateListingCubit(repo, user, 'Hub');
      cubit.emit(cubit.state.copyWith(step: 1));
      cubit.next();
      expect(cubit.state.step, 2);
      cubit.close();
    });

    test('next on step 2 calls publish', () async {
      when(() => repo.create(
            sellerId: 'U1',
            sellerName: 'Alice',
            title: 'Desk lamp',
            category: 'Furniture',
            hub: 'Hub',
            price: 12000,
            photos: any(named: 'photos'),
          )).thenAnswer((_) async => const Listing(
            id: 'L1',
            sellerId: 'U1',
            sellerName: 'Alice',
            title: 'Desk lamp',
            category: 'Furniture',
            hub: 'Hub',
            price: 12000,
          ));
      final cubit = CreateListingCubit(repo, user, 'Hub');
      cubit.setTitle('Desk lamp');
      cubit.setPrice('12000');
      cubit.setCategory('Furniture');
      cubit.addPhotos([Uint8List.fromList([1, 2, 3])]);
      cubit.next(); // step 0 -> 1
      cubit.next(); // step 1 -> 2
      await cubit.publish();
      expect(cubit.state.published, isNotNull);
      expect(cubit.state.published!.id, 'L1');
      cubit.close();
    });

    test('publish failure emits error message', () async {
      when(() => repo.create(
            sellerId: 'U1',
            sellerName: 'Alice',
            title: 'Desk lamp',
            category: 'Furniture',
            hub: 'Hub',
            price: 12000,
            photos: any(named: 'photos'),
          )).thenThrow(const AppException('Create failed.'));
      final cubit = CreateListingCubit(repo, user, 'Hub');
      cubit.setTitle('Desk lamp');
      cubit.setPrice('12000');
      cubit.setCategory('Furniture');
      cubit.addPhotos([Uint8List.fromList([1, 2, 3])]);
      cubit.next(); // step 0 -> 1
      cubit.next(); // step 1 -> 2
      await cubit.publish();
      expect(cubit.state.publishing, false);
      expect(cubit.state.message, isNotNull);
      expect(cubit.state.message!.isError, true);
      cubit.close();
    });

    test('back on step 0 returns false', () {
      final cubit = CreateListingCubit(repo, user, 'Hub');
      expect(cubit.back(), false);
      cubit.close();
    });

    test('back on step 1 returns true and goes to step 0', () {
      final cubit = CreateListingCubit(repo, user, 'Hub');
      cubit.emit(cubit.state.copyWith(step: 1));
      expect(cubit.back(), true);
      expect(cubit.state.step, 0);
      cubit.close();
    });
  });
}
