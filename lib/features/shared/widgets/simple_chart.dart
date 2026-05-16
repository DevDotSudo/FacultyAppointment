import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';

/// A simple horizontal bar chart widget for dashboard stats.
class ChartBarData {
  final String label;
  final double value;
  final Color color;
  const ChartBarData(this.label, this.value, this.color);
}

class SimpleBarChart extends StatelessWidget {
  final List<ChartBarData> bars;

  const SimpleBarChart({super.key, required this.bars});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final maxValue = bars.fold<double>(0, (max, b) => b.value > max ? b.value : max);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: bars.map((bar) {
        final fraction = maxValue > 0 ? bar.value / maxValue : 0.0;
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            children: [
              SizedBox(
                width: 70,
                child: Text(bar.label,
                  style: GoogleFonts.inter(fontSize: 11, color: isDark ? AppColors.darkMuted : AppColors.textSecondary)),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: fraction,
                    backgroundColor: isDark ? AppColors.darkBorder : AppColors.dividerLight,
                    color: bar.color,
                    minHeight: 8,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 30,
                child: Text('${bar.value.toInt()}',
                  style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.darkText : AppColors.textPrimary)),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

