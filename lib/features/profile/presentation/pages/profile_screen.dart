import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/hubs.dart';
import '../../../../core/tokens.dart';
import '../../../../core/ui/ui_message.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../listings/domain/entities/listing.dart';
import '../../../listings/presentation/cubit/my_listings_cubit.dart';
import '../../../settings/presentation/pages/settings_screen.dart';
import '../cubit/profile_cubit.dart';
import 'edit_listing_dialog.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  void _pickHub(BuildContext context) {
    final cubit = context.read<ProfileCubit>();
    final current = cubit.state.profile?.hub;
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: C.white,
      builder: (ctx) => SafeArea(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Padding(
              padding: EdgeInsets.all(16),
              child: Text('Trade Hub settings', style: T.h1)),
          for (final h in campusHubs.entries)
            ListTile(
              title: Text(h.key, style: T.body),
              subtitle: Text(h.value, style: T.caption),
              trailing: Icon(
                  current == h.key
                      ? Icons.radio_button_checked
                      : Icons.radio_button_off,
                  color: current == h.key ? C.orange : C.inputBorder),
              onTap: () {
                cubit.updateHub(h.key);
                Navigator.pop(ctx);
              },
            ),
          const SizedBox(height: 8),
        ]),
      ),
    );
  }

  Future<void> _edit(BuildContext context, Listing l) async {
    final cubit = context.read<MyListingsCubit>();
    final result = await showDialog<EditListingResult>(
      context: context,
      builder: (_) => EditListingDialog(listing: l),
    );
    if (result != null)
      cubit.edit(l.id, title: result.title, price: result.price);
  }

  Future<void> _delete(BuildContext context, Listing l) async {
    final cubit = context.read<MyListingsCubit>();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: C.white,
        title: const Text('Delete listing?', style: T.h1),
        content: Text('"${l.title}" will be removed permanently.',
            style: T.bodySlate),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Delete', style: T.body.copyWith(color: C.red)),
          ),
        ],
      ),
    );
    if (ok == true) cubit.remove(l.id);
  }

  @override
  Widget build(BuildContext context) {
    final email = context.select((AuthBloc b) => b.state.user?.email ?? '');
    return MultiBlocListener(
      listeners: [
        BlocListener<ProfileCubit, ProfileState>(
          listenWhen: (p, c) => p.message != c.message && c.message != null,
          listener: (context, s) => showUiMessage(context, s.message!),
        ),
        BlocListener<MyListingsCubit, MyListingsState>(
          listenWhen: (p, c) => p.message != c.message && c.message != null,
          listener: (context, s) => showUiMessage(context, s.message!),
        ),
      ],
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Profile and My Listings'),
          bottom: const PreferredSize(
              preferredSize: Size.fromHeight(1),
              child: Divider(height: 1, color: C.border)),
        ),
        body: BlocBuilder<ProfileCubit, ProfileState>(
          builder: (context, ps) {
            final p = ps.profile;
            final name = p?.name ?? '';
            return ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              children: [
                Row(children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                        color: C.orangeTint,
                        borderRadius: BorderRadius.circular(14)),
                    alignment: Alignment.center,
                    child: Text(name.isEmpty ? '?' : name[0].toUpperCase(),
                        style: T.h1),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(name, style: T.display),
                          Text('${p?.year ?? ''} · ALU Kigali',
                              style: T.caption),
                        ]),
                  ),
                ]),
                const SizedBox(height: 12),
                const Row(children: [Pill('Verified student')]),
                const SizedBox(height: 8),
                Text(email, style: T.caption),
                const SizedBox(height: 12),
                TrustCard(
                  'Your Trade Hub',
                  '${p?.hub ?? defaultHub} · ${campusHubs[p?.hub] ?? ''}',
                  onTap: () => _pickHub(context),
                ),
                const SizedBox(height: 20),
                const Text('My Listings', style: T.h1),
                const SizedBox(height: 10),
                BlocBuilder<MyListingsCubit, MyListingsState>(
                    builder: (context, ls) => _listings(context, ls)),
                const SizedBox(height: 16),
                SecondaryButton(
                  'Settings',
                  onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => const SettingsScreen())),
                ),
                const SizedBox(height: 10),
                SecondaryButton(
                  'Log out',
                  onPressed: () =>
                      context.read<AuthBloc>().add(const AuthLogoutRequested()),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _listings(BuildContext context, MyListingsState s) {
    final cubit = context.read<MyListingsCubit>();
    final active = s.active;
    final sold = s.sold;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Pill('Active · ${active.length}',
            selected: s.filter == ListingFilter.active,
            orange: s.filter == ListingFilter.all,
            onTap: () => cubit.toggleFilter(ListingFilter.active)),
        const SizedBox(width: 8),
        Pill('Sold · ${sold.length}',
            selected: s.filter == ListingFilter.sold,
            onTap: () => cubit.toggleFilter(ListingFilter.sold)),
      ]),
      const SizedBox(height: 12),
      if (s.loading) const Center(child: CircularProgressIndicator()),
      if (s.filter != ListingFilter.sold) ...[
        if (!s.loading && active.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Text('No active listings. Tap Sell to post one.',
                style: T.bodySlate),
          ),
        for (final l in active) ...[
          _card(context, l),
          const SizedBox(height: 10)
        ],
      ],
      if (s.filter != ListingFilter.active && sold.isNotEmpty) ...[
        const SizedBox(height: 6),
        const Text('Sold listings', style: T.h1),
        const SizedBox(height: 10),
        for (final l in sold) ...[
          _card(context, l),
          const SizedBox(height: 10)
        ],
      ],
    ]);
  }

  Widget _card(BuildContext context, Listing l) => SurfaceCard(
        padding: const EdgeInsets.fromLTRB(16, 12, 4, 12),
        child: Row(children: [
          Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(l.title, style: T.h1.copyWith(fontSize: 18)),
              const SizedBox(height: 6),
              Text(rwf(l.price), style: T.body),
              const SizedBox(height: 4),
              Text(
                l.sold
                    ? 'Sold to ${l.soldToName} · ${formatWhen(l.soldAt)}'
                    : 'Active · ${l.hub}',
                style: T.caption,
              ),
            ]),
          ),
          if (!l.sold)
            IconButton(
              tooltip: 'Edit listing',
              icon: const Icon(Icons.edit_outlined, color: C.slate),
              onPressed: () => _edit(context, l),
            ),
          IconButton(
            tooltip: 'Delete listing',
            icon: const Icon(Icons.delete_outline, color: C.red),
            onPressed: () => _delete(context, l),
          ),
        ]),
      );
}
