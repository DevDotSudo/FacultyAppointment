import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../shared/widgets/dialog_helper.dart';

class RequestDetailPage extends StatelessWidget {
  const RequestDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightGrayBg,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Back
            Row(
              children: [
                IconButton(
                  onPressed: () => context.pop(),
                  icon: const Icon(Icons.arrow_back_ios,
                      color: AppColors.primaryBlue, size: 18),
                ),
                GestureDetector(
                  onTap: () => context.pop(),
                  child: Text('Back',
                      style: GoogleFonts.inter(
                          fontSize: 14, color: AppColors.primaryBlue)),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Detail card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.cardWhite,
                border: Border.all(color: AppColors.borderGray),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Request Details',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                  ),
                  const Divider(),
                  const SizedBox(height: 4),
                  _detailRow('Student', 'John Dela Cruz'),
                  const SizedBox(height: 10),
                  _detailRow('Date & Time', 'Mar 27, 2025 \u00b7 10:00 AM'),
                  const SizedBox(height: 10),
                  _detailRow('Purpose',
                      'I would like to discuss my final project.'),
                  const SizedBox(height: 10),
                  _detailRow('Student ID', '202100123'),
                  const SizedBox(height: 10),
                  _detailRow('Email', 'john.delacruz@school.edu.ph'),
                  const SizedBox(height: 10),
                  _detailRow('Phone', '0912 345 6789'),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Accept / Reject buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      DialogHelper.showAcceptRequestModal(
                        context,
                        studentName: 'John Dela Cruz',
                        date: 'Mar 27, 2025',
                        time: '10:00 AM',
                        onConfirm: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Request accepted'),
                              backgroundColor: AppColors.statusAccepted,
                            ),
                          );
                        },
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.statusAccepted,
                    ),
                    child: const Text('Accept'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      DialogHelper.showRejectRequestModal(
                        context,
                        studentName: 'John Dela Cruz',
                        onConfirm: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Request rejected'),
                              backgroundColor: AppColors.statusRejected,
                            ),
                          );
                        },
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.statusRejected,
                    ),
                    child: const Text('Reject'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textMuted)),
        const Spacer(),
        SizedBox(
          width: 200,
          child: Text(value,
              style:
                  GoogleFonts.inter(fontSize: 14, color: AppColors.textDark),
              textAlign: TextAlign.right),
        ),
      ],
    );
  }
}