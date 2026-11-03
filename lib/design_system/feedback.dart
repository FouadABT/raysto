import 'package:flutter/material.dart';

/// A Material 3 snackbar on the inverse surface (see `AppTheme`), replacing
/// any snackbar already showing. With [onUndo] it offers one action and still
/// closes by itself after [duration]: the caller's own timer decides what
/// happens next, never the snackbar's visibility.
ScaffoldFeatureController<SnackBar, SnackBarClosedReason> showRaystoSnackBar(
  BuildContext context,
  String message, {
  VoidCallback? onUndo,
  String undoLabel = 'Undo',
  Duration duration = const Duration(seconds: 5),
}) {
  final messenger = ScaffoldMessenger.of(context);
  messenger.hideCurrentSnackBar();
  return messenger.showSnackBar(
    SnackBar(
      content: Text(message),
      duration: duration,
      // Material keeps a snackbar with an action until dismissed; this one
      // must leave on time, its action being a convenience, not a decision.
      persist: false,
      action: onUndo == null
          ? null
          : SnackBarAction(label: undoLabel, onPressed: onUndo),
    ),
  );
}
