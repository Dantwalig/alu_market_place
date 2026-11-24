import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/hubs.dart';
import '../../../../core/tokens.dart';
import '../../../../core/ui/ui_message.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../profile/presentation/cubit/profile_cubit.dart';
import '../../domain/repositories/listing_repository.dart';
import '../cubit/create_listing_cubit.dart';
import 'listing_confirmation_screen.dart';

/// This is a placeholder for price guidance data. We need to replace these demo RWF ranges with real data.
const _guidance = {
  'Furniture': [15000, 35000],
  'Appliances': [30000, 60000],
  'Electronics': [10000, 80000],
  'Books': [2000, 10000],
  'Other': [3000, 20000],
};

class CreateListingScreen extends StatefulWidget {
  const CreateListingScreen({super.key});

  static Route<void> route(BuildContext context) {
    final repo = context.read<ListingRepository>();
    final user = context.read<AuthBloc>().state.user!;
    final hub = context.read<ProfileCubit>().state.profile?.hub ?? defaultHub;
    return MaterialPageRoute(
      builder: (_) => BlocProvider(
        create: (_) => CreateListingCubit(repo, user, hub),
        child: const CreateListingScreen(),
      ),
    );
  }

  @override
  State<CreateListingScreen> createState() => _CreateListingScreenState();
}

/// StatefulWidget only to own and dispose the text controllers.
class _CreateListingScreenState extends State<CreateListingScreen> {
  final _title = TextEditingController();
  final _price = TextEditingController();

  @override
  void dispose() {
    _title.dispose();
    _price.dispose();
    super.dispose();
  }

