import 'package:INSPECT/core/extension/theme_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ItemMovementScreen extends StatefulWidget {
  const ItemMovementScreen({super.key});

  @override
  State<ItemMovementScreen> createState() => _ItemMovementScreenState();
}

class _ItemMovementScreenState extends State<ItemMovementScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: context.isTablet ? _buildTabletLayout(context) : _buildMobileLayout(context),
    );
  }

  Widget _buildTabletLayout(BuildContext context) {
    return Stack(
      children: [
        // ✅ Background SVG at the bottom
        Positioned(
          bottom: 10,
          left: 0,
          right: 0,
          child: SvgPicture.asset(
            'assets/images/work_in_progress.svg',
            fit: BoxFit.contain,
            alignment: Alignment.bottomCenter,
            height: context.screenHeight * 0.3, // you can adjust this
          ),
        ),

        // Foreground content centered
        Container(
          width: double.infinity,
          height: context.screenHeight - kToolbarHeight * 2,
          padding: context.paddingHorizontal,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              context.vXxl,
              Text(
                'Take a break',
                style: context.topology.textTheme.titleMedium?.copyWith(
                  color: context.colors.error,
                ),
              ),
              Text(
                'There is no movement by now',
                style: context.topology.textTheme.titleMedium?.copyWith(
                  color: context.colors.primary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    return Text('Mobile View');
  }
}
