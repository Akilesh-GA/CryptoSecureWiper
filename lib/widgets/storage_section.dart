import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:math';

class StorageSection extends StatefulWidget {
  final String label;
  final double total;
  final double used;
  final double free;
  final Color color;

  const StorageSection({
    super.key,
    required this.label,
    required this.total,
    required this.used,
    required this.free,
    required this.color,
  });

  @override
  _StorageSectionState createState() => _StorageSectionState();
}

class _StorageSectionState extends State<StorageSection>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  List<FlSpot> spots = [];
  final Random random = Random();

  @override
  void initState() {
    super.initState();

    // 🔹 Faster animation
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    )..addListener(() {
      setState(() {
        double progress = _animation.value;
        int totalPoints = 50;

        spots = List.generate(totalPoints + 1, (i) {
          double x = i * 2 / totalPoints;
          double targetY = widget.used * (i / totalPoints);

          // Zig-zag effect
          double fluctuation =
              (random.nextDouble() - 0.5) * (widget.total * 0.05);
          double y = (targetY * progress + fluctuation).clamp(0, widget.total);

          return FlSpot(x, y);
        });
      });
    });

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          widget.label,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 20),
        SizedBox(
          height: 200,
          child: LineChart(
            LineChartData(
              minY: 0,
              maxY: widget.total,
              titlesData: FlTitlesData(
                show: true,
                leftTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false)),
                bottomTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false)),
                topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 50,
                    interval: widget.total / 4,
                    getTitlesWidget: (value, meta) {
                      return Text(
                        "${value.toStringAsFixed(0)} GB",
                        style:
                        const TextStyle(color: Colors.white70, fontSize: 12),
                      );
                    },
                  ),
                ),
              ),
              gridData: FlGridData(show: false),
              borderData: FlBorderData(show: false),

              lineTouchData: LineTouchData(
                enabled: true,
                handleBuiltInTouches: true,
                touchTooltipData: LineTouchTooltipData(
                  getTooltipItems: (touchedSpots) {
                    if (touchedSpots.isEmpty) return <LineTooltipItem>[];
                    final spot = touchedSpots.first; // show only the first touched spot
                    return [
                      LineTooltipItem(
                        "${spot.y.toStringAsFixed(1)} GB",
                        const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ];
                  },
                ),
              ),

              lineBarsData: [
                // Glow layers
                for (double opacity in [0.1, 0.2, 0.3])
                  LineChartBarData(
                    spots: spots.isEmpty ? [FlSpot(0, 0)] : spots,
                    isCurved: true,
                    color: widget.color.withOpacity(opacity),
                    barWidth: 8,
                    isStrokeCapRound: true,
                    dotData: FlDotData(show: false),
                    belowBarData: BarAreaData(show: false),
                  ),
                // Main solid line
                LineChartBarData(
                  spots: spots.isEmpty ? [FlSpot(0, 0)] : spots,
                  isCurved: true,
                  color: widget.color,
                  barWidth: 4,
                  isStrokeCapRound: true,
                  dotData: FlDotData(show: false),
                  belowBarData: BarAreaData(
                    show: true,
                    gradient: LinearGradient(
                      colors: [
                        widget.color.withOpacity(0.3),
                        widget.color.withOpacity(0.0),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 30),
        const Divider(color: Colors.white24, thickness: 1, height: 40),
      ],
    );
  }
}
