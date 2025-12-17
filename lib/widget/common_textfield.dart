import 'package:INSPECT/core/extension/theme_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CommonTextField extends StatefulWidget {
  final String? labelText;
  final String? hintText;
  final String? helperText;
  final String? errorText;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final void Function(String)? onFieldSubmitted;
  final void Function()? onTap;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final bool obscureText;
  final bool enabled;
  final bool readOnly;
  final bool autofocus;
  final int? maxLines;
  final int? minLines;
  final int? maxLength;
  final List<TextInputFormatter>? inputFormatters;
  final FocusNode? focusNode;
  final TextCapitalization textCapitalization;
  final TextAlign textAlign;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final String? prefixText;
  final String? suffixText;
  final EdgeInsetsGeometry? contentPadding;
  final Color? fillColor;
  final Color? borderColor;
  final Color? focusedBorderColor;
  final Color? errorBorderColor;
  final double? borderRadius;
  final double? borderWidth;
  final bool filled;
  final TextStyle? style;
  final TextStyle? labelStyle;
  final TextStyle? hintStyle;
  final TextStyle? errorStyle;
  final TextStyle? helperStyle;
  final AutovalidateMode? autovalidateMode;
  final bool showPasswordToggle;
  final IconData? passwordVisibleIcon;
  final IconData? passwordHiddenIcon;

  const CommonTextField({
    Key? key,
    this.labelText,
    this.hintText,
    this.helperText,
    this.errorText,
    this.controller,
    this.validator,
    this.onChanged,
    this.onFieldSubmitted,
    this.onTap,
    this.keyboardType,
    this.textInputAction,
    this.obscureText = false,
    this.enabled = true,
    this.readOnly = false,
    this.autofocus = false,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.inputFormatters,
    this.focusNode,
    this.textCapitalization = TextCapitalization.none,
    this.textAlign = TextAlign.start,
    this.prefixIcon,
    this.suffixIcon,
    this.prefixText,
    this.suffixText,
    this.contentPadding,
    this.fillColor,
    this.borderColor,
    this.focusedBorderColor,
    this.errorBorderColor,
    this.borderRadius,
    this.borderWidth,
    this.filled = false,
    this.style,
    this.labelStyle,
    this.hintStyle,
    this.errorStyle,
    this.helperStyle,
    this.autovalidateMode,
    this.showPasswordToggle = false,
    this.passwordVisibleIcon = Icons.visibility,
    this.passwordHiddenIcon = Icons.visibility_off,
  }) : super(key: key);

  @override
  State<CommonTextField> createState() => _CommonTextFieldState();
}

class _CommonTextFieldState extends State<CommonTextField> {
  late bool _obscureText;
  late FocusNode _focusNode;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.obscureText;
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    super.dispose();
  }

  void _onFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });
  }

  void _togglePasswordVisibility() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  Widget? _buildSuffixIcon() {
    if (widget.showPasswordToggle && widget.obscureText) {
      return IconButton(
        icon: Icon(
          _obscureText ? widget.passwordHiddenIcon : widget.passwordVisibleIcon,
          color:
              _isFocused
                  ? widget.focusedBorderColor ?? Theme.of(context).primaryColor
                  : Colors.grey[600],
        ),
        onPressed: _togglePasswordVisibility,
      );
    }
    return widget.suffixIcon;
  }

  OutlineInputBorder _buildBorder({Color? color, double? width}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(widget.borderRadius ?? 8.0),
      borderSide: BorderSide(
        color: color ?? widget.borderColor ?? Colors.grey[400]!,
        width: width ?? widget.borderWidth ?? 1.0,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      cursorHeight: 16,
      controller: widget.controller,
      validator: widget.validator,
      onChanged: widget.onChanged,
      onFieldSubmitted: widget.onFieldSubmitted,
      onTap: widget.onTap,
      keyboardType: widget.keyboardType,
      textInputAction: widget.textInputAction,
      obscureText: _obscureText,
      enabled: widget.enabled,
      readOnly: widget.readOnly,
      autofocus: widget.autofocus,
      maxLines: widget.maxLines,
      minLines: widget.minLines,
      maxLength: widget.maxLength,
      inputFormatters: widget.inputFormatters,
      focusNode: _focusNode,
      textCapitalization: widget.textCapitalization,
      textAlign: widget.textAlign,
      autovalidateMode: widget.autovalidateMode,
      style: widget.style ?? context.topology.textTheme.bodyMedium,
      decoration: InputDecoration(
        labelText: widget.labelText,
        hintText: widget.hintText,
        helperText: widget.helperText,
        errorText: widget.errorText,
        prefixIcon: widget.prefixIcon,
        suffixIcon: _buildSuffixIcon(),
        prefixText: widget.prefixText,
        suffixText: widget.suffixText,
        contentPadding:
            widget.contentPadding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        filled: widget.filled,
        fillColor: widget.fillColor ?? (widget.filled ? Colors.grey[50] : null),

        // Label styling
        labelStyle:
            widget.labelStyle ??
            context.topology.textTheme.titleMedium?.copyWith(
              color:
                  _isFocused
                      ? widget.focusedBorderColor ?? context.colors.primary
                      : Colors.grey[700],
            ),

        // Hint styling
        hintStyle:
            widget.hintStyle ??
            context.topology.textTheme.bodyMedium?.copyWith(color: Colors.grey[500]),

        // Error styling
        errorStyle:
            widget.errorStyle ??
            TextStyle(color: widget.errorBorderColor ?? context.colors.primary),

        // Helper styling
        helperStyle: widget.helperStyle ?? TextStyle(color: Colors.grey[600]),

        // Border styling
        border: _buildBorder(),
        enabledBorder: _buildBorder(color: widget.borderColor ?? Colors.grey[400]),
        focusedBorder: _buildBorder(
          color: widget.focusedBorderColor ?? context.colors.primary,
          width: 2.0,
        ),
        errorBorder: _buildBorder(color: widget.errorBorderColor ?? context.colors.error),
        focusedErrorBorder: _buildBorder(
          color: widget.errorBorderColor ?? context.colors.error,
          width: 2.0,
        ),
        disabledBorder: _buildBorder(color: Colors.grey[300]),
      ),
    );
  }
}
