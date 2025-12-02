import 'package:base_app/core/extension/theme_extension.dart';
import 'package:flutter/material.dart';

class CommonDropdown<T> extends StatelessWidget {
  final String? label;
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?>? onChanged;
  final EdgeInsetsGeometry padding;
  final Color? backgroundColor;
  final Color? borderColor; // ✅ new
  final double borderWidth; // ✅ new
  final double borderRadius;
  final TextStyle? textStyle;
  final bool isExpanded;

  const CommonDropdown({
    super.key,
    this.label,
    required this.value,
    required this.items,
    required this.onChanged,
    this.padding = const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
    this.backgroundColor,
    this.borderColor,
    this.borderWidth = 1.0,
    this.borderRadius = 8.0,
    this.textStyle,
    this.isExpanded = true,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(label!, style: context.topology.textTheme.bodyMedium),
          const SizedBox(height: 6),
        ],
        Container(
          padding: padding,
          decoration: BoxDecoration(
            color: backgroundColor ?? colors.surface,
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(
              color: borderColor ?? colors.primary, // ✅ border color
              width: borderWidth, // ✅ border width
            ),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<T>(
              value: value,
              items: items,
              onChanged: onChanged,
              isExpanded: isExpanded,
              style:
                  textStyle ??
                  context.topology.textTheme.bodyMedium?.copyWith(color: context.colors.primary),
              icon: Icon(Icons.arrow_drop_down, color: colors.onSurface),
            ),
          ),
        ),
      ],
    );
  }
}
