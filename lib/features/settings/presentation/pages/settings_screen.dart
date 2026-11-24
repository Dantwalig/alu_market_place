import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/tokens.dart';
import '../../../../core/widgets.dart';
import '../../domain/entities/app_settings.dart';
import '../cubit/settings_cubit.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<SettingsCubit>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        bottom: const PreferredSize(
            preferredSize: Size.fromHeight(1),
            child: Divider(height: 1, color: C.border)),
      ),
      body: BlocBuilder<SettingsCubit, AppSettings>(
        builder: (context, s) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text('Text size', style: T.h1),
            const SizedBox(height: 4),
            const Text('Makes text across the app smaller or larger.',
                style: T.caption),
            const SizedBox(height: 12),
            SegmentedButton<TextSize>(
              showSelectedIcon: false,
              segments: [
                for (final t in TextSize.values)
                  ButtonSegment(value: t, label: Text(t.label))
              ],
              selected: {s.textSize},
              onSelectionChanged: (sel) => cubit.setTextSize(sel.first),
            ),
            const SizedBox(height: 24),
            const Text('Messages', style: T.h1),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Unread badge', style: T.body),
              subtitle: const Text(
                  'Show the number of unread chats on the Messages tab.',
                  style: T.caption),
              value: s.showUnreadBadge,
              activeThumbColor: C.orange,
              onChanged: cubit.setShowUnreadBadge,
            ),
            const SizedBox(height: 12),
            const Text('Sign in', style: T.h1),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Remember my email', style: T.body),
              subtitle: const Text('Pre-fill your email on the login screen.',
                  style: T.caption),
              value: s.rememberEmail,
              activeThumbColor: C.orange,
              onChanged: cubit.setRememberEmail,
            ),
            const SizedBox(height: 24),
            SecondaryButton('Reset to defaults',
                onPressed: cubit.resetToDefaults),
          ],
        ),
      ),
    );
  }
}
