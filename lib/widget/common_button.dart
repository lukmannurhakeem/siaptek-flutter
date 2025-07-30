/*
// Basic elevated button (full width)
CommonButton(
  text: "Submit",
  onPressed: () {},
)

// Outlined button with icon (full width)
CommonButton(
  text: "Save",
  icon: Icons.save, 
  buttonType: ButtonType.outlined,
  onPressed: () {},
)

// Loading state (full width)
CommonButton(
  text: "Processing...",
  isLoading: true,
  onPressed: () {},
)

// Icon-only button (compact width)
CommonButton.iconOnly(
  icon: Icons.add,
  onPressed: () {},
)

// Custom styled button (full width)
CommonButton(
  text: "Delete",
  icon: Icons.delete,
  backgroundColor: Colors.red,
  textColor: Colors.white,
  buttonType: ButtonType.elevated,
  onPressed: () {},
)

// NEW: RichText button examples
CommonButton(
  richText: RichText(
    text: TextSpan(
      text: "Save ",
      style: TextStyle(color: Colors.white, fontSize: 16),
      children: [
        TextSpan(
          text: "\$99.99",
          style: TextStyle(
            color: Colors.yellow,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ],
    ),
  ),
  icon: Icons.shopping_cart,
  backgroundColor: Colors.green,
  onPressed: () {},
)

// Interactive RichText with clickable parts
CommonButton(
  richText: RichText(
    textAlign: TextAlign.center,
    text: TextSpan(
      text: "Read our ",
      style: TextStyle(color: Colors.white, fontSize: 16),
      children: [
        TextSpan(
          text: "Terms",
          style: TextStyle(
            color: Colors.blue,
            fontWeight: FontWeight.bold,
            decoration: TextDecoration.underline,
          ),
          recognizer: TapGestureRecognizer()
            ..onTap = () => print("Terms clicked!"),
        ),
        TextSpan(
          text: " and ",
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
        TextSpan(
          text: "Privacy Policy",
          style: TextStyle(
            color: Colors.blue,
            fontWeight: FontWeight.bold,
            decoration: TextDecoration.underline,
          ),
          recognizer: TapGestureRecognizer()
            ..onTap = () => print("Privacy Policy clicked!"),
        ),
      ],
    ),
  ),
  buttonType: ButtonType.glassmorphism,
  onPressed: () => print("Main button clicked!"),
)

// Complex interactive example
CommonButton(
  richText: RichText(
    textAlign: TextAlign.center,
    text: TextSpan(
      text: "Buy now for ",
      style: TextStyle(color: Colors.white, fontSize: 16),
      children: [
        TextSpan(
          text: "\$29.99",
          style: TextStyle(
            color: Colors.green,
            fontWeight: FontWeight.bold,
            fontSize: 18,
            decoration: TextDecoration.lineThrough,
          ),
          recognizer: TapGestureRecognizer()
            ..onTap = () => print("Original price clicked!"),
        ),
        TextSpan(
          text: " ",
          style: TextStyle(color: Colors.white),
        ),
        TextSpan(
          text: "\$19.99",
          style: TextStyle(
            color: Colors.yellow,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
          recognizer: TapGestureRecognizer()
            ..onTap = () => print("Sale price clicked!"),
        ),
        TextSpan(
          text: " (Limited time!)",
          style: TextStyle(
            color: Colors.red,
            fontSize: 12,
            fontStyle: FontStyle.italic,
          ),
          recognizer: TapGestureRecognizer()
            ..onTap = () => print("Limited time offer clicked!"),
        ),
      ],
    ),
  ),
  backgroundColor: Colors.purple,
  onPressed: () => print("Purchase button clicked!"),
)

// NEW: Glassmorphism button examples (full width)
CommonButton(
  text: "Glass Effect",
  buttonType: ButtonType.glassmorphism,
  onPressed: () {},
)

CommonButton(
  text: "Download",
  icon: Icons.download,
  buttonType: ButtonType.glassmorphism,
  glassBlurIntensity: 15.0,
  glassBorderColor: Colors.white.withOpacity(0.3),
  onPressed: () {},
)

// Override full width behavior
CommonButton(
  text: "Custom Width",
  width: 200, // This will override the full width
  onPressed: () {},
)
 */

