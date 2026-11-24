import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import '../tokens.dart';

/// One-shot message held in a cubit state and shown as a snackbar.
/// The unique [id] makes two identical messages count as different events.
class UiMessage extends Equatable {
  final String text;
  final bool isError;
  final int id;

  UiMessage._(this.text, this.isError)
      : id = DateTime.now().microsecondsSinceEpoch;
  factory UiMessage.error(String text) => UiMessage._(text, true);
  factory UiMessage.success(String text) => UiMessage._(text, false);

  @override
  List<Object?> get props => [text, isError, id];
}

void showUiMessage(BuildContext context, UiMessage m) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(
      content: Text(m.text),
      backgroundColor: m.isError ? C.red : C.green,
      behavior: SnackBarBehavior.floating,
    ));
}