  void _back(BuildContext context) {
    if (!context.read<CreateListingCubit>().back()) Navigator.maybePop(context);
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<CreateListingCubit>();
    return BlocConsumer<CreateListingCubit, CreateListingState>(
      listenWhen: (p, c) =>
          p.message != c.message || p.published != c.published,
      listener: (context, s) {
        if (s.message != null) showUiMessage(context, s.message!);
        if (s.published != null) {
          Navigator.of(context).pushReplacement(MaterialPageRoute(
              builder: (_) =>
                  ListingConfirmationScreen(listing: s.published!)));
        }
      },
      builder: (context, s) {
        final incomplete = s.showErrors && !s.essentialsValid && s.step == 0;
        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => _back(context)),
            title: const Text('Create Listing'),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Center(child: Pill('Step ${s.step + 1} of 3')),
              ),
            ],
            bottom: const PreferredSize(
                preferredSize: Size.fromHeight(1),
                child: Divider(height: 1, color: C.border)),
          ),
          body: SafeArea(
            child: Column(children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: [
                    _essentials(s, cubit, incomplete),
                    _hubStep(s, cubit),
                    _review(s, context)
                  ][s.step],
                ),
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
                decoration: const BoxDecoration(
                    border: Border(top: BorderSide(color: C.border))),
                child: PrimaryButton(
                  s.publishing
                      ? 'Publishing...'
                      : (s.step == 2 ? 'Publish' : 'Continue'),
                  onPressed: s.publishing ? null : cubit.next,
                ),
              ),
            ]),
          ),
        );
      },
    );
  }

  Widget _essentials(
      CreateListingState s, CreateListingCubit cubit, bool incomplete) {
    final photoError = s.photoError;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(incomplete ? 'Complete your listing' : 'Start with the essentials',
          style: T.h1),
      const SizedBox(height: 10),
      Text(
        incomplete
            ? 'Add the missing details before publishing.'
            : 'Add your item details. You’ll set the meetup hub and review next.',
        style: T.bodySlate,
      ),
      const SizedBox(height: 20),
      const Text('PHOTOS', style: T.fieldLabel),
      const SizedBox(height: 8),
      GestureDetector(
        // This is a placeholder for the photo picker. We need to call image_picker here and upload the chosen photos.
        onTap: cubit.addPhoto,
        child: Container(
          height: 130,
          width: double.infinity,
          decoration: BoxDecoration(
            color: s.photos > 0 ? C.surface : C.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
                color: photoError != null
                    ? C.red
                    : (s.photos > 0 ? C.border : C.inputBorder)),
          ),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(
                s.photos > 0
                    ? Icons.photo_library_outlined
                    : Icons.photo_camera_outlined,
                color: C.orange,
                size: 26),
            const SizedBox(height: 8),
            Text(s.photos > 0 ? 'Add another photo' : 'Add photos',
                style: T.label),
            const SizedBox(height: 2),
            Text('${s.photos} of 5 photos', style: T.caption),
          ]),
        ),
      ),
      if (photoError != null)
        Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(photoError, style: T.caption.copyWith(color: C.red))),
      if (s.photos > 0) ...[
        const SizedBox(height: 8),
        Row(children: [
          Pill('${s.photos} of 5 photos · Cover'),
          const SizedBox(width: 8),
          TextButton(
            onPressed: cubit.clearPhotos,
            child: Text('Clear',
                style: T.caption
                    .copyWith(color: C.navy, fontWeight: FontWeight.w600)),
          ),
        ]),
      ],
      const SizedBox(height: 20),
      AppField(
        label: 'Title',
        controller: _title,
        hint: 'e.g. Single mattress',
        error: s.titleError,
        onChanged: cubit.setTitle,
      ),
      const SizedBox(height: 20),
      AppField(
        label: 'Price (RWF)',
        controller: _price,
        hint: 'Enter amount',
        error: s.priceError,
        keyboardType: TextInputType.number,
        onChanged: cubit.setPrice,
      ),
      const SizedBox(height: 20),
      const Text('CATEGORY', style: T.fieldLabel),
      const SizedBox(height: 8),
      DropdownButtonFormField<String>(
        // initialValue only seeds the field, so the key rebuilds it when the
        // cubit changes the category (for example after the form is reset).
        key: ValueKey(s.category),
        initialValue: s.category,
        isExpanded: true,
        icon: const Icon(Icons.keyboard_arrow_down, color: C.slate),
        hint: const Text('Select category', style: T.bodySlate),
        style: T.body,
        decoration: InputDecoration(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                  color: s.categoryError != null ? C.red : C.inputBorder)),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: C.orange, width: 1.5)),
        ),
        items: [
          for (final c in listingCategories)
            DropdownMenuItem(value: c, child: Text(c))
        ],
        onChanged: cubit.setCategory,
      ),
      if (s.categoryError != null)
        Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(s.categoryError!,
                style: T.caption.copyWith(color: C.red))),
      const SizedBox(height: 16),
      const SurfaceCard(
        child: Row(children: [
          Icon(Icons.info_outline, size: 18, color: C.slate),
          SizedBox(width: 10),
          Expanded(
              child: Text(
                  'All prices are in RWF. Your listing is saved when you publish.',
                  style: T.caption)),
        ]),
      ),
    ]);
  }

  Widget _hubStep(CreateListingState s, CreateListingCubit cubit) {
    final g = _guidance[s.category];
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Choose a public meetup hub', style: T.h1),
      const SizedBox(height: 10),
      const Text(
          'Handoffs happen at a public campus spot. Pick where you’ll meet buyers.',
          style: T.bodySlate),
      const SizedBox(height: 20),
      for (final h in campusHubs.entries)
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: SurfaceCard(
            color: s.hub == h.key ? C.orangeTint : C.surface,
            borderColor: s.hub == h.key ? C.orange : C.border,
            onTap: () => cubit.setHub(h.key),
            child: Row(children: [
              const Icon(Icons.shield_outlined, size: 18, color: C.slate),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(h.key, style: T.h2),
                      Text('${h.value} · Public handoff', style: T.caption),
                    ]),
              ),
              Icon(
                  s.hub == h.key
                      ? Icons.radio_button_checked
                      : Icons.radio_button_off,
                  color: s.hub == h.key ? C.orange : C.inputBorder),
            ]),
          ),
        ),
      const SizedBox(height: 10),
      if (g != null)
        SurfaceCard(
          color: C.orangeTint,
          borderColor: C.orange,
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Price guidance', style: T.h2),
            const SizedBox(height: 4),
            Text(
              'Similar ${s.category} listings go for ${rwf(g[0])} to ${rwf(g[1])}. '
              'You priced yours at ${rwf(s.priceValue)}.',
              style: T.caption.copyWith(color: C.navy),
            ),
          ]),
        ),
    ]);
  }

  Widget _review(CreateListingState s, BuildContext context) {
    final seller = context.read<AuthBloc>().state.user?.shownName ?? '';
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Review and publish', style: T.h1),
      const SizedBox(height: 10),
      const Text('Only verified students will see this listing.',
          style: T.bodySlate),
      const SizedBox(height: 20),
      SurfaceCard(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(s.title.trim(), style: T.h1.copyWith(fontSize: 18)),
          const SizedBox(height: 4),
          Text(rwf(s.priceValue), style: T.body),
          const SizedBox(height: 4),
          Text('$seller · Verified · ${s.hub}', style: T.caption),
        ]),
      ),
      const SizedBox(height: 12),
      TrustCard('Listing details',
          '${s.category} · ${s.photos} photo${s.photos == 1 ? '' : 's'}\nSeller: $seller\nMeetup: ${s.hub}'),
    ]);
  }
}
