import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../shared/widgets/dialog_helper.dart';
import '../../domain/usecases/accept_request_usecase.dart';
import '../../domain/usecases/reject_request_usecase.dart';

class RequestDetailPage extends StatefulWidget {
  const RequestDetailPage({super.key});

  @override
  State<RequestDetailPage> createState() => _RequestDetailPageState();
}

class _RequestDetailPageState extends State<RequestDetailPage> {
  final _acceptUseCase = AcceptRequestUseCase();
  final _rejectUseCase = RejectRequestUseCase();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? AppColors.darkCard : AppColors.cardLight;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.borderGray;
    final textColor = isDark ? AppColors.darkText : AppColors.textDark;
    final mutedColor = isDark ? AppColors.darkMuted : AppColors.textMuted;
    final secondaryColor = isDark ? AppColors.darkMuted : AppColors.textSecondary;

    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';

    return StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('appointment_requests')
            .where('faculty_id', isEqualTo: uid)
            .where('status', isEqualTo: 'pending')
            .orderBy('created_at', descending: true)
            .limit(1)
            .snapshots(),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snap.hasData || snap.data!.docs.isEmpty) {
            return Center(
              child: Text('No pending requests', style: GoogleFonts.inter(color: mutedColor, fontSize: 16)),
            );
          }

          final doc = snap.data!.docs.first;
          final d = doc.data() as Map<String, dynamic>;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Request Details',
                  style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.bold, color: textColor),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: cardColor,
                    border: Border.all(color: borderColor),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _detailRow('Student', d['student_name'] as String? ?? 'N/A', mutedColor, secondaryColor),
                      const SizedBox(height: 10),
                      _detailRow('Date & Time', '${d['date'] ?? ''} · ${d['time'] ?? ''}', mutedColor, secondaryColor),
                      const SizedBox(height: 10),
                      _detailRow('Purpose', d['purpose'] as String? ?? 'N/A', mutedColor, secondaryColor),
                      const SizedBox(height: 10),
                      _detailRow('Status', d['status'] as String? ?? 'pending', mutedColor, AppColors.warning),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          DialogHelper.showAcceptRequestModal(
                            context,
                            studentName: d['student_name'] as String? ?? 'Student',
                            date: d['date'] as String? ?? '',
                            time: d['time'] as String? ?? '',
                            onConfirm: () async {
                              await _acceptUseCase.call(
                                requestId: doc.id,
                                studentId: d['student_id'] as String? ?? '',
                              );
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Request accepted'), backgroundColor: AppColors.statusAccepted),
                                );
                              }
                            },
                          );
                        },
                        style: ElevatedButton.styleFrom(backgroundColor: AppColors.statusAccepted),
                        child: const Text('Accept'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          DialogHelper.showRejectRequestModal(
                            context,
                            studentName: d['student_name'] as String? ?? 'Student',
                            onConfirm: () async {
                              await _rejectUseCase.call(
                                requestId: doc.id,
                                studentId: d['student_id'] as String? ?? '',
                              );
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Request rejected'), backgroundColor: AppColors.statusRejected),
                                );
                              }
                            },
                          );
                        },
                        style: ElevatedButton.styleFrom(backgroundColor: AppColors.statusRejected),
                        child: const Text('Reject'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      );
  }

  Widget _detailRow(String label, String value, Color mutedColor, Color valueColor) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: mutedColor)),
        const Spacer(),
        SizedBox(
          width: 200,
          child: Text(value,
              style: GoogleFonts.inter(fontSize: 14, color: valueColor),
              textAlign: TextAlign.right),
        ),
      ],
    );
  }
}