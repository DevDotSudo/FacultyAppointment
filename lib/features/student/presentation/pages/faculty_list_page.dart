import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../shared/widgets/responsive_layout.dart';
import '../../../shared/widgets/sidebar_nav_widget.dart';
import '../cubit/student_cubit.dart';
import '../cubit/student_state.dart';

class FacultyListPage extends StatelessWidget {
  const FacultyListPage({super.key});

  List<SidebarNavItem> _sidebarItems(BuildContext context) => [
        SidebarNavItem(
          label: 'Dashboard',
          icon: Icons.dashboard,
          onTap: () => context.goNamed('student-dashboard'),
        ),
        SidebarNavItem(
          label: 'Faculty',
          icon: Icons.school,
          isActive: true,
          onTap: () => context.goNamed('student-faculty'),
        ),
        SidebarNavItem(
          label: 'My Appointments',
          icon: Icons.calendar_today,
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
      child: BlocBuilder<StudentCubit, StudentState>(
        builder: (context, state) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Faculty List',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                decoration: InputDecoration(
                  hintText: 'Search faculty...',
                  prefixIcon: const Icon(Icons.search, color: AppColors.textMuted),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: AppColors.borderGray),
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
              const SizedBox(height: 16),
              if (state is StudentLoaded) ...[
                ...state.facultyList.map((faculty) => Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.cardWhite,
                        border: Border.all(color: AppColors.borderGray),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 24,
                            backgroundColor: AppColors.primaryBlue,
                            child: Text(
                              faculty.name.split(' ').map((e) => e.isNotEmpty ? e[0] : '').take(2).join().toUpperCase(),
                              style: GoogleFonts.inter(color: AppColors.white, fontSize: 14),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  faculty.name,
                                  style: GoogleFonts.inter(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textDark,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  faculty.department,
                                  style: GoogleFonts.inter(
                                    fontSize: 13,
                                    color: AppColors.textMuted,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          OutlinedButton(
                            onPressed: () => context.goNamed('student-book-appointment'),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: AppColors.statusAccepted),
                              foregroundColor: AppColors.statusAccepted,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(6),
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                            ),
                            child: const Text('View Availability'),
                          ),
                        ],
                      ),
                    )),
              ] else if (state is StudentLoading) ...[
                const Center(child: CircularProgressIndicator()),
              ],
            ],
          );
        },
      ),
    );
  }
}