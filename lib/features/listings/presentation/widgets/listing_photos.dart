import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../../core/tokens.dart';

/// Shows a listing's photos. With [swipeable] false only the cover is shown,
/// which is what the list cards use. With [swipeable] true the photos can be
/// swiped through. Listings without photos get a neutral placeholder.
class ListingPhotos extends StatefulWidget {
  const ListingPhotos({
    super.key,
    required this.photos,
    this.height = 160,
    this.swipeable = false,
  });

  final List<String> photos;
  final double height;
  final bool swipeable;

  @override
  State<ListingPhotos> createState() => _ListingPhotosState();
}

class _ListingPhotosState extends State<ListingPhotos> {
  late List<Uint8List> _bytes = _decode(widget.photos);
  int _page = 0;

  static List<Uint8List> _decode(List<String> photos) {
    final out = <Uint8List>[];
    for (final p in photos) {
      try {
        out.add(base64Decode(p));
      } catch (_) {
        // Skip a photo that cannot be decoded instead of breaking the card.
      }
    }
    return out;
  }

  @override
  void didUpdateWidget(covariant ListingPhotos old) {
    super.didUpdateWidget(old);
    if (!listEquals(old.photos, widget.photos)) {
      _bytes = _decode(widget.photos);
      _page = 0;
    }
  }

  Widget _image(Uint8List b) => Image.memory(
        b,
        fit: BoxFit.cover,
        width: double.infinity,
        height: widget.height,
        gaplessPlayback: true,
        errorBuilder: (_, __, ___) => _placeholder(),
      );

  Widget _placeholder() => Container(
        height: widget.height,
        width: double.infinity,
        color: C.surface,
        child: const Icon(Icons.photo_outlined, size: 44, color: C.inputBorder),
      );

  @override
  Widget build(BuildContext context) {
    final Widget content;
    if (_bytes.isEmpty) {
      content = _placeholder();
    } else if (!widget.swipeable || _bytes.length == 1) {
      content = _image(_bytes.first);
    } else {
      content = SizedBox(
        height: widget.height,
        child: Stack(children: [
          PageView.builder(
            itemCount: _bytes.length,
            onPageChanged: (i) => setState(() => _page = i),
            itemBuilder: (_, i) => _image(_bytes[i]),
          ),
          Positioned(
            right: 8,
            bottom: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                  color: C.navy.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(10)),
              child: Text('${_page + 1} / ${_bytes.length}',
                  style: T.caption.copyWith(color: C.white)),
            ),
          ),
        ]),
      );
    }
    return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: SizedBox(height: widget.height, child: content));
  }
}
