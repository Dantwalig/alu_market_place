import 'package:flutter/material.dart';

import '../../../../core/tokens.dart';

/// Cover photo for a listing card. Shows a neutral placeholder while loading,
/// when the listing has no image, or if the image fails to load.
class ListingImage extends StatelessWidget {
  const ListingImage(this.url, {super.key});

  final String? url;

  Widget _placeholder() => Container(
        color: C.surface,
        alignment: Alignment.center,
        child: const Icon(Icons.photo_outlined, color: C.slate, size: 32),
      );

  @override
  Widget build(BuildContext context) {
    final u = url;
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: (u == null || u.isEmpty)
            ? _placeholder()
            : Image.network(
                u,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, progress) =>
                    progress == null ? child : _placeholder(),
                errorBuilder: (_, __, ___) => _placeholder(),
              ),
      ),
    );
  }
}
