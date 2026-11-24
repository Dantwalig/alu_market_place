import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/app_exception.dart';
import '../../../../core/ui/ui_message.dart';
import '../../../auth/domain/entities/app_user.dart';
import '../../domain/entities/listing.dart';
import '../../domain/repositories/listing_repository.dart';

class CreateListingState extends Equatable {
  final int step; // 0 essentials, 1 meetup hub, 2 review
  final int photos;
  final String title;
  final String priceText;
  final String? category;
  final String hub;
  final bool showErrors;
  final bool publishing;
  final Listing? published;
  final UiMessage? message;

  const CreateListingState({
    required this.hub,
    this.step = 0,
    this.photos = 0,
    this.title = '',
    this.priceText = '',
    this.category,
    this.showErrors = false,
    this.publishing = false,
    this.published,
    this.message,
  });

  int get priceValue =>
      int.tryParse(priceText.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
  bool get essentialsValid =>
      photos > 0 &&
      title.trim().isNotEmpty &&
      priceValue > 0 &&
      category != null;

  String? get photoError =>
      showErrors && photos == 0 ? 'Add at least one photo' : null;
  String? get titleError =>
      showErrors && title.trim().isEmpty ? 'Enter a title' : null;
  String? get priceError =>
      showErrors && priceValue <= 0 ? 'Enter a price in RWF' : null;
  String? get categoryError =>
      showErrors && category == null ? 'Choose a category' : null;

  CreateListingState copyWith({
    int? step,
    int? photos,
    String? title,
    String? priceText,
    String? category,
    String? hub,
    bool? showErrors,
    bool? publishing,
    Listing? published,
    UiMessage? message,
  }) =>
      CreateListingState(
        step: step ?? this.step,
        photos: photos ?? this.photos,
        title: title ?? this.title,
        priceText: priceText ?? this.priceText,
        category: category ?? this.category,
        hub: hub ?? this.hub,
        showErrors: showErrors ?? this.showErrors,
        publishing: publishing ?? this.publishing,
        published: published ?? this.published,
        message: message,
      );

  @override
  List<Object?> get props => [
        step,
        photos,
        title,
        priceText,
        category,
        hub,
        showErrors,
        publishing,
        published,
        message
      ];
}

/// Three-step "Create listing" form. All form state lives here, not in the widget.
class CreateListingCubit extends Cubit<CreateListingState> {
  CreateListingCubit(this._repo, this._user, String defaultHub)
      : super(CreateListingState(hub: defaultHub));
  final ListingRepository _repo;
  final AppUser _user;

  void setTitle(String v) => emit(state.copyWith(title: v));
  void setPrice(String v) => emit(state.copyWith(priceText: v));
  void setCategory(String? v) => emit(state.copyWith(category: v));
  void setHub(String v) => emit(state.copyWith(hub: v));

  /// This is a placeholder for image_picker. We need to replace this photo counter (max 5) with real photo picking and upload.
  void addPhoto() =>
      emit(state.copyWith(photos: state.photos >= 5 ? 5 : state.photos + 1));
  void clearPhotos() => emit(state.copyWith(photos: 0));

  void next() {
    if (state.step == 0) {
      if (!state.essentialsValid) {
        emit(state.copyWith(showErrors: true));
        return;
      }
      emit(state.copyWith(step: 1));
    } else if (state.step == 1) {
      emit(state.copyWith(step: 2));
    } else {
      publish();
    }
  }

  /// Returns false when already on the first step (caller should leave the screen).
  bool back() {
    if (state.step == 0) return false;
    emit(state.copyWith(step: state.step - 1));
    return true;
  }

  Future<void> publish() async {
    if (state.publishing) return;
    emit(state.copyWith(publishing: true));
    try {
      final listing = await _repo.create(
        sellerId: _user.uid,
        sellerName: _user.shownName,
        title: state.title.trim(),
        category: state.category!,
        hub: state.hub,
        price: state.priceValue,
        photoCount: state.photos,
      );
      emit(state.copyWith(publishing: false, published: listing));
    } on AppException catch (e) {
      emit(state.copyWith(
          publishing: false, message: UiMessage.error(e.message)));
    }
  }
}