import 'dart:ui';

import 'package:base_app/core/extension/theme_extension.dart';
import 'package:base_app/core/theme/app_color.dart';
import 'package:flutter/gestures.dart'; // Added for TapGestureRecognizer
import 'package:flutter/material.dart';

class CommonButton extends StatefulWidget {
  final String? text;
  final RichText? richText; // New property for rich text support
  final VoidCallback? onPressed;
  final IconData? icon;
  final Color? backgroundColor;
  final Color? textColor;
  final Color? iconColor;
  final double borderRadius;
  final EdgeInsetsGeometry padding;
  final double? width;
  final double? height;
  final double iconSize;
  final bool isLoading;
  final Widget? loadingWidget;
  final TextStyle? textStyle;
  final ButtonType buttonType;
  final bool fillWidth; // New property to control full width behavior

  // Glassmorphism-specific properties
  final double glassBlurIntensity;
  final Color? glassBorderColor;
  final double glassBorderWidth;
  final List<Color>? glassGradientColors;
  final bool enableGlassAnimation;

  const CommonButton({
    Key? key,
    this.text,
    this.richText, // New parameter
    required this.onPressed,
    this.icon,
    this.backgroundColor,
    this.textColor,
    this.iconColor,
    this.borderRadius = 8.0,
    this.padding = const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
    this.width,
    this.height,
    this.iconSize = 24.0,
    this.isLoading = false,
    this.loadingWidget,
    this.textStyle,
    this.buttonType = ButtonType.elevated,
    this.fillWidth = true, // Default to true for full width
    this.glassBlurIntensity = 10.0,
    this.glassBorderColor,
    this.glassBorderWidth = 1.5,
    this.glassGradientColors,
    this.enableGlassAnimation = true,
  }) : assert(
         text != null || richText != null || icon != null,
         "Either text, richText, or icon must be provided",
       ),
       assert(
         text == null || richText == null,
         "Cannot provide both text and richText. Use one or the other.",
       ),
       super(key: key);

  // Factory constructor for rich text button
  factory CommonButton.richText({
    Key? key,
    required RichText richText,
    required VoidCallback? onPressed,
    IconData? icon,
    Color? backgroundColor,
    Color? iconColor,
    double borderRadius = 8.0,
    EdgeInsetsGeometry? padding,
    double? width,
    double? height,
    double iconSize = 24.0,
    bool isLoading = false,
    Widget? loadingWidget,
    ButtonType buttonType = ButtonType.elevated,
    bool fillWidth = true,
    double glassBlurIntensity = 10.0,
    Color? glassBorderColor,
    double glassBorderWidth = 1.5,
    List<Color>? glassGradientColors,
    bool enableGlassAnimation = true,
  }) {
    return CommonButton(
      key: key,
      richText: richText,
      icon: icon,
      onPressed: onPressed,
      backgroundColor: backgroundColor,
      iconColor: iconColor,
      borderRadius: borderRadius,
      padding: padding ?? const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      width: width,
      height: height,
      iconSize: iconSize,
      isLoading: isLoading,
      loadingWidget: loadingWidget,
      buttonType: buttonType,
      fillWidth: fillWidth,
      glassBlurIntensity: glassBlurIntensity,
      glassBorderColor: glassBorderColor,
      glassBorderWidth: glassBorderWidth,
      glassGradientColors: glassGradientColors,
      enableGlassAnimation: enableGlassAnimation,
    );
  }

