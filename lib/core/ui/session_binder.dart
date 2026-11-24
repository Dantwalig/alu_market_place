import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../features/auth/domain/entities/app_user.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/listings/presentation/cubit/browse_cubit.dart';
import '../../features/listings/presentation/cubit/my_listings_cubit.dart';
import '../../features/listings/presentation/cubit/search_cubit.dart';
import '../../features/messages/presentation/cubit/conversations_cubit.dart';
import '../../features/profile/presentation/cubit/profile_cubit.dart';
import 'nav_cubit.dart';

/// Connects the data cubits to the signed-in user. When the user signs in
/// (and is verified) the cubits start their Firestore streams; on sign-out
/// they stop and clear, so one account's data never leaks into the next.
class SessionBinder extends StatelessWidget {
  final Widget child;
  const SessionBinder({super.key, required this.child});

  static AppUser? _active(AuthState s) =>
      s.status == AuthStatus.authenticated && !s.needsVerification
          ? s.user
          : null;

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listenWhen: (p, c) => _active(p)?.uid != _active(c)?.uid,
      listener: (context, state) {
        final user = _active(state);
        context.read<MyListingsCubit>().bind(user);
        context.read<BrowseCubit>().bind(user);
        context.read<SearchCubit>().bind(user);
        context.read<ConversationsCubit>().bind(user);
        context.read<ProfileCubit>().bind(user);
        if (user == null) context.read<NavCubit>().setTab(0);
      },
      child: child,
    );
  }
}
