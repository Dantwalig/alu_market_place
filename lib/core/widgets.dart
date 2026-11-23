import 'package:flutter/material.dart';
import 'tokens.dart';

class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  const PrimaryButton(this.label, {super.key, this.onPressed});
  @override
  Widget build(BuildContext context) {
    final on = onPressed != null;
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: C.navy,
          foregroundColor: C.white,
          disabledBackgroundColor: C.border,
          disabledForegroundColor: C.slate,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child:
            Text(label, style: T.label.copyWith(color: on ? C.white : C.slate)),
      ),
    );
  }
}

class SecondaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  const SecondaryButton(this.label, {super.key, this.onPressed});
  @override
  Widget build(BuildContext context) => SizedBox(
        width: double.infinity,
        height: 52,
        child: OutlinedButton(
          onPressed: onPressed,
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: C.inputBorder),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: Text(label, style: T.label),
        ),
      );
}

class Pill extends StatelessWidget {
  final String text;
  final bool orange;
  final bool selected;
  final VoidCallback? onTap;
  const Pill(this.text,
      {super.key, this.orange = false, this.selected = false, this.onTap});
  @override
  Widget build(BuildContext context) {
    final hot = orange || selected;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: hot ? C.orangeTint : C.surface,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: hot ? C.orange : C.inputBorder),
        ),
        child: Text(text,
            style: T.caption.copyWith(
                fontWeight: FontWeight.w600,
                color: hot ? const Color(0xFFB45F00) : C.navy)),
      ),
    );
  }
}

class SurfaceCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  final VoidCallback? onTap;
  final Color color;
  final Color borderColor;
  const SurfaceCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(14),
    this.onTap,
    this.color = C.surface,
    this.borderColor = C.border,
  });
  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: padding,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: borderColor),
          ),
          child: child,
        ),
      );
}

/// Shield + title + subtitle row, used for trust info and hub cards.
class TrustCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback? onTap;
  const TrustCard(this.title, this.subtitle, {super.key, this.onTap});
  @override
  Widget build(BuildContext context) => SurfaceCard(
        onTap: onTap,
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Icon(Icons.shield_outlined, size: 18, color: C.slate),
          const SizedBox(width: 10),
          Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, style: T.h2),
              const SizedBox(height: 2),
              Text(subtitle, style: T.caption),
            ]),
          ),
        ]),
      );
}

class AppField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String? hint;
  final String? error;
  final TextInputType? keyboardType;
  final ValueChanged<String>? onChanged;
  const AppField({
    super.key,
    required this.label,
    required this.controller,
    this.hint,
    this.error,
    this.keyboardType,
    this.onChanged,
  });
  @override
  Widget build(BuildContext context) {
    final bad = error != null;
    OutlineInputBorder b(Color c, [double w = 1]) => OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: c, width: w));
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label.toUpperCase(), style: T.fieldLabel),
      const SizedBox(height: 8),
      TextField(
        controller: controller,
        keyboardType: keyboardType,
        onChanged: onChanged,
        style: T.body,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: T.bodySlate.copyWith(color: C.slate.withAlpha(153)),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          enabledBorder: b(bad ? C.red : C.inputBorder),
          focusedBorder: b(bad ? C.red : C.orange, 1.5),
        ),
      ),
      if (bad)
        Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(error!, style: T.caption.copyWith(color: C.red))),
    ]);
  }
}

class AppBottomNav extends StatelessWidget {
  final int index;
  final ValueChanged<int> onTap;

  /// Optional unread counts per tab index, shown as a small badge.
  final Map<int, int> badges;
  const AppBottomNav(
      {super.key,
      required this.index,
      required this.onTap,
      this.badges = const {}});
  static const _items = [
    (Icons.home_outlined, 'Home'),
    (Icons.search, 'Search'),
    (Icons.add, 'Sell'),
    (Icons.chat_bubble_outline, 'Messages'),
    (Icons.person_outline, 'Profile'),
  ];
  @override
  Widget build(BuildContext context) => Container(
        decoration: const BoxDecoration(
            color: C.white, border: Border(top: BorderSide(color: C.border))),
        child: SafeArea(
          top: false,
          child: Row(children: [
            for (var i = 0; i < _items.length; i++)
              Expanded(
                child: InkWell(
                  onTap: () => onTap(i),
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    Container(
                        height: 3,
                        width: 28,
                        color: i == index ? C.orange : Colors.transparent),
                    const SizedBox(height: 8),
                    Stack(clipBehavior: Clip.none, children: [
                      Icon(_items[i].$1,
                          size: 24, color: i == index ? C.navy : C.slate),
                      if ((badges[i] ?? 0) > 0)
                        Positioned(
                          right: -8,
                          top: -4,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 5, vertical: 1),
                            decoration: BoxDecoration(
                                color: C.orange,
                                borderRadius: BorderRadius.circular(999)),
                            child: Text('${badges[i]}',
                                style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: C.navy)),
                          ),
                        ),
                    ]),
                    const SizedBox(height: 2),
                    Text(_items[i].$2,
                        style: T.caption.copyWith(
                            fontSize: 11,
                            color: i == index ? C.navy : C.slate,
                            fontWeight: i == index
                                ? FontWeight.w600
                                : FontWeight.w400)),
                    const SizedBox(height: 8),
                  ]),
                ),
              ),
          ]),
        ),
      );
}
