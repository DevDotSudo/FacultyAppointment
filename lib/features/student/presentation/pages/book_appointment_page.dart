import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../shared/widgets/dialog_helper.dart';
import '../../../shared/widgets/responsive_layout.dart';
import '../../../shared/widgets/sidebar_nav_widget.dart';

class BookAppointmentPage extends StatefulWidget {
  const BookAppointmentPage({super.key});

  @override
  State<BookAppointmentPage> createState() => _BookAppointmentPageState();
}

class _BookAppointmentPageState extends State<BookAppointmentPage> {
  final _purposeController = TextEditingController(
    text: 'I would like to discuss my final project.',
  );
  String _selectedFaculty = 'Dr. Maria Santos';
  String _selectedTime = '10:00 AM';
  final String _selectedDate = '03/27/2025';

  @override
  void dispose() {
    _purposeController.dispose();
    super.dispose();
  }

  List<SidebarNavItem> _sidebarItems(BuildContext context) => [
        SidebarNavItem(
          label: 'Dashboard',
          icon: Icons.dashboard,
          onTap: () => context.goNamed('student-dashboard'),
        ),
        SidebarNavItem(
          label: 'Faculty',
          icon: Icons.school,
          onTap: () => context.goNamed('student-faculty'),
        ),
        SidebarNavItem(
          label: 'My Appointments',
          icon: Icons.calendar_today,
          isActive: true,
          onTap: () => context.goNamed('student-my-appointments'),
        ),
        SidebarNavItem(
          label: 'Profile',
          icon: Icons.person,
          onTap: () => context.goNamed('student-profile'),
        ),
      ];

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      sidebarItems: _sidebarItems(context),
      onLogout: () => context.goNamed('login'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Back button
          Row(
            children: [
              IconButton(
                onPressed: () => context.pop(),
                icon: const Icon(Icons.arrow_back_ios,
                    color: AppColors.primaryBlue, size: 18),
                constraints: const BoxConstraints(),
                padding: EdgeInsets.zero,
              ),
              const SizedBox(width: 4),
              GestureDetector(
                onTap: () => context.pop(),
                child: Text(
                  'Back',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: AppColors.primaryBlue,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          Text(
            'Book Appointment',
            style: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 20),

          // Form card
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
                // Faculty
                Text(
                  'Faculty',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 4),
                DropdownButtonFormField<String>(
                  initialValue: _selectedFaculty,
                  items: ['Dr. Maria Santos', 'Dr. Michael Brown', 'Prof. Ana Reyes']
                      .map((f) => DropdownMenuItem(value: f, child: Text(f)))
                      .toList(),
                  onChanged: (v) => setState(() => _selectedFaculty = v ?? _selectedFaculty),
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                      borderSide: const BorderSide(color: AppColors.borderGray),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  ),
                ),
                const SizedBox(height: 12),

                // Date & Time row
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Date',
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textDark,
                            ),
                          ),
                          const SizedBox(height: 4),
                          TextFormField(
                            decoration: InputDecoration(
                              hintText: '03/27/2025',
                              suffixIcon: const Icon(Icons.calendar_today,
                                  size: 18, color: AppColors.textMuted),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(6),
                                borderSide:
                                    const BorderSide(color: AppColors.borderGray),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 12),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Time',
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textDark,
                            ),
                          ),
                          const SizedBox(height: 4),
                          DropdownButtonFormField<String>(
                            initialValue: _selectedTime,
                            items: ['9:00 AM', '10:00 AM', '11:00 AM', '1:00 PM', '2:00 PM', '3:00 PM']
                                .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                                .toList(),
                            onChanged: (v) => setState(() => _selectedTime = v ?? _selectedTime),
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(6),
                                borderSide:
                                    const BorderSide(color: AppColors.borderGray),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 12),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Purpose
                Text(
                  'Purpose',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 4),
                TextFormField(
                  controller: _purposeController,
                  maxLines: 4,
                  decoration: InputDecoration(
                    hintText: 'Enter purpose...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                      borderSide: const BorderSide(color: AppColors.borderGray),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 12),
                  ),
                ),
                const SizedBox(height: 20),

                // Submit
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      DialogHelper.showConfirmSubmitModal(
                        context,
                        facultyName: _selectedFaculty,
                        date: _selectedDate,
                        time: _selectedTime,
                        onConfirm: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Appointment submitted successfully!'),
                              backgroundColor: AppColors.statusAccepted,
                            ),
                          );
                        },
                      );
                    },
                    child: const Text('Submit Appointment'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}