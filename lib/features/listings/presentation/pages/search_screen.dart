import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/hubs.dart';
import '../../../../core/tokens.dart';
import '../../../../core/ui/ui_message.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets.dart';
import '../../../messages/presentation/cubit/conversations_cubit.dart';
import '../../../messages/presentation/pages/chat_screen.dart';
import '../../domain/entities/listing.dart';
import '../cubit/search_cubit.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  Future<void> _message(BuildContext context, Listing l) async {
    final id = await context.read<ConversationsCubit>().startChat(l);
    if (id != null && context.mounted) {
      Navigator.of(context).push(ChatScreen.route(context, id));
    }
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<SearchCubit>();
    return BlocConsumer<SearchCubit, SearchState>(
      listenWhen: (p, c) => p.message != c.message && c.message != null,
      listener: (context, s) => showUiMessage(context, s.message!),
      builder: (context, s) {
        final items = s.results;
        return Scaffold(
          appBar: AppBar(
            title: const Text('Search'),
            bottom: const PreferredSize(
                preferredSize: Size.fromHeight(1),
                child: Divider(height: 1, color: C.border)),
          ),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            children: [
              TextField(
                onChanged: cubit.setQuery,
                style: T.body,
                decoration: InputDecoration(
                  hintText: 'Search listings',
                  hintStyle: T.bodySlate,
                  prefixIcon: const Icon(Icons.search, color: C.slate),
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: C.inputBorder)),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          const BorderSide(color: C.orange, width: 1.5)),
                ),
              ),
              const SizedBox(height: 12),
              Wrap(spacing: 8, runSpacing: 8, children: [
                for (final c in listingCategories)
                  Pill(c,
                      selected: s.category == c,
                      onTap: () => cubit.toggleCategory(c)),
              ]),
              const SizedBox(height: 14),
              if (s.loading)
                const Padding(
                    padding: EdgeInsets.only(top: 40),
                    child: Center(child: CircularProgressIndicator()))
              else if (items.isEmpty)
                const Padding(
                    padding: EdgeInsets.only(top: 40),
                    child: Center(
                        child:
                            Text('No matching listings', style: T.bodySlate)))
              else
                for (final l in items) ...[
                  SurfaceCard(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(children: [
                            Expanded(
                                child: Text(l.title,
                                    style: T.h1.copyWith(fontSize: 18))),
                            Pill(l.category),
                          ]),
                          const SizedBox(height: 6),
                          Text(rwf(l.price), style: T.body),
                          const SizedBox(height: 4),
                          Text('${l.sellerName} · ${l.hub}', style: T.caption),
                          const SizedBox(height: 12),
                          SecondaryButton('Message seller',
                              onPressed: () => _message(context, l)),
                        ]),
                  ),
                  const SizedBox(height: 12),
                ],
            ],
          ),
        );
      },
    );
  }
}
