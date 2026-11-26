import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/tokens.dart';
import '../../../../core/ui/ui_message.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets.dart';
import '../../../messages/presentation/cubit/conversations_cubit.dart';
import '../../../messages/presentation/pages/chat_screen.dart';
import '../../domain/entities/listing.dart';
import '../widgets/listing_photos.dart';
import '../cubit/browse_cubit.dart';
import 'create_listing_screen.dart';

class BrowseScreen extends StatelessWidget {
  const BrowseScreen({super.key});

  Future<void> _message(BuildContext context, Listing l) async {
    final id = await context.read<ConversationsCubit>().startChat(l);
    if (id != null && context.mounted) {
      Navigator.of(context).push(ChatScreen.route(context, id));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<BrowseCubit, BrowseState>(
      listenWhen: (p, c) => p.message != c.message && c.message != null,
      listener: (context, s) => showUiMessage(context, s.message!),
      builder: (context, s) {
        final items = s.visible;
        return Scaffold(
          appBar: AppBar(
            title: const Text('Marketplace'),
            bottom: const PreferredSize(
                preferredSize: Size.fromHeight(1),
                child: Divider(height: 1, color: C.border)),
          ),
          body: s.loading
              ? const Center(child: CircularProgressIndicator())
              : items.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child:
                            Column(mainAxisSize: MainAxisSize.min, children: [
                          const Text('No listings from other students yet',
                              style: T.bodySlate),
                          const SizedBox(height: 16),
                          SecondaryButton('Post a listing',
                              onPressed: () => Navigator.of(context)
                                  .push(CreateListingScreen.route(context))),
                        ]),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: items.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, i) {
                        final l = items[i];
                        return SurfaceCard(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ListingPhotos(photos: l.photos),
                                const SizedBox(height: 12),
                                Row(children: [
                                  Expanded(
                                      child: Text(l.title,
                                          style: T.h1.copyWith(fontSize: 18))),
                                  Pill(l.category),
                                ]),
                                const SizedBox(height: 6),
                                Text(rwf(l.price), style: T.body),
                                const SizedBox(height: 4),
                                Text('${l.sellerName} · ${l.hub}',
                                    style: T.caption),
                                const SizedBox(height: 12),
                                SecondaryButton('Message seller',
                                    onPressed: () => _message(context, l)),
                              ]),
                        );
                      },
                    ),
        );
      },
    );
  }
}
