import 'package:base_app/core/extension/theme_extension.dart';
import 'package:flutter/material.dart';

class TeamPlannerScreen extends StatefulWidget{
  const TeamPlannerScreen({super.key});

  @override
  State<TeamPlannerScreen> createState() => _TeamPlannerScreen();
}

class _TeamPlannerScreen extends State<TeamPlannerScreen> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: context.paddingAll,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text('403. Forbidden',style: context.topology.textTheme.titleLarge?.copyWith(color: context.colors.error)),
          Text('You do not have permission to plan events.',style: context.topology.textTheme.titleMedium?.copyWith(color: context.colors.primary),),
        ],
      ),
    );
  }
  
}