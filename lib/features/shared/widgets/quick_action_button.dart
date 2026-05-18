import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/utils/responsive.dart';

class QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color color;

  const QuickActionButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return SizedBox(
      width: double.infinity,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 10,
          ),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: color.withValues(alpha: 0.2), width: 0.5),
          ),
          child: Row(
            children: [
              Icon(icon, size: 18, color: color),
              const SizedBox(width: 10),
              Text(label,
                style: GoogleFonts.inter(
                  fontSize: Responsive.body(screenWidth).fontSize,
                  fontWeight: FontWeight.w500,
                  color: color)),
            ],
          ),
        ),
      ),
    );
  }
}