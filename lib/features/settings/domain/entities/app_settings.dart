import 'package:equatable/equatable.dart';

enum TextSize {
  small(0.9, 'Small'),
  normal(1.0, 'Default'),
  large(1.2, 'Large');

  const TextSize(this.factor, this.label);
  final double factor;
  final String label;
}

class AppSettings extends Equatable {
  final TextSize textSize;
  final bool showUnreadBadge;
  final bool rememberEmail;
  final String savedEmail;

  const AppSettings({
    this.textSize = TextSize.normal,
    this.showUnreadBadge = true,
    this.rememberEmail = false,
    this.savedEmail = '',
  });

  /// Email to prefill on the login page ('' when not remembered).
  String get rememberedEmail => rememberEmail ? savedEmail : '';

  AppSettings copyWith(
          {TextSize? textSize,
          bool? showUnreadBadge,
          bool? rememberEmail,
          String? savedEmail}) =>
      AppSettings(
        textSize: textSize ?? this.textSize,
        showUnreadBadge: showUnreadBadge ?? this.showUnreadBadge,
        rememberEmail: rememberEmail ?? this.rememberEmail,
        savedEmail: savedEmail ?? this.savedEmail,
      );

  @override
  List<Object?> get props =>
      [textSize, showUnreadBadge, rememberEmail, savedEmail];
}
