import 'package:base_app/core/extension/theme_extension.dart';
import 'package:base_app/core/service/navigation_service.dart';
import 'package:base_app/route/route.dart';
import 'package:base_app/widget/common_textfield.dart';
import 'package:flutter/material.dart';

class PersonnelScreen extends StatefulWidget {
  const PersonnelScreen({super.key});

  @override
  State<PersonnelScreen> createState() => _PersonnelScreenState();
}

class _PersonnelScreenState extends State<PersonnelScreen> {
  @override
  Widget build(BuildContext context) {
    final screenHeight = context.screenHeight - (kToolbarHeight * 1.25);
    final screenWidth = context.screenWidth;

    List<String> personnel = [
      "Ahmad Bin Abdullah",
      "Siti Nurhaliza Binti Hassan",
      "Raj Kumar A/L Subramaniam",
      "Lim Wei Ming",
      "Fatimah Binti Omar",
      "Chen Kar Wai",
      "Devi A/P Krishnan",
      "Tan Bee Lian",
      "Mohd Syafiq Bin Roslan",
      "Wong Mei Ling",
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
                    child: GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: context.isTablet ? 6 : 2,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: context.isTablet ? 2.0 : 1.0,
                      ),
                      itemCount: personnel.length,
                      itemBuilder: (context, index) {
                        final data = personnel[index];
                        return _personnelCard(context, data);
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
                NavigationService().navigateTo(AppRoutes.createPersonnel);
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
    return GestureDetector(
      onTap: () {
        NavigationService().navigateTo(AppRoutes.personnelDetails);
      },
      child: Card(
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
                style: context.topology.textTheme.bodySmall?.copyWith(
                  color: context.colors.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
