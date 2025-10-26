import 'package:flutter/material.dart';

class CustomProgressBar extends StatelessWidget {
  final String label;
  final double value;
  final double total;
  final List<Color> colors;

  const CustomProgressBar({
    super.key,
    required this.label,
    required this.value,
    required this.total,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    final double ratio = total > 0 ? value / total : 0;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "$label: ${value.toStringAsFixed(2)} GB",
            style: const TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: ratio,
              minHeight: 10,
              backgroundColor: Colors.grey[800],
              valueColor: AlwaysStoppedAnimation<Color>(colors[0]),
            ),
          ),
        ],
      ),
    );
  }
}
