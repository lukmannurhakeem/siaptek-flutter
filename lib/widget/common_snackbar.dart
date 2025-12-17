import 'package:INSPECT/core/extension/theme_extension.dart';
import 'package:flutter/material.dart';

/// A reusable custom snackbar utility class
class CommonSnackbar {
  static void show({
    required BuildContext context,
    required String message,
    required SnackbarType type,
    Duration duration = const Duration(seconds: 3),
    VoidCallback? onDismiss,
  }) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: CustomSnackbarContent(message: message, type: type),
        backgroundColor: Colors.transparent,
        elevation: 0,
        duration: duration,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        padding: EdgeInsets.zero,
        dismissDirection: DismissDirection.horizontal,
        onVisible: () {
          // Optional callback when snackbar becomes visible
        },
      ),
    );
  }

  /// Shows a success snackbar
  static void showSuccess(BuildContext context, String message) {
    show(context: context, message: message, type: SnackbarType.success);
  }

  /// Shows an error snackbar
  static void showError(BuildContext context, String message) {
    show(context: context, message: message, type: SnackbarType.error);
  }

  /// Shows an info snackbar
  static void showInfo(BuildContext context, String message) {
    show(context: context, message: message, type: SnackbarType.info);
  }

  /// Shows a warning snackbar
  static void showWarning(BuildContext context, String message) {
    show(context: context, message: message, type: SnackbarType.warning);
  }
}

class CustomSnackbarContent extends StatelessWidget {
  final String message;
  final SnackbarType type;

  const CustomSnackbarContent({Key? key, required this.message, required this.type})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: _getBackgroundColor(context),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          _getIcon(context),
          const SizedBox(width: 12),
          Expanded(child: Text(message, style: const TextStyle(color: Colors.white, fontSize: 14))),
          const SizedBox(width: 8),
          InkWell(
            onTap: () {
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
            },
            child: const Icon(Icons.close, color: Colors.white70, size: 16),
          ),
        ],
      ),
    );
  }

  Icon _getIcon(BuildContext context) {
    switch (type) {
      case SnackbarType.success:
        return Icon(Icons.check_circle, color: context.colors.success);
      case SnackbarType.error:
        return Icon(Icons.error, color: context.colors.onPrimary);
      case SnackbarType.info:
        return Icon(Icons.info, color: context.colors.info);
      case SnackbarType.warning:
        return Icon(Icons.warning, color: context.colors.warning);
    }
  }

  Color _getBackgroundColor(BuildContext context) {
    switch (type) {
      case SnackbarType.success:
        return context.colors.success.withOpacity(0.9);
      case SnackbarType.error:
        return context.colors.error.withOpacity(0.9);
      case SnackbarType.info:
        return context.colors.info.withOpacity(0.9);
      case SnackbarType.warning:
        return context.colors.warning.withOpacity(0.9);
    }
  }
}

/// Enum to define the type of snackbar
enum SnackbarType { success, error, info, warning }