  // Helper method to create interactive RichText with clickable spans
  static RichText createInteractiveRichText({
    required List<InteractiveTextSpan> spans,
    TextAlign textAlign = TextAlign.start,
    TextDirection? textDirection,
    bool softWrap = true,
    TextOverflow overflow = TextOverflow.clip,
    double textScaleFactor = 1.0,
    int? maxLines,
    Locale? locale,
    StrutStyle? strutStyle,
    TextWidthBasis textWidthBasis = TextWidthBasis.parent,
    TextHeightBehavior? textHeightBehavior,
  }) {
    return RichText(
      textAlign: textAlign,
      textDirection: textDirection,
      softWrap: softWrap,
      overflow: overflow,
      textScaleFactor: textScaleFactor,
      maxLines: maxLines,
      locale: locale,
      strutStyle: strutStyle,
      textWidthBasis: textWidthBasis,
      textHeightBehavior: textHeightBehavior,
      text: TextSpan(
        children:
            spans
                .map(
                  (span) => TextSpan(
                    text: span.text,
                    style: span.style,
                    recognizer:
                        span.onTap != null ? (TapGestureRecognizer()..onTap = span.onTap) : null,
                  ),
                )
                .toList(),
      ),
    );
  }

  factory CommonButton.iconOnly({
    Key? key,
    required IconData icon,
    required VoidCallback? onPressed,
    Color? backgroundColor,
    Color? iconColor,
    double borderRadius = 8.0,
    EdgeInsetsGeometry? padding,
    double? width,
    double? height,
    double iconSize = 24.0,
    bool isLoading = false,
    Widget? loadingWidget,
    ButtonType buttonType = ButtonType.elevated,
    bool fillWidth = false, // Icon-only buttons don't fill width by default
    double glassBlurIntensity = 10.0,
    Color? glassBorderColor,
    double glassBorderWidth = 1.5,
    List<Color>? glassGradientColors,
    bool enableGlassAnimation = true,
  }) {
    return CommonButton(
      key: key,
      icon: icon,
      onPressed: onPressed,
      backgroundColor: backgroundColor,
      iconColor: iconColor,
      borderRadius: borderRadius,
      padding: padding ?? const EdgeInsets.all(12.0),
      width: width,
      height: height,
      iconSize: iconSize,
      isLoading: isLoading,
      loadingWidget: loadingWidget,
      buttonType: buttonType,
      fillWidth: fillWidth,
      glassBlurIntensity: glassBlurIntensity,
      glassBorderColor: glassBorderColor,
      glassBorderWidth: glassBorderWidth,
      glassGradientColors: glassGradientColors,
      enableGlassAnimation: enableGlassAnimation,
    );
  }

  // Factory constructor for text-only button
  factory CommonButton.textOnly({
    Key? key,
    required String text,
    required VoidCallback? onPressed,
    Color? backgroundColor,
    Color? textColor,
    double borderRadius = 8.0,
    EdgeInsetsGeometry? padding,
    bool isLoading = false,
    Widget? loadingWidget,
    TextStyle? textStyle,
    ButtonType buttonType = ButtonType.elevated,
    bool fillWidth = true, // Text buttons fill width by default
    double glassBlurIntensity = 10.0,
    Color? glassBorderColor,
    double glassBorderWidth = 1.5,
    List<Color>? glassGradientColors,
    bool enableGlassAnimation = true,
  }) {
    return CommonButton(
      key: key,
      text: text,
      onPressed: onPressed,
      backgroundColor: backgroundColor,
      textColor: textColor,
      borderRadius: borderRadius,
      padding: padding ?? const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      isLoading: isLoading,
      loadingWidget: loadingWidget,
      textStyle: textStyle,
      buttonType: buttonType,
      fillWidth: fillWidth,
      glassBlurIntensity: glassBlurIntensity,
      glassBorderColor: glassBorderColor,
      glassBorderWidth: glassBorderWidth,
      glassGradientColors: glassGradientColors,
      enableGlassAnimation: enableGlassAnimation,
    );
  }

  @override
  State<CommonButton> createState() => _CommonButtonState();
}

