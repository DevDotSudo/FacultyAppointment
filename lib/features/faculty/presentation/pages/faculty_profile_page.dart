import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../shared/widgets/responsive_layout.dart';
import '../../../shared/widgets/sidebar_nav_widget.dart';
import '../../../shared/widgets/dialog_helper.dart';

class FacultyProfilePage extends StatelessWidget {
  const FacultyProfilePage({super.key});

  List<SidebarNavItem> _sidebarItems(BuildContext context) => [
        SidebarNavItem(label: 'Dashboard', icon: Icons.dashboard, onTap: () => context.goNamed('faculty-dashboard')),
        SidebarNavItem(label: 'Requests', icon: Icons.list_alt, onTap: () => context.goNamed('faculty-requests')),
        SidebarNavItem(label: 'Availability', icon: Icons.calendar_today, onTap: () => context.goNamed('faculty-availability')),
        SidebarNavItem(label: 'Profile', icon: Icons.person, isActive: true, onTap: () => context.goNamed('faculty-profile')),
      ];

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';

    return ResponsiveLayout(
      sidebarItems: _sidebarItems(context),
      onLogout: () => context.goNamed('login'),
      child: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance.collection('faculty').doc(uid).get(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;
          final fullName = data['full_name'] as String? ?? 'Faculty';
          final initials = fullName.split(' ').map((e) => e.isNotEmpty ? e[0] : '').take(2).join().toUpperCase();

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('My Profile', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textDark)),
              const SizedBox(height: 20),

              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.cardWhite,
                  border: Border.all(color: AppColors.borderGray),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: AppColors.primaryBlue,
                      child: Text(initials, style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () {},
                      child: Text('Change Photo', style: GoogleFonts.inter(fontSize: 13, color: AppColors.primaryBlue)),
                    ),
                    const Divider(),
                    const SizedBox(height: 16),

                    _profileField('Full Name', fullName),
                    const SizedBox(height: 14),
                    _profileField('Email', data['email'] as String? ?? ''),
                    const SizedBox(height: 14),
                    _profileField('Phone Number', data['phone'] as String? ?? ''),
                    const SizedBox(height: 14),
                    _profileField('Department', data['department'] as String? ?? ''),
                    const SizedBox(height: 14),
                    _profileField('Specialization', data['specialization'] as String? ?? ''),
                    const SizedBox(height: 14),
                    _profileField('Office Location', data['office_location'] as String? ?? ''),
                    const SizedBox(height: 20),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => DialogHelper.showUpdateProfileSuccessModal(context),
                        child: const Text('Update Profile'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _profileField(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textDark)),
        const SizedBox(height: 4),
        TextFormField(
          initialValue: value,
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: const BorderSide(color: AppColors.borderGray)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: const BorderSide(color: AppColors.borderGray)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          ),
          style: GoogleFonts.inter(fontSize: 14, color: AppColors.textDark),
        ),
      ],
    );
  }
}