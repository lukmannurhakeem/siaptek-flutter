import 'package:flutter/material.dart';

class CommonBackground extends StatelessWidget {
  final Widget? child;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final BoxFit fit;
  final Alignment alignment;
  final BorderRadius? borderRadius;
  final Color? overlayColor;
  final double overlayOpacity;

  const CommonBackground({
    Key? key,
    this.child,
    this.width,
    this.height,
    this.padding,
    this.margin,
    this.fit = BoxFit.cover,
    this.alignment = Alignment.center,
    this.borderRadius,
    this.overlayColor,
    this.overlayOpacity = 0.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        image: DecorationImage(
          image: const AssetImage(
              'assets/images/background.jpg'), // Replace with your image path
          fit: fit,
          alignment: alignment,
        ),
      ),
      child: overlayColor != null && overlayOpacity > 0
          ? Container(
              decoration: BoxDecoration(
                color: overlayColor!.withOpacity(overlayOpacity),
                borderRadius: borderRadius,
              ),
              child: child,
            )
          : child,
    );
  }
}
