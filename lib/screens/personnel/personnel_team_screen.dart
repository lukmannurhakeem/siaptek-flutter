import 'package:base_app/core/extension/theme_extension.dart';
import 'package:base_app/core/service/navigation_service.dart';
import 'package:base_app/route/route.dart';
import 'package:base_app/widget/common_textfield.dart';
import 'package:flutter/material.dart';

class PersonnelTeamScreen extends StatefulWidget {
  const PersonnelTeamScreen({super.key});

  @override
  State<PersonnelTeamScreen> createState() => _PersonnelTeamScreenState();
}

class _PersonnelTeamScreenState extends State<PersonnelTeamScreen> {
  @override
  Widget build(BuildContext context) {
    final screenHeight = context.screenHeight - (kToolbarHeight * 1.25);
    final screenWidth = context.screenWidth;

    List<String> teams = [
      "Alpha Squad",
      "Phoenix Warriors",
      "Thunder Bolts",
      "Shadow Hunters",
      "Golden Eagles",
      "Storm Breakers",
      "Fire Dragons",
      "Ice Wolves",
      "Lightning Strike",
      "Crimson Guardians",
    ];

    return SizedBox(
      width: screenWidth,
      height: screenHeight,
      child: Stack(
        children: [
          Positioned.fill(
            child: Padding(
              padding: context.paddingAll,
              child: Column(
                children: [
                  CommonTextField(
                    hintText: 'Search here ...',
                    style: context.topology.textTheme.bodySmall?.copyWith(
                      color: context.colors.primary,
                    ),
                    suffixIcon: Icon(Icons.search, color: context.colors.primary),
                  ),
                  context.vM,
                  Expanded(
                    child: ListView.builder(
                      itemCount: teams.length,
                      itemBuilder: (context, index) {
                        final data = teams[index];
                        if (index >= teams.length) return const SizedBox.shrink();
                        return Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Text(
                                  '${index + 1}.',
                                  style: context.topology.textTheme.bodyMedium?.copyWith(
                                    color: context.colors.primary,
                                  ),
                                ),
                                context.hS,
                                Text(
                                  data,
                                  style: context.topology.textTheme.bodyMedium?.copyWith(
                                    color: context.colors.primary,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 50,
            right: 30,
            child: FloatingActionButton(
              onPressed: () {
                NavigationService().navigateTo(AppRoutes.createTeamPersonnel);
              },
              tooltip: 'Add New',
              child: const Icon(Icons.add),
              backgroundColor: context.colors.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _personnelCard(BuildContext context, String name) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                color: context.colors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Icon(Icons.person, size: 40, color: context.colors.primary),
            ),
            const SizedBox(height: 12),
            Text(
              name,
              textAlign: TextAlign.center,
              style: context.topology.textTheme.bodySmall?.copyWith(color: context.colors.primary),
            ),
          ],
        ),
      ),
    );
  }
}
