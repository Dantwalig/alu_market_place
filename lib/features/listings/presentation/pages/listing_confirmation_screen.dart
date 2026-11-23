import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/tokens.dart';
import '../../../../core/ui/nav_cubit.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets.dart';
import '../../domain/entities/listing.dart';

class ListingConfirmationScreen extends StatelessWidget {
  final Listing listing;
  const ListingConfirmationScreen({super.key, required this.listing});

  void _goToListings(BuildContext context) {
    context.read<NavCubit>().setTab(4); // Profile tab shows My Listings
    Navigator.of(context).popUntil((r) => r.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => _goToListings(context)),
        title: const Text('Listing Confirmation'),
        bottom: const PreferredSize(
            preferredSize: Size.fromHeight(1),
            child: Divider(height: 1, color: C.border)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const SurfaceCard(
              color: C.white,
              borderColor: C.green,
              padding: EdgeInsets.all(12),
              child: Row(children: [
                Icon(Icons.info_outline, size: 18, color: C.green),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                      'Your listing is published and visible to verified students.',
                      style: T.caption),
                ),
              ]),
            ),
            const SizedBox(height: 16),
            Text('Your ${listing.title.toLowerCase()} is live!', style: T.h1),
            const SizedBox(height: 8),
            Text(
                '${listing.sellerName}, your ${listing.title.toLowerCase()} is now available in your Trade Hub.',
                style: T.bodySlate),
            const SizedBox(height: 16),
            Container(
              height: 120,
              width: double.infinity,
              decoration: BoxDecoration(
                  color: C.surface, borderRadius: BorderRadius.circular(12)),
              child: const Icon(Icons.photo_outlined,
                  size: 44, color: C.inputBorder),
            ),
            const SizedBox(height: 12),
            SurfaceCard(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(listing.title, style: T.label),
                    const SizedBox(height: 4),
                    Text(rwf(listing.price), style: T.bodySlate),
                    const SizedBox(height: 2),
                    Text('${listing.sellerName} · Verified · ${listing.hub}',
                        style: T.caption),
                  ]),
            ),
            const SizedBox(height: 12),
            TrustCard('Published listing details',
                '${listing.category}\nSeller: ${listing.sellerName}\nMeetup: ${listing.hub}'),
            const SizedBox(height: 12),
            const Text(
                'You’ll receive enquiries in Messages. Mark as sold only after the handoff.',
                style: T.caption),
            const SizedBox(height: 16),
            PrimaryButton('View My Listings',
                onPressed: () => _goToListings(context)),
          ]),
        ),
      ),
    );
  }
}
