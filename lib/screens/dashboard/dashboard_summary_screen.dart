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
  final List<String> _value = [
    '567',
    '229',
    '2032',
    '176',
    '596',
    '3053',
    '6595',
    '5949',
    '25364',
    '5644',
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
    return (context.isTablet) ? _webView() : _mobileView();
  }

  Widget _webView() {
    return SingleChildScrollView(
      child: Padding(
        padding: context.paddingHorizontal,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            context.vS,
            Text(
              'Report Status',
              style: context.topology.textTheme.titleMedium?.copyWith(
                color: context.colors.primary,
              ),
            ),
            context.vS,
            Container(
              width: double.infinity,
              child: IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(child: _buildCard(context, 'Active Location', '1247', 'Location')),
                    context.hS,
                    Expanded(
                      child: _buildCard(context, 'Items Under Management', '50212', 'Total Items'),
                    ),
                    context.hS,
                    Expanded(child: _buildCard(context, 'Jobs This Month', '0', 'Jobs')),
                    context.hS,
                    Expanded(child: _buildCard(context, 'Jobs Next Month', '0', 'Jobs')),
                    context.hS,
                    Expanded(child: _buildCard(context, 'Overdue', '23154', 'Total Items')),
                  ],
                ),
              ),
            ),
            context.vM,
            Text(
              'Status Comparison',
              style: context.topology.textTheme.titleMedium?.copyWith(
                color: context.colors.primary,
              ),
            ),
            context.vS,
            Row(
              crossAxisAlignment: CrossAxisAlignment.start, // Align to top
              children: [
                Expanded(
                  child: Container(
                    alignment: Alignment.topCenter,
                    padding: const EdgeInsets.only(top: 60.0),
                    // Push pie chart down to center with indicators
                    child: AspectRatio(
                      aspectRatio: 3.5, // Make it more square for better centering
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
                ),
                context.hL,
                Expanded(child: _buildIndicators()),
              ],
            ),
            context.vXxl,
          ],
        ),
      ),
    );
  }

  Widget _buildCard(BuildContext context, String title, String value, String subtitle) {
    return Card(
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 8,
      color: context.colors.secondary,
      child: Padding(
        padding: context.paddingAll,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: context.topology.textTheme.bodyMedium?.copyWith(color: context.colors.primary),
            ),
            context.vS,
            Text(
              value,
              style: context.topology.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: context.colors.primary,
              ),
            ),
            context.vS,
            Text(
              subtitle,
              style: context.topology.textTheme.bodyMedium?.copyWith(color: context.colors.primary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _mobileView() {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          context.vS,

          IntrinsicHeight(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: Card(
                    margin: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 8,
                    color: context.colors.secondary,
                    child: Padding(
                      padding: context.paddingAll,
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
                            '3',
                            style: context.topology.textTheme.titleSmall?.copyWith(
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
                  ),
                ),
                context.hS, // Add spacing between cards
                Expanded(
                  child: Card(
                    margin: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 8,
                    color: context.colors.secondary,
                    child: Padding(
                      padding: context.paddingAll,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Active Locations', // Different content for second card
                            style: context.topology.textTheme.bodySmall?.copyWith(
                              color: context.colors.primary,
                            ),
                          ),
                          context.vS,
                          Text(
                            '1,247', // Different value
                            style: context.topology.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: context.colors.primary,
                            ),
                          ),
                          context.vS,
                          Text(
                            'Locations',
                            style: context.topology.textTheme.bodySmall?.copyWith(
                              color: context.colors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ), // Cards Section

          context.vS,

          IntrinsicHeight(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: Card(
                    margin: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 8,
                    color: context.colors.secondary,
                    child: Padding(
                      padding: context.paddingAll,
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
                            '100',
                            style: context.topology.textTheme.titleSmall?.copyWith(
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
                  ),
                ),
                context.hS, // Add spacing between cards
                Expanded(
                  child: Card(
                    margin: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 8,
                    color: context.colors.secondary,
                    child: Padding(
                      padding: context.paddingAll,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Jobs Next Month', // Different content for second card
                            style: context.topology.textTheme.bodySmall?.copyWith(
                              color: context.colors.primary,
                            ),
                          ),
                          context.vS,
                          Text(
                            '500', // Different value
                            style: context.topology.textTheme.titleSmall?.copyWith(
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
                  ),
                ),
              ],
            ),
          ), // Cards Section

          context.vS,

          SizedBox(
            width: double.infinity,
            child: Card(
              margin: EdgeInsets.zero,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
                          style: context.topology.textTheme.titleSmall?.copyWith(
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
          context.vM,
          Text(
            'Report Status',
            style: context.topology.textTheme.titleSmall?.copyWith(color: context.colors.primary),
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
                context.vS,
                // Indicators/Legend - This will show ALL items without scrolling
                _buildIndicators(),
              ],
            ),
          ),
          context.vXxl,
        ],
      ),
    );
  }

  Widget _buildIndicators() {
    return (context.isTablet)
        ? Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (int i = 0; i < _labels.length; i += 2)
              Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: Row(
                  children: [
                    Expanded(child: _buildIndicatorItem(i)),
                    const SizedBox(width: 16),
                    if (i + 1 < _labels.length)
                      Expanded(child: _buildIndicatorItem(i + 1))
                    else
                      const Expanded(child: SizedBox()),
                  ],
                ),
              ),
          ],
        )
        : Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (int i = 0; i < _labels.length; i += 2)
              Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: Row(
                  children: [
                    Expanded(child: _buildIndicatorItem(i)),
                    const SizedBox(width: 16),
                    if (i + 1 < _labels.length)
                      Expanded(child: _buildIndicatorItem(i + 1))
                    else
                      const Expanded(child: SizedBox()),
                  ],
                ),
              ),
          ],
        );
  }

  Widget _buildIndicatorItem(int index) {
    final isSelected = index == _touchedIndex;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: isSelected ? _colors[index].withOpacity(0.1) : Colors.transparent,
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(color: isSelected ? _colors[index] : Colors.transparent, width: 1.5),
      ),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(color: _colors[index], shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${_value[index]}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.topology.textTheme.titleSmall?.copyWith(
                    color: isSelected ? _colors[index] : context.colors.primary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${_labels[index]} (${_values[index]}%)',
                  maxLines: 2,
                  style: context.topology.textTheme.bodySmall?.copyWith(
                    color: isSelected ? _colors[index] : context.colors.primary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
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
