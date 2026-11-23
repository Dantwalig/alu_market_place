import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/tokens.dart';
import '../../../../core/ui/ui_message.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../listings/domain/repositories/listing_repository.dart';
import '../../domain/entities/message.dart';
import '../../domain/repositories/messages_repository.dart';
import '../cubit/chat_cubit.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  static Route<void> route(BuildContext context, String conversationId) {
    final messages = context.read<MessagesRepository>();
    final listings = context.read<ListingRepository>();
    final me = context.read<AuthBloc>().state.user!;
    return MaterialPageRoute(
      builder: (_) => BlocProvider(
        create: (_) =>
            ChatCubit(messages, listings, me, conversationId)..start(),
        child: const ChatScreen(),
      ),
    );
  }

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

/// StatefulWidget only to own and dispose the input and scroll controllers.
class _ChatScreenState extends State<ChatScreen> {
  final _input = TextEditingController();
  final _scroll = ScrollController();

  @override
  void dispose() {
    _input.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _send() {
    final text = _input.text;
    if (text.trim().isEmpty) return;
    context.read<ChatCubit>().send(text);
    _input.clear();
  }

  void _scrollToEnd() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.animateTo(_scroll.position.maxScrollExtent + 80,
            duration: const Duration(milliseconds: 200), curve: Curves.easeOut);
      }
    });
  }

  Future<void> _confirmSold(BuildContext context, String title) async {
    final cubit = context.read<ChatCubit>();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: C.white,
        title: const Text('Mark as sold?', style: T.h1),
        content: Text(
          'Only mark ${title.toLowerCase()} as sold after the handoff at the hub. It will be removed from search.',
          style: T.bodySlate,
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Not yet')),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Mark as Sold')),
        ],
      ),
    );
    if (ok == true) cubit.markSold();
  }

  Future<void> _report(BuildContext context) async {
    const reasons = [
      'Suspicious behaviour',
      'Asking to pay outside the hub',
      'Fake listing',
      'Harassment'
    ];
    final cubit = context.read<ChatCubit>();
    final r = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: C.white,
      builder: (ctx) => SafeArea(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Padding(
              padding: EdgeInsets.all(16),
              child: Text('Report this user', style: T.h1)),
          for (final x in reasons)
            ListTile(
                title: Text(x, style: T.body),
                onTap: () => Navigator.pop(ctx, x)),
          const SizedBox(height: 8),
        ]),
      ),
    );
    if (r != null) cubit.report(r);
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ChatCubit>();
    final me = cubit.me.uid;
    return BlocConsumer<ChatCubit, ChatState>(
      listenWhen: (p, c) =>
          p.message != c.message || p.messages.length != c.messages.length,
      listener: (context, s) {
        if (s.message != null) showUiMessage(context, s.message!);
        _scrollToEnd();
      },
      builder: (context, s) {
        final conv = s.conversation;
        final listing = s.listing;
        final isSeller = conv?.sellerId == me;
        return Scaffold(
          appBar: AppBar(
            title: Text(conv?.otherName(me) ?? 'Chat'),
            actions: [
              PopupMenuButton<String>(
                onSelected: (v) => v == 'report' ? _report(context) : null,
                itemBuilder: (_) => const [
                  PopupMenuItem(value: 'report', child: Text('Report user'))
                ],
              ),
            ],
            bottom: const PreferredSize(
                preferredSize: Size.fromHeight(1),
                child: Divider(height: 1, color: C.border)),
          ),
          body: SafeArea(
            child: Column(children: [
              Expanded(
                child: ListView(
                  controller: _scroll,
                  padding: const EdgeInsets.all(16),
                  children: [
                    if (listing != null)
                      TrustCard(
                        '${listing.title} · ${rwf(listing.price)}',
                        '${isSeller ? 'Your listing' : 'Listing by ${listing.sellerName}'} · ${s.sold ? 'Sold' : 'Active'}',
                      ),
                    const SizedBox(height: 10),
                    for (final m in s.messages)
                      _bubble(context, m, m.senderId == me),
                    if (conv?.meetup != null) ...[
                      const SizedBox(height: 6),
                      TrustCard(listing?.hub ?? 'Meetup', conv!.meetup!),
                    ],
                    if (s.sold) ...[
                      const SizedBox(height: 10),
                      SurfaceCard(
                        color: C.orangeTint,
                        borderColor: C.orange,
                        child: Row(children: [
                          const Icon(Icons.info_outline,
                              size: 18, color: C.orange),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                                'SOLD · This item is no longer available',
                                style: T.caption.copyWith(color: C.navy)),
                          ),
                        ]),
                      ),
                    ],
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
                child: Column(children: [
                  if (isSeller && listing != null && !s.sold) ...[
                    conv?.meetup == null
                        ? SecondaryButton('Confirm meetup at ${listing.hub}',
                            onPressed: cubit.confirmMeetup)
                        : PrimaryButton('Mark as Sold',
                            onPressed: () =>
                                _confirmSold(context, listing.title)),
                    const SizedBox(height: 10),
                  ],
                  TextField(
                    controller: _input,
                    onSubmitted: (_) => _send(),
                    style: T.body,
                    decoration: InputDecoration(
                      hintText: 'Write a message...',
                      hintStyle: T.bodySlate,
                      suffixIcon: IconButton(
                        tooltip: 'Send',
                        icon: const Icon(Icons.send, color: C.navy),
                        onPressed: _send,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: C.inputBorder)),
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              const BorderSide(color: C.orange, width: 1.5)),
                    ),
                  ),
                ]),
              ),
            ]),
          ),
        );
      },
    );
  }

  Widget _bubble(BuildContext context, Message m, bool mine) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Column(
          crossAxisAlignment:
              mine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Container(
              constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.72),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: mine ? C.navy : const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(m.text,
                  style: T.body.copyWith(color: mine ? C.white : C.navy)),
            ),
            const SizedBox(height: 3),
            Text(formatClock(m.createdAt), style: T.caption),
          ],
        ),
      );
}
