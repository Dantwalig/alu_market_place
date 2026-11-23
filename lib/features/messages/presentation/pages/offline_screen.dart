import 'package:flutter/material.dart';
import '../../../../core/tokens.dart';
import '../../../../core/widgets.dart';

class OfflineScreen extends StatelessWidget {
  final VoidCallback onRetry;
  const OfflineScreen({super.key, required this.onRetry});
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Container(
            width: 92,
            height: 92,
            decoration: const BoxDecoration(
                color: C.orangeTint, shape: BoxShape.circle),
            child: const Icon(Icons.wifi_off, color: C.orange, size: 38),
          ),
          const SizedBox(height: 20),
          const Text('You are offline', style: T.h1),
          const SizedBox(height: 8),
          const Text('Check your connection and try again.',
              style: T.bodySlate),
          const SizedBox(height: 28),
          PrimaryButton('Try Again', onPressed: onRetry),
        ]),
      );
}
