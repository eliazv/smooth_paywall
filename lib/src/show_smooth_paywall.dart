import 'package:flutter/material.dart';

/// Shows a paywall as modal bottom sheet.
Future<T?> showSmoothPaywallSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool isScrollControlled = true,
  bool isDismissible = true,
  bool enableDrag = true,
  Color barrierColor = const Color(0x99000000),
  bool useRootNavigator = false,
}) {
  return showModalBottomSheet<T>(
    context: context,
    useRootNavigator: useRootNavigator,
    backgroundColor: Colors.transparent,
    barrierColor: barrierColor,
    isScrollControlled: isScrollControlled,
    isDismissible: isDismissible,
    enableDrag: enableDrag,
    builder: builder,
  );
}

/// Pushes a full-screen paywall page.
Future<T?> showSmoothPaywallPage<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool fullscreenDialog = true,
  bool useRootNavigator = false,
}) {
  return Navigator.of(context, rootNavigator: useRootNavigator).push<T>(
    MaterialPageRoute<T>(builder: builder, fullscreenDialog: fullscreenDialog),
  );
}
