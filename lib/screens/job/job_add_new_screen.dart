import 'package:base_app/core/extension/theme_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class JobAddNewScreen extends StatefulWidget {
  const JobAddNewScreen({super.key});

  @override
  State<JobAddNewScreen> createState() => _JobAddNewScreen();
}

class _JobAddNewScreen extends State<JobAddNewScreen> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // ✅ Background SVG at the bottom
        Positioned(
          bottom: 10,
          left: 0,
          right: 0,
          child: SvgPicture.asset(
            'assets/images/todo.svg',
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
                'We still upgrading for your convenience',
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
}
