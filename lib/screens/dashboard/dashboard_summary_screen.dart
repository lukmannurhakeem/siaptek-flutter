import 'package:base_app/core/extension/theme_extension.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class SummaryScreen extends StatefulWidget {
  const SummaryScreen({super.key});

  @override
  State<SummaryScreen> createState() => _SummaryScreenState();
}

class _SummaryScreenState extends State<SummaryScreen> {
  int _touchedIndex = -1;

  final List<String> _labels = [
    'Fail',
    'Quarantine',
    'Rejected',
    'CAR',
    'Unsatisfactory',
    'Satisfactory',
    'Pass',
    'Accepted',
    'Fir for use at time of inspection',
    'Items with No Status',
  ];
  final List<Color> _colors = [
    Colors.red,
    Colors.brown,
    Colors.grey,
    Colors.orange,
    Colors.cyan,
    Colors.indigo,
    Colors.lime,
    Colors.green,
    Colors.teal,
    Colors.amber,
  ];
  final List<double> _values = [1, 0, 4, 0, 1, 6, 13, 11, 50, 11];

  @override
  Widget build(BuildContext context) {
    return (context.isTablet)
        ? Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            context.vS,
            Text(
              'Report Status',
              style: context.topology.textTheme.titleMedium?.copyWith(
                color: context.colors.primary,
              ),
            ),
            Container(
              width: MediaQuery.of(context).size.width,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Card(
                    margin: const EdgeInsets.all(0),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Items Under Management',
                            style: context.topology.textTheme.bodyLarge?.copyWith(
                              color: context.colors.primary,
                            ),
                          ),
                          context.vS,
                          Text(
                            '49405',
                            style: context.topology.textTheme.titleLarge?.copyWith(
                              color: context.colors.primary,
                            ),
                          ),
                          context.vS,
                          Text(
                            'Total Items',
                            style: context.topology.textTheme.bodyMedium?.copyWith(
                              color: context.colors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Card(
                    margin: const EdgeInsets.all(0),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Items Under Management',
                            style: context.topology.textTheme.bodyLarge?.copyWith(
                              color: context.colors.primary,
                            ),
                          ),
                          context.vS,
                          Text(
                            '49405',
                            style: context.topology.textTheme.titleLarge?.copyWith(
                              color: context.colors.primary,
                            ),
                          ),
                          context.vS,
                          Text(
                            'Total Items',
                            style: context.topology.textTheme.bodyMedium?.copyWith(
                              color: context.colors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Card(
                    margin: const EdgeInsets.all(0),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Items Under Management',
                            style: context.topology.textTheme.bodyLarge?.copyWith(
                              color: context.colors.primary,
                            ),
                          ),
                          context.vS,
                          Text(
                            '49405',
                            style: context.topology.textTheme.titleLarge?.copyWith(
                              color: context.colors.primary,
                            ),
                          ),
                          context.vS,
                          Text(
                            'Total Items',
                            style: context.topology.textTheme.bodyMedium?.copyWith(
                              color: context.colors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Card(
                    margin: const EdgeInsets.all(0),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Items Under Management',
                            style: context.topology.textTheme.bodyLarge?.copyWith(
                              color: context.colors.primary,
                            ),
                          ),
                          context.vS,
                          Text(
                            '49405',
                            style: context.topology.textTheme.titleLarge?.copyWith(
                              color: context.colors.primary,
                            ),
                          ),
                          context.vS,
                          Text(
                            'Total Items',
                            style: context.topology.textTheme.bodyMedium?.copyWith(
                              color: context.colors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: context.paddingAll,
              child: Text(
                'Status Comparison',
                style: context.topology.textTheme.titleLarge?.copyWith(
                  color: context.colors.primary,
                ),
              ),
            ),
            context.divider,
            context.vS,
            SizedBox(
              height: MediaQuery.of(context).size.height / 3,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start, // Align to top
                children: [
                  Expanded(
                    child: AspectRatio(
                      aspectRatio: 1.5,
                      child: PieChart(
                        PieChartData(
                          sectionsSpace: 2,

                          centerSpaceRadius: 40,
                          pieTouchData: PieTouchData(
                            touchCallback: (event, response) {
                              setState(() {
                                if (!event.isInterestedForInteractions ||
                                    response == null ||
                                    response.touchedSection == null) {
                                  _touchedIndex = -1;
                                  return;
                                }
                                _touchedIndex = response.touchedSection!.touchedSectionIndex;
                              });
                            },
                          ),
                          sections: _getSections(),
                        ),
                      ),
                    ),
                  ),
                  context.hL,
                  Expanded(
                    child: Container(alignment: Alignment.topCenter, child: _buildIndicators()),
                  ),
                ],
              ),
            ),
          ],
        )
        : ListView(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Pie Chart Section
                context.vS,
                Text(
                  'Report Status',
                  style: context.topology.textTheme.titleMedium?.copyWith(
                    color: context.colors.primary,
                  ),
                ),
                context.vS,
                context.divider,
                context.vS,
                Container(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      AspectRatio(
                        aspectRatio: 1.5,
                        child: PieChart(
                          PieChartData(
                            sectionsSpace: 2,
                            centerSpaceRadius: 40,
                            pieTouchData: PieTouchData(
                              touchCallback: (event, response) {
                                setState(() {
                                  if (!event.isInterestedForInteractions ||
                                      response == null ||
                                      response.touchedSection == null) {
                                    _touchedIndex = -1;
                                    return;
                                  }
                                  _touchedIndex = response.touchedSection!.touchedSectionIndex;
                                });
                              },
                            ),
                            sections: _getSections(),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Indicators/Legend
                      _buildIndicators(),
                    ],
                  ),
                ),
                context.vS,
                context.divider,
                context.vS,
                // Cards Section
                SizedBox(
                  width: double.infinity,
                  child: Card(
                    margin: EdgeInsets.zero,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
                    ),
                    elevation: 8,
                    color: context.colors.secondary,
                    // Light background for contrast
                    child: Stack(
                      children: [
                        // 🔵 Background decorative icon (overlayed)
                        Positioned(
                          top: -10,
                          right: -10,
                          child: Icon(
                            Icons.inventory_2_rounded,
                            size: 120,
                            color: context.colors.primary.withOpacity(0.08),
                          ),
                        ),

                        // 🔷 Colored side bar
                        Positioned(
                          left: 0,
                          top: 0,
                          bottom: 0,
                          width: 6,
                          child: Container(
                            decoration: BoxDecoration(
                              color: context.colors.primary,
                              borderRadius: const BorderRadius.only(
                                bottomLeft: Radius.circular(16),
                              ),
                            ),
                          ),
                        ),

                        // 🔤 Main content
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 24.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Items Under Management',
                                style: context.topology.textTheme.bodySmall?.copyWith(
                                  color: context.colors.primary,
                                ),
                              ),
                              context.vS,
                              Text(
                                '49,405',
                                style: context.topology.textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: context.colors.primary,
                                ),
                              ),
                              context.vS,
                              Text(
                                'Total Items',
                                style: context.topology.textTheme.bodySmall?.copyWith(
                                  color: context.colors.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                context.vS,

                SizedBox(
                  width: double.infinity,
                  child: Card(
                    margin: EdgeInsets.zero,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
                    ),
                    elevation: 8,
                    color: context.colors.secondary,
                    // Light background for contrast
                    child: Stack(
                      children: [
                        // 🔵 Background decorative icon (overlayed)
                        Positioned(
                          top: -10,
                          right: -10,
                          child: Icon(
                            Icons.work,
                            size: 120,
                            color: context.colors.primary.withOpacity(0.08),
                          ),
                        ),

                        // 🔷 Colored side bar
                        Positioned(
                          left: 0,
                          top: 0,
                          bottom: 0,
                          width: 6,
                          child: Container(
                            decoration: BoxDecoration(
                              color: context.colors.primary,
                              borderRadius: const BorderRadius.only(
                                bottomLeft: Radius.circular(16),
                              ),
                            ),
                          ),
                        ),

                        // 🔤 Main content
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 24.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Jobs This Month',
                                style: context.topology.textTheme.bodySmall?.copyWith(
                                  color: context.colors.primary,
                                ),
                              ),
                              context.vS,
                              Text(
                                '0',
                                style: context.topology.textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: context.colors.primary,
                                ),
                              ),
                              context.vS,
                              Text(
                                'Job',
                                style: context.topology.textTheme.bodySmall?.copyWith(
                                  color: context.colors.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                context.vS,

                SizedBox(
                  width: double.infinity,
                  child: Card(
                    margin: EdgeInsets.zero,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
                    ),
                    elevation: 8,
                    color: context.colors.secondary,
                    // Light background for contrast
                    child: Stack(
                      children: [
                        // 🔵 Background decorative icon (overlayed)
                        Positioned(
                          top: -10,
                          right: -10,
                          child: Icon(
                            Icons.calendar_month,
                            size: 120,
                            color: context.colors.primary.withOpacity(0.08),
                          ),
                        ),

                        // 🔷 Colored side bar
                        Positioned(
                          left: 0,
                          top: 0,
                          bottom: 0,
                          width: 6,
                          child: Container(
                            decoration: BoxDecoration(
                              color: context.colors.primary,
                              borderRadius: const BorderRadius.only(
                                bottomLeft: Radius.circular(16),
                              ),
                            ),
                          ),
                        ),

                        // 🔤 Main content
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 24.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Jobs Next Month',
                                style: context.topology.textTheme.bodySmall?.copyWith(
                                  color: context.colors.primary,
                                ),
                              ),
                              context.vS,
                              Text(
                                '0',
                                style: context.topology.textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: context.colors.primary,
                                ),
                              ),
                              context.vS,
                              Text(
                                'Job',
                                style: context.topology.textTheme.bodySmall?.copyWith(
                                  color: context.colors.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                context.vS,
                SizedBox(
                  width: double.infinity,
                  child: Card(
                    margin: EdgeInsets.zero,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
                    ),
                    elevation: 8,
                    color: context.colors.secondary,
                    // Light background for contrast
                    child: Stack(
                      children: [
                        // 🔵 Background decorative icon (overlayed)
                        Positioned(
                          top: -10,
                          right: -10,
                          child: Icon(
                            Icons.all_out,
                            size: 120,
                            color: context.colors.primary.withOpacity(0.08),
                          ),
                        ),

                        // 🔷 Colored side bar
                        Positioned(
                          left: 0,
                          top: 0,
                          bottom: 0,
                          width: 6,
                          child: Container(
                            decoration: BoxDecoration(
                              color: context.colors.primary,
                              borderRadius: const BorderRadius.only(
                                bottomLeft: Radius.circular(16),
                              ),
                            ),
                          ),
                        ),

                        // 🔤 Main content
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 24.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Overdue',
                                style: context.topology.textTheme.bodySmall?.copyWith(
                                  color: context.colors.primary,
                                ),
                              ),
                              context.vS,
                              Text(
                                '21,562',
                                style: context.topology.textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: context.colors.primary,
                                ),
                              ),
                              context.vS,
                              Text(
                                'Total Items',
                                style: context.topology.textTheme.bodySmall?.copyWith(
                                  color: context.colors.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                context.vXxl,
              ],
            ),
          ],
        );
  }

  Widget _buildIndicators() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16.0,
        mainAxisSpacing: 8.0,
        childAspectRatio: 4.0, // Wide rectangular indicators
      ),
      itemCount: _labels.length,
      itemBuilder: (context, index) {
        final isSelected = index == _touchedIndex;
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
          decoration: BoxDecoration(
            color: isSelected ? _colors[index].withOpacity(0.1) : Colors.transparent,
            borderRadius: BorderRadius.circular(8.0),
            border: isSelected ? Border.all(color: _colors[index], width: 1.5) : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(color: _colors[index], shape: BoxShape.circle),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${_labels[index]} (${_values[index]}%)',
                  maxLines: 3,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    color: isSelected ? _colors[index] : Colors.black87,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  List<PieChartSectionData> _getSections() {
    return List.generate(_values.length, (i) {
      final isTouched = i == _touchedIndex;
      final double radius = isTouched ? 70 : 60;
      final fontSize = isTouched ? 18.0 : 16.0;

      return PieChartSectionData(
        value: _values[i],
        color: _colors[i],
        title: '${_values[i]}%',
        titleStyle: TextStyle(fontSize: fontSize, color: Colors.white),
        radius: radius,
        showTitle: false,
      );
    });
  }
}
