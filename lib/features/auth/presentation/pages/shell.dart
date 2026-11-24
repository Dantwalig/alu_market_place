import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/ui/nav_cubit.dart';
import '../../../../core/widgets.dart';
import '../../../../features/listings/presentation/pages/browse_screen.dart';
import '../../../../features/listings/presentation/pages/create_listing_screen.dart';
import '../../../../features/listings/presentation/pages/search_screen.dart';
import '../../../../features/messages/presentation/cubit/conversations_cubit.dart';
import '../../../../features/messages/presentation/pages/messages_screen.dart';
import '../../../../features/profile/presentation/pages/profile_screen.dart';
import '../../../../features/settings/presentation/cubit/settings_cubit.dart';
import '../bloc/auth_bloc.dart';

/// Bottom-navigation shell shown after sign in.
class Shell extends StatelessWidget {
  const Shell({super.key});

  @override
  Widget build(BuildContext context) {
    final unread =
        context.select((ConversationsCubit c) => c.state.unreadCount);
    final showBadge =
        context.select((SettingsCubit c) => c.state.showUnreadBadge);
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        return BlocBuilder<NavCubit, int>(
          builder: (context, i) => Scaffold(
            body: IndexedStack(index: i, children: [
              BrowseScreen(),
              SearchScreen(),
              const SizedBox.shrink(),
              MessagesScreen(),
              ProfileScreen(),
            ]),
            bottomNavigationBar: AppBottomNav(
              index: i,
              badges: showBadge ? {3: unread} : const {},
              onTap: (n) {
                if (n == 2) {
                  Navigator.of(context)
                      .push(CreateListingScreen.route(context));
                } else {
                  context.read<NavCubit>().setTab(n);
                }
              },
            ),
          ),
        );
      },
    );
  }
}
