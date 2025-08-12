import 'package:base_app/core/extension/theme_extension.dart';
import 'package:flutter/material.dart';

class CommonCollapsibleWidget extends StatefulWidget {
  /// The header widget that will always be visible and acts as the toggle
  final Widget header;

  /// The content widget that will be collapsed/expanded
  final Widget content;

  /// Initial collapsed state
  final bool initiallyCollapsed;

  /// Duration of the expand/collapse animation
  final Duration animationDuration;

  /// Animation curve
  final Curve curve;

  /// Whether to show a trailing icon (chevron)
  final bool showTrailingIcon;

  /// Custom trailing icon when collapsed
  final Widget? collapsedIcon;

  /// Custom trailing icon when expanded
  final Widget? expandedIcon;

  /// Callback when the collapsed state changes
  final ValueChanged<bool>? onToggle;

  /// Padding around the content
  final EdgeInsetsGeometry? contentPadding;

  /// Background color of the widget
  final Color? backgroundColor;

  /// Border radius
  final BorderRadius? borderRadius;

  /// Whether the entire header area is clickable or just the icon
  final bool headerClickable;

  const CommonCollapsibleWidget({
    Key? key,
    required this.header,
    required this.content,
    this.initiallyCollapsed = true,
    this.animationDuration = const Duration(milliseconds: 300),
    this.curve = Curves.easeInOut,
    this.showTrailingIcon = true,
    this.collapsedIcon,
    this.expandedIcon,
    this.onToggle,
    this.contentPadding,
    this.backgroundColor,
    this.borderRadius,
    this.headerClickable = true,
  }) : super(key: key);

  @override
  State<CommonCollapsibleWidget> createState() => _CommonCollapsibleWidgetState();
}

class _CommonCollapsibleWidgetState extends State<CommonCollapsibleWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _expandAnimation;
  late Animation<double> _iconRotationAnimation;
  late bool _isCollapsed;

  @override
  void initState() {
    super.initState();
    _isCollapsed = widget.initiallyCollapsed;

    _controller = AnimationController(duration: widget.animationDuration, vsync: this);

    _expandAnimation = CurvedAnimation(parent: _controller, curve: widget.curve);

    _iconRotationAnimation = Tween<double>(begin: 0.0, end: 0.5).animate(_expandAnimation);

    if (!_isCollapsed) {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() {
      _isCollapsed = !_isCollapsed;
      if (_isCollapsed) {
        _controller.reverse();
      } else {
        _controller.forward();
      }
      widget.onToggle?.call(_isCollapsed);
    });
  }

  Widget _buildTrailingIcon() {
    if (!widget.showTrailingIcon) return const SizedBox.shrink();

    return GestureDetector(
      onTap: widget.headerClickable ? null : _toggle,
      child: AnimatedBuilder(
        animation: _iconRotationAnimation,
        builder: (context, child) {
          if (widget.collapsedIcon != null && widget.expandedIcon != null) {
            return _isCollapsed ? widget.collapsedIcon! : widget.expandedIcon!;
          }

          return Transform.rotate(
            angle: _iconRotationAnimation.value * 3.14159,
            child: Icon(Icons.keyboard_arrow_down, color: context.colors.primary),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: widget.backgroundColor ?? context.colors.primary.withOpacity(0.1),
        borderRadius: widget.borderRadius,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          GestureDetector(
            onTap: widget.headerClickable ? _toggle : null,
            child: Row(children: [Expanded(child: widget.header), _buildTrailingIcon()]),
          ),
          SizeTransition(
            sizeFactor: _expandAnimation,
            child: Container(padding: widget.contentPadding, child: widget.content),
          ),
        ],
      ),
    );
  }
}