class _CommonButtonState extends State<CommonButton> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    if (widget.buttonType == ButtonType.glassmorphism && widget.enableGlassAnimation) {
      _animationController.forward();
    }
  }

  void _onTapUp(TapUpDetails details) {
    if (widget.buttonType == ButtonType.glassmorphism && widget.enableGlassAnimation) {
      _animationController.reverse();
    }
    if (widget.onPressed != null && !widget.isLoading) {
      widget.onPressed!();
    }
  }

  void _onTapCancel() {
    if (widget.buttonType == ButtonType.glassmorphism && widget.enableGlassAnimation) {
      _animationController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    // Get default colors based on button type and theme
    final defaultBackgroundColor = _getDefaultBackgroundColor(colors);
    final defaultForegroundColor = _getDefaultForegroundColor(colors);

    final effectiveBackgroundColor = widget.backgroundColor ?? defaultBackgroundColor;
    final effectiveTextColor = widget.textColor ?? defaultForegroundColor;
    final effectiveIconColor = widget.iconColor ?? widget.textColor ?? defaultForegroundColor;

    // Determine the effective width
    double? effectiveWidth;
    if (widget.width != null) {
      // Explicit width provided
      effectiveWidth = widget.width;
    } else if (widget.fillWidth) {
      // Fill the available width
      effectiveWidth = double.infinity;
    } else {
      // Let the button size itself based on content
      effectiveWidth = null;
    }

    Widget buttonWidget = SizedBox(
      width: effectiveWidth,
      height: widget.height,
      child:
          widget.buttonType == ButtonType.glassmorphism
              ? _buildGlassmorphismButton(
                context,
                effectiveBackgroundColor,
                effectiveTextColor,
                effectiveIconColor,
              )
              : _buildButton(
                context,
                effectiveBackgroundColor,
                effectiveTextColor,
                effectiveIconColor,
              ),
    );

    // Apply scale animation only for glassmorphism buttons
    if (widget.buttonType == ButtonType.glassmorphism && widget.enableGlassAnimation) {
      return AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(scale: _scaleAnimation.value, child: buttonWidget);
        },
      );
    }

    return buttonWidget;
  }

  Widget _buildGlassmorphismButton(
    BuildContext context,
    Color bgColor,
    Color fgColor,
    Color iconClr,
  ) {
    final defaultGlassBorderColor = widget.glassBorderColor ?? Colors.white.withOpacity(0.2);
    final defaultGlassGradientColors =
        widget.glassGradientColors ?? [bgColor.withOpacity(0.2), bgColor.withOpacity(0.1)];

    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(widget.borderRadius),
          border: Border.all(color: defaultGlassBorderColor, width: widget.glassBorderWidth),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
            BoxShadow(
              color: Colors.white.withOpacity(0.1),
              blurRadius: 5,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(widget.borderRadius),
          child: BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: widget.glassBlurIntensity,
              sigmaY: widget.glassBlurIntensity,
            ),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: defaultGlassGradientColors,
                ),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: widget.isLoading ? null : widget.onPressed,
                  borderRadius: BorderRadius.circular(widget.borderRadius),
                  child: Container(
                    padding: widget.padding,
                    child: Center(child: _buildButtonContent(fgColor, iconClr, context)),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildButton(BuildContext context, Color bgColor, Color fgColor, Color iconClr) {
    final buttonStyle = _getButtonStyle(bgColor, fgColor);
    final content = _buildButtonContent(fgColor, iconClr, context);

    switch (widget.buttonType) {
      case ButtonType.elevated:
        return ElevatedButton(
          onPressed: widget.isLoading ? null : widget.onPressed,
          style: buttonStyle,
          child: content,
        );
      case ButtonType.outlined:
        return OutlinedButton(
          onPressed: widget.isLoading ? null : widget.onPressed,
          style: buttonStyle.copyWith(
            backgroundColor: MaterialStateProperty.all(Colors.transparent),
            side: MaterialStateProperty.all(BorderSide(color: bgColor)),
          ),
          child: content,
        );
      case ButtonType.text:
        return TextButton(
          onPressed: widget.isLoading ? null : widget.onPressed,
          style: buttonStyle.copyWith(
            backgroundColor: MaterialStateProperty.all(Colors.transparent),
          ),
          child: content,
        );
      case ButtonType.glassmorphism:
        // This case is handled by _buildGlassmorphismButton
        return const SizedBox.shrink();
    }
  }

  ButtonStyle _getButtonStyle(Color bgColor, Color fgColor) {
    return ButtonStyle(
      backgroundColor: MaterialStateProperty.resolveWith<Color>((Set<MaterialState> states) {
        if (states.contains(MaterialState.disabled)) {
          return bgColor.withOpacity(0.5);
        }
        return bgColor;
      }),
      foregroundColor: MaterialStateProperty.all(fgColor),
      padding: MaterialStateProperty.all(widget.padding),
      shape: MaterialStateProperty.all(
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(widget.borderRadius)),
      ),
      elevation:
          widget.buttonType == ButtonType.elevated
              ? MaterialStateProperty.all(2.0)
              : MaterialStateProperty.all(0.0),
    );
  }

  Widget _buildButtonContent(Color textClr, Color iconClr, BuildContext context) {
    if (widget.isLoading) {
      return widget.loadingWidget ??
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(textClr),
            ),
          );
    }

    // Determine if we have text content (either regular text or rich text)
    final hasTextContent = widget.text != null || widget.richText != null;
    final hasIcon = widget.icon != null;

    // Icon-only button
    if (!hasTextContent && hasIcon) {
      return Icon(widget.icon, color: iconClr, size: widget.iconSize);
    }
    // Text-only button (regular text)
    else if (hasTextContent && !hasIcon && widget.text != null) {
      return Text(
        widget.text!,
        style: widget.textStyle ?? context.topology.textTheme.titleSmall?.copyWith(color: textClr),
        textAlign: TextAlign.center,
      );
    }
    // RichText-only button
    else if (hasTextContent && !hasIcon && widget.richText != null) {
      return widget.richText!;
    }
    // Button with icon and regular text
    else if (hasIcon && widget.text != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(widget.icon, color: iconClr, size: widget.iconSize),
          const SizedBox(width: 8.0),
          Flexible(
            child: Text(
              widget.text!,
              style:
                  widget.textStyle ??
                  context.topology.textTheme.headlineSmall?.copyWith(color: textClr),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      );
    }
    // Button with icon and rich text
    else if (hasIcon && widget.richText != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(widget.icon, color: iconClr, size: widget.iconSize),
          const SizedBox(width: 8.0),
          Flexible(child: widget.richText!),
        ],
      );
    }

    // Fallback - should not reach here due to assertions
    return const SizedBox.shrink();
  }

  Color _getDefaultBackgroundColor(AppColors colors) {
    switch (widget.buttonType) {
      case ButtonType.elevated:
        return colors.primary;
      case ButtonType.outlined:
      case ButtonType.text:
        return Colors.transparent;
      case ButtonType.glassmorphism:
        return AppColors.white.withOpacity(0.1);
    }
  }

  Color _getDefaultForegroundColor(AppColors colors) {
    switch (widget.buttonType) {
      case ButtonType.elevated:
        return colors.onPrimary;
      case ButtonType.outlined:
      case ButtonType.text:
        return colors.primary;
      case ButtonType.glassmorphism:
        return AppColors.white;
    }
  }
}

enum ButtonType {
  elevated,
  outlined,
  text,
  glassmorphism, // New glassmorphism button type
}

// Helper class for creating interactive text spans
class InteractiveTextSpan {
  final String text;
  final TextStyle? style;
  final VoidCallback? onTap;

  const InteractiveTextSpan({required this.text, this.style, this.onTap});

  // Helper constructor for clickable spans
  InteractiveTextSpan.clickable({required this.text, required this.onTap, this.style});

  // Helper constructor for non-clickable spans
  InteractiveTextSpan.static({required this.text, this.style}) : onTap = null;
}
