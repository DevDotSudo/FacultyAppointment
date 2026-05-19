import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';

class AppointmentPieChart extends StatefulWidget {
  final int pending;
  final int approved;
  final int rejected;
  final int completed;
  final int cancelled;

  const AppointmentPieChart({
    super.key,
    required this.pending,
    required this.approved,
    required this.rejected,
    required this.completed,
    this.cancelled = 0,
  });

  @override
  State<AppointmentPieChart> createState() => _AppointmentPieChartState();
}

class _AppointmentPieChartState extends State<AppointmentPieChart> {
  int _touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final total = widget.pending + widget.approved + widget.rejected + widget.completed + widget.cancelled;

    if (total == 0) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: Text('No data yet',
              style: GoogleFonts.inter(
                  color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary)),
        ),
      );
    }

    final sections = <_Seg>[
      if (widget.pending > 0) _Seg('Pending', widget.pending, AppColors.statusPending),
      if (widget.approved > 0) _Seg('Approved', widget.approved, AppColors.statusAccepted),
      if (widget.completed > 0) _Seg('Completed', widget.completed, const Color(0xFF6366F1)),
      if (widget.rejected > 0) _Seg('Rejected', widget.rejected, AppColors.statusRejected),
      if (widget.cancelled > 0) _Seg('Cancelled', widget.cancelled, const Color(0xFF94A3B8)),
    ];

    return Row(children: [
      SizedBox(
        width: 120,
        height: 120,
        child: PieChart(PieChartData(
          pieTouchData: PieTouchData(
            touchCallback: (event, response) {
              setState(() {
                _touchedIndex = (!event.isInterestedForInteractions ||
                        response?.touchedSection == null)
                    ? -1
                    : response!.touchedSection!.touchedSectionIndex;
              });
            },
          ),
          borderData: FlBorderData(show: false),
          sectionsSpace: 2,
          centerSpaceRadius: 30,
          sections: sections.asMap().entries.map((e) {
            final touched = e.key == _touchedIndex;
            return PieChartSectionData(
              color: e.value.color,
              value: e.value.count.toDouble(),
              title: touched ? '${(e.value.count / total * 100).toStringAsFixed(0)}%' : '',
              radius: touched ? 30 : 22,
              titleStyle: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white),
            );
          }).toList(),
        )),
      ),
      const SizedBox(width: 16),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: sections.map((s) {
            final pct = (s.count / total * 100).toStringAsFixed(1);
            return Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(children: [
                Container(width: 10, height: 10,
                    decoration: BoxDecoration(color: s.color, borderRadius: BorderRadius.circular(3))),
                const SizedBox(width: 8),
                Expanded(child: Text(s.label,
                    style: GoogleFonts.inter(fontSize: 12,
                        color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary))),
                Text('${s.count}',
                    style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600,
                        color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary)),
                const SizedBox(width: 4),
                Text('($pct%)',
                    style: GoogleFonts.inter(fontSize: 11,
                        color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary)),
              ]),
            );
          }).toList(),
        ),
      ),
    ]);
  }
}

class _Seg {
  final String label;
  final int count;
  final Color color;
  const _Seg(this.label, this.count, this.color);
}
