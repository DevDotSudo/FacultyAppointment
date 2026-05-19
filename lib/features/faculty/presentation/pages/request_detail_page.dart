import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../shared/widgets/dialog_helper.dart';
import '../../../shared/widgets/skeleton_loader.dart';
import '../../domain/usecases/accept_request_usecase.dart';
import '../../domain/usecases/reject_request_usecase.dart';

class RequestDetailPage extends StatefulWidget {
  final String requestId;
  const RequestDetailPage({super.key, required this.requestId});

  @override
  State<RequestDetailPage> createState() => _RequestDetailPageState();
}

class _RequestDetailPageState extends State<RequestDetailPage> {
  final _acceptUseCase = AcceptRequestUseCase();
  final _rejectUseCase = RejectRequestUseCase();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final textColor = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final mutedColor = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final cardColor = isDark ? AppColors.darkCardBg : Colors.white;

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('appointment_requests')
          .doc(widget.requestId)
          .snapshots(),
      builder: (context, snap) {
        if (snap.hasError) {
          return Center(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Icon(Icons.error_outline_rounded, size: 48, color: AppColors.danger),
              const SizedBox(height: 12),
              Text('Failed to load request.',
                  style: GoogleFonts.inter(fontSize: 14, color: AppColors.danger)),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () => context.go('/faculty/requests'),
                icon: const Icon(Icons.arrow_back_rounded, size: 16),
                label: const Text('Back to Requests'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                ),
              ),
            ]),
          );
        }
        
        if (snap.connectionState == ConnectionState.waiting) {
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
                    color: cardColor,
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
        
        if (!snap.hasData || !snap.data!.exists) {
          return Center(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Icon(Icons.search_off_rounded, size: 48, color: mutedColor),
              const SizedBox(height: 12),
              Text('Request not found.',
                  style: GoogleFonts.inter(fontSize: 14, color: mutedColor)),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () => context.go('/faculty/requests'),
                icon: const Icon(Icons.arrow_back_rounded, size: 16),
                label: const Text('Back to Requests'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                ),
              ),
            ]),
          );
        }

        final doc = snap.data!;
        final d = doc.data() as Map<String, dynamic>;
        final studentName = d['student_name'] as String? ?? 'Student';
        final studentInitials = studentName.split(' ').map((e) => e.isNotEmpty ? e[0] : '').take(2).join().toUpperCase();
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
                onTap: () => context.go('/faculty/requests'),
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.arrow_back_rounded, color: AppColors.primary, size: 18),
                      const SizedBox(width: 6),
                      Text('Back to Requests',
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
                    child: Text('Request Details',
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
                  color: cardColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: borderColor),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Student info with avatar
                    Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: AppColors.accent.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Center(
                            child: Text(
                              studentInitials,
                              style: GoogleFonts.inter(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.accent,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Student',
                                  style: GoogleFonts.inter(
                                      fontSize: 11, color: mutedColor, fontWeight: FontWeight.w500)),
                              const SizedBox(height: 2),
                              Text(studentName,
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
                      value: '$date · $time',
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
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Action buttons (only show for pending status)
              if (status == 'pending')
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          DialogHelper.showAcceptRequestModal(
                            context,
                            studentName: studentName,
                            date: date,
                            time: time,
                            onConfirm: () async {
                              await _acceptUseCase.call(
                                requestId: doc.id,
                                studentId: d['student_id'] as String? ?? '',
                              );
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text('Request accepted ✓'),
                                      backgroundColor: AppColors.statusAccepted),
                                );
                              }
                            },
                          );
                        },
                        icon: const Icon(Icons.check_circle_rounded, size: 18),
                        label: const Text('Accept'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.statusAccepted,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          DialogHelper.showRejectRequestModal(
                            context,
                            studentName: studentName,
                            onConfirm: () async {
                              await _rejectUseCase.call(
                                requestId: doc.id,
                                studentId: d['student_id'] as String? ?? '',
                              );
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text('Request rejected'),
                                      backgroundColor: AppColors.statusRejected),
                                );
                              }
                            },
                          );
                        },
                        icon: const Icon(Icons.cancel_rounded, size: 18),
                        label: const Text('Reject'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.statusRejected,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              else
                // Status message for non-pending requests
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: _statusColor(status).withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: _statusColor(status).withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline_rounded, size: 18, color: _statusColor(status)),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _statusMessage(status),
                          style: GoogleFonts.inter(
                            fontSize: 13,
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
      default:
        return AppColors.statusPending;
    }
  }

  String _statusMessage(String status) {
    switch (status.toLowerCase()) {
      case 'accepted':
        return 'This request has been accepted.';
      case 'rejected':
        return 'This request has been rejected.';
      case 'cancelled':
        return 'This request was cancelled by the student.';
      case 'completed':
        return 'This appointment has been completed.';
      default:
        return 'This request is awaiting your response.';
    }
  }
}
