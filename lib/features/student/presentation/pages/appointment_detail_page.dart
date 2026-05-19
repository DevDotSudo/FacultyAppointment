import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../shared/widgets/skeleton_loader.dart';

class AppointmentDetailPage extends StatelessWidget {
  final String appointmentId;
  const AppointmentDetailPage({super.key, required this.appointmentId});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final mutedColor = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final cardBg = isDark ? AppColors.darkCardBg : Colors.white;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;

    if (appointmentId.isEmpty) {
      return Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.error_outline_rounded, size: 48, color: mutedColor),
          const SizedBox(height: 12),
          Text('No appointment selected.',
              style: GoogleFonts.inter(fontSize: 14, color: mutedColor)),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => context.go('/student/my-appointments'),
            icon: const Icon(Icons.arrow_back_rounded, size: 16),
            label: const Text('Back to Appointments'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
          ),
        ]),
      );
    }

    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance
          .collection('appointment_requests')
          .doc(appointmentId)
          .get(),
      builder: (context, snap) {
        if (snap.hasError) {
          return Center(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Icon(Icons.error_outline_rounded, size: 48, color: AppColors.danger),
              const SizedBox(height: 12),
              Text('Failed to load appointment.',
                  style: GoogleFonts.inter(fontSize: 14, color: AppColors.danger)),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () => context.go('/student/my-appointments'),
                icon: const Icon(Icons.arrow_back_rounded, size: 16),
                label: const Text('Back to Appointments'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                ),
              ),
            ]),
          );
        }
        
        if (!snap.hasData) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonLoader(width: 100, height: 20, borderRadius: BorderRadius.circular(4)),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: borderColor),
                  ),
                  child: Column(
                    children: [
                      SkeletonLoader(width: double.infinity, height: 16, borderRadius: BorderRadius.circular(4)),
                      const SizedBox(height: 12),
                      SkeletonLoader(width: double.infinity, height: 16, borderRadius: BorderRadius.circular(4)),
                      const SizedBox(height: 12),
                      SkeletonLoader(width: double.infinity, height: 16, borderRadius: BorderRadius.circular(4)),
                    ],
                  ),
                ),
              ],
            ),
          );
        }
        
        if (!snap.data!.exists) {
          return Center(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Icon(Icons.search_off_rounded, size: 48, color: mutedColor),
              const SizedBox(height: 12),
              Text('Appointment not found.',
                  style: GoogleFonts.inter(fontSize: 14, color: mutedColor)),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () => context.go('/student/my-appointments'),
                icon: const Icon(Icons.arrow_back_rounded, size: 16),
                label: const Text('Back to Appointments'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                ),
              ),
            ]),
          );
        }

        final d = snap.data!.data() as Map<String, dynamic>;
        final faculty = d['faculty_name'] as String? ?? 'Faculty';
        final facultyInitials = d['faculty_initials'] as String? ?? faculty.substring(0, 1).toUpperCase();
        final date = d['date'] as String? ?? '';
        final time = d['time'] as String? ?? '';
        final purpose = d['purpose'] as String? ?? '';
        final status = d['status'] as String? ?? 'pending';

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Back button
              InkWell(
                onTap: () => context.go('/student/my-appointments'),
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.arrow_back_rounded, color: AppColors.primary, size: 18),
                      const SizedBox(width: 6),
                      Text('Back to Appointments',
                          style: GoogleFonts.inter(
                              fontSize: 13,
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Header with status
              Row(
                children: [
                  Expanded(
                    child: Text('Appointment Details',
                        style: GoogleFonts.inter(
                            fontSize: 20, fontWeight: FontWeight.bold, color: textColor)),
                  ),
                  _statusBadge(status),
                ],
              ),
              const SizedBox(height: 20),

              // Main card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: borderColor),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Faculty info with avatar
                    Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Center(
                            child: Text(
                              facultyInitials,
                              style: GoogleFonts.inter(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Faculty',
                                  style: GoogleFonts.inter(
                                      fontSize: 11, color: mutedColor, fontWeight: FontWeight.w500)),
                              const SizedBox(height: 2),
                              Text(faculty,
                                  style: GoogleFonts.inter(
                                      fontSize: 15, fontWeight: FontWeight.w600, color: textColor)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const Divider(height: 1),
                    const SizedBox(height: 20),

                    // Date & Time
                    _infoRow(
                      icon: Icons.calendar_today_rounded,
                      label: 'Date & Time',
                      value: [if (date.isNotEmpty) date, if (time.isNotEmpty) time].join(' · '),
                      textColor: textColor,
                      mutedColor: mutedColor,
                    ),
                    const SizedBox(height: 16),

                    // Purpose
                    _infoRow(
                      icon: Icons.description_rounded,
                      label: 'Purpose',
                      value: purpose.isNotEmpty ? purpose : 'No purpose specified',
                      textColor: textColor,
                      mutedColor: mutedColor,
                    ),
                    const SizedBox(height: 16),

                    // Status message
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: _statusColor(status).withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: _statusColor(status).withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline_rounded, size: 16, color: _statusColor(status)),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _statusMessage(status),
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color: _statusColor(status),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _infoRow({
    required IconData icon,
    required String label,
    required String value,
    required Color textColor,
    required Color mutedColor,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(icon, size: 14, color: AppColors.primary),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: GoogleFonts.inter(
                      fontSize: 11, color: mutedColor, fontWeight: FontWeight.w500)),
              const SizedBox(height: 3),
              Text(value,
                  style: GoogleFonts.inter(fontSize: 14, color: textColor)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _statusBadge(String status) {
    final color = _statusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        status.toUpperCase(),
        style: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: color,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return AppColors.statusPending;
      case 'accepted':
        return AppColors.statusAccepted;
      case 'rejected':
        return AppColors.statusRejected;
      case 'cancelled':
        return AppColors.danger;
      case 'completed':
        return AppColors.success;
      case 'rescheduled':
        return AppColors.warning;
      default:
        return AppColors.statusPending;
    }
  }

  String _statusMessage(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'Waiting for faculty response.';
      case 'accepted':
        return 'Your appointment has been accepted.';
      case 'rejected':
        return 'Your appointment was rejected.';
      case 'cancelled':
        return 'This appointment was cancelled.';
      case 'completed':
        return 'This appointment has been completed.';
      case 'rescheduled':
        return 'This appointment has been rescheduled.';
      default:
        return '';
    }
  }
}

