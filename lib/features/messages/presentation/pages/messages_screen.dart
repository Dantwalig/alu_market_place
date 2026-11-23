import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/tokens.dart';
import '../../../../core/ui/ui_message.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../cubit/conversations_cubit.dart';
import 'chat_screen.dart';
import 'offline_screen.dart';

/// Shows the No Internet screen when the Firestore stream fails.
class MessagesScreen extends StatefulWidget {
  const MessagesScreen({super.key});
  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

/// StatefulWidget only to own and dispose the search controller.
class _MessagesScreenState extends State<MessagesScreen> {
  final _search = TextEditingController();

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ConversationsCubit>();
    final name = context.select((AuthBloc b) => b.state.user?.shownName ?? '');
    return BlocConsumer<ConversationsCubit, ConversationsState>(
      listenWhen: (p, c) => p.message != c.message && c.message != null,
      listener: (context, s) => showUiMessage(context, s.message!),
      builder: (context, s) {
        final items = s.visible;
        return Scaffold(
          appBar: AppBar(
            title: const Text('Messages'),
            bottom: const PreferredSize(
                preferredSize: Size.fromHeight(1),
                child: Divider(height: 1, color: C.border)),
          ),
          body: s.offline
              ? OfflineScreen(onRetry: cubit.retry)
              : ListView(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                  children: [
                    const Text('Your conversations', style: T.h1),
                    const SizedBox(height: 4),
                    Text(name, style: T.caption),
                    const SizedBox(height: 14),
                    TextField(
                      controller: _search,
                      onChanged: cubit.setQuery,
                      style: T.body,
                      decoration: InputDecoration(
                        hintText: 'Search messages',
                        hintStyle: T.bodySlate,
                        prefixIcon: const Icon(Icons.search, color: C.slate),
                        contentPadding:
                            const EdgeInsets.symmetric(vertical: 14),
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
                    Row(children: [
                      Pill('All messages',
                          selected: !s.unreadOnly,
                          onTap: () => cubit.setUnreadOnly(false)),
                      const SizedBox(width: 8),
                      Pill('Unread · ${s.unreadCount}',
                          selected: s.unreadOnly,
                          onTap: () => cubit.setUnreadOnly(true)),
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
                            child: Text('No conversations found',
                                style: T.bodySlate)),
                      ),
                    for (final c in items) ...[
                      SurfaceCard(
                        onTap: () => Navigator.of(context)
                            .push(ChatScreen.route(context, c.id)),
                        child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.shield_outlined,
                                  size: 18, color: C.slate),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(c.otherName(s.uid!), style: T.h2),
                                      const SizedBox(height: 4),
                                      Text(c.listingTitle, style: T.caption),
                                      Text(
                                          c.lastMessage.isEmpty
                                              ? 'Say hello'
                                              : c.lastMessage,
                                          style: T.caption),
                                    ]),
                              ),
                              if (c.isUnreadFor(s.uid!))
                                Container(
                                  width: 8,
                                  height: 8,
                                  margin: const EdgeInsets.only(top: 4),
                                  decoration: const BoxDecoration(
                                      color: C.orange, shape: BoxShape.circle),
                                ),
                            ]),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(2, 6, 0, 12),
                        child:
                            Text(formatWhen(c.lastMessageAt), style: T.caption),
                      ),
                    ],
                  ],
                ),
        );
      },
    );
  }
}
