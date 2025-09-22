import 'package:base_app/core/extension/theme_extension.dart';
import 'package:flutter/material.dart';

class CommonChecklistTile extends StatelessWidget {
  final String title;
  final bool value;
  final ValueChanged<bool?>? onChanged; // ✅ fix: allow nullable
  final EdgeInsetsGeometry contentPadding;
  final ListTileControlAffinity controlAffinity;
  final TextStyle? textStyle;
  final Color? activeColor;
  final Color? checkColor;

  const CommonChecklistTile({
    super.key,
    required this.title,
    required this.value,
    this.onChanged,
    this.contentPadding = EdgeInsets.zero,
    this.controlAffinity = ListTileControlAffinity.leading,
    this.textStyle,
    this.activeColor,
    this.checkColor,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return CheckboxListTile(
      title: Text(title, style: textStyle ?? context.topology.textTheme.bodyMedium),
      value: value,
      onChanged: onChanged,
      controlAffinity: controlAffinity,
      contentPadding: contentPadding,
      activeColor: activeColor ?? colors.primary,
      checkColor: checkColor ?? colors.onPrimary,
    );
  }
}
