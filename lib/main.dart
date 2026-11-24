import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/tokens.dart';
import 'core/ui/nav_cubit.dart';
import 'core/ui/session_binder.dart';
import 'core/widgets.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/pages/auth_gate.dart';
import 'features/listings/data/repositories/listing_repository_impl.dart';
import 'features/listings/domain/repositories/listing_repository.dart';
import 'features/listings/presentation/cubit/browse_cubit.dart';
import 'features/listings/presentation/cubit/my_listings_cubit.dart';
import 'features/listings/presentation/cubit/search_cubit.dart';
import 'features/listings/presentation/pages/browse_screen.dart';
import 'features/listings/presentation/pages/create_listing_screen.dart';
import 'features/listings/presentation/pages/search_screen.dart';
import 'features/messages/data/repositories/messages_repository_impl.dart';
import 'features/messages/domain/repositories/messages_repository.dart';
import 'features/messages/presentation/cubit/conversations_cubit.dart';
import 'features/messages/presentation/pages/messages_screen.dart';
import 'features/profile/data/repositories/profile_repository_impl.dart';
import 'features/profile/domain/repositories/profile_repository.dart';
import 'features/profile/presentation/cubit/profile_cubit.dart';
import 'features/profile/presentation/pages/profile_screen.dart';
import 'features/settings/data/repositories/shared_prefs_settings_repository.dart';
import 'features/settings/domain/repositories/settings_repository.dart';
import 'features/settings/presentation/cubit/settings_cubit.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Android reads android/app/google-services.json (see AUTH_SETUP.md). The web
  // build has no such file, so it needs explicit options.
  await Firebase.initializeApp(
    options: kIsWeb ? DefaultFirebaseOptions.web : null,
  );
  // Load saved preferences before the first frame so there is no flash of defaults.
  final prefs = await SharedPreferences.getInstance();
  runApp(MarketApp(settings: SharedPrefsSettingsRepository(prefs)));
}

class MarketApp extends StatelessWidget {
  final SettingsRepository settings;
  const MarketApp({super.key, required this.settings});

  @override
  Widget build(BuildContext context) {
    final db = FirebaseFirestore.instance;
    final listings = ListingRepositoryImpl(db);
    final messages = MessagesRepositoryImpl(db);
    final profiles = ProfileRepositoryImpl(db);

    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<ListingRepository>.value(value: listings),
        RepositoryProvider<MessagesRepository>.value(value: messages),
        RepositoryProvider<ProfileRepository>.value(value: profiles),
      ],
      child: BlocProvider(
        create: (_) => AuthBloc(AuthRepositoryImpl())..add(const AuthStarted()),
        child: MaterialApp(
          title: 'ALU Market',
          debugShowCheckedModeBanner: false,
          theme: appTheme(),
          // Providers sit above the Navigator so every pushed route can use them.
          builder: (context, child) => MultiBlocProvider(
            providers: [
              BlocProvider(create: (_) => SettingsCubit(settings)),
              BlocProvider(create: (_) => NavCubit()),
              BlocProvider(create: (_) => MyListingsCubit(listings)),
              BlocProvider(create: (_) => BrowseCubit(listings)),
              BlocProvider(create: (_) => SearchCubit(listings)),
              BlocProvider(create: (_) => ConversationsCubit(messages)),
              BlocProvider(create: (_) => ProfileCubit(profiles)),
            ],
            child: Builder(builder: (context) {
              final factor =
                  context.select((SettingsCubit c) => c.state.textSize.factor);
              final mq = MediaQuery.of(context);
              return MediaQuery(
                data: mq.copyWith(
                    textScaler:
                        TextScaler.linear(mq.textScaler.scale(1) * factor)),
                child: SessionBinder(child: child!),
              );
            }),
          ),
          home: const AuthGate(signedIn: Shell()),
        ),
      ),
    );
  }
}

/// Bottom-navigation shell. Sell opens as a full flow on top of the shell.
class Shell extends StatelessWidget {
  const Shell({super.key});

  @override
  Widget build(BuildContext context) {
    final unread =
        context.select((ConversationsCubit c) => c.state.unreadCount);
    final showBadge =
        context.select((SettingsCubit c) => c.state.showUnreadBadge);
    return BlocBuilder<NavCubit, int>(
      builder: (context, i) => Scaffold(
        body: IndexedStack(index: i, children: const [
          BrowseScreen(),
          SearchScreen(),
          SizedBox.shrink(),
          MessagesScreen(),
          ProfileScreen(),
        ]),
        bottomNavigationBar: AppBottomNav(
          index: i,
          badges: showBadge ? {3: unread} : const {},
          onTap: (n) {
            if (n == 2) {
              Navigator.of(context).push(CreateListingScreen.route(context));
            } else {
              context.read<NavCubit>().setTab(n);
            }
          },
        ),
      ),
    );
  }
}
