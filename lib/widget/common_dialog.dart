import 'package:base_app/core/extension/theme_extension.dart';
import 'package:flutter/material.dart';

class CommonDialog extends StatefulWidget {
  final Widget widget;
  final VoidCallback? onClose;

  const CommonDialog({super.key, required this.widget, this.onClose});

  static Future<void> show(BuildContext context, {required Widget widget, VoidCallback? onClose}) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (BuildContext context) => CommonDialog(onClose: onClose, widget: widget),
    );
  }

  @override
  State<CommonDialog> createState() => _CommonDialogState();
}

class _CommonDialogState extends State<CommonDialog> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.3,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _animationController, curve: Curves.elasticOut));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeIn));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: Container(
                decoration: BoxDecoration(
                  color: context.colors.onPrimary,
                  borderRadius: BorderRadius.circular(8.0),
                ),
                padding: context.paddingAll,
                child: widget.widget,
              ),
            ),
          ),
        );
      },
    );
  }
}
