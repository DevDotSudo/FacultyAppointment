import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../shared/widgets/responsive_layout.dart';
import '../../../shared/widgets/sidebar_nav_widget.dart';
import '../../../shared/widgets/dialog_helper.dart';
import '../../domain/usecases/manage_availability_usecase.dart';

class ManageAvailabilityPage extends StatefulWidget {
  const ManageAvailabilityPage({super.key});

  @override
  State<ManageAvailabilityPage> createState() => _ManageAvailabilityPageState();
}

class _ManageAvailabilityPageState extends State<ManageAvailabilityPage> {
  final ManageAvailabilityUseCase _useCase = ManageAvailabilityUseCase();

  List<SidebarNavItem> _sidebarItems(BuildContext context) => [
        SidebarNavItem(label: 'Dashboard', icon: Icons.dashboard, onTap: () => context.goNamed('faculty-dashboard')),
        SidebarNavItem(label: 'Requests', icon: Icons.list_alt, onTap: () => context.goNamed('faculty-requests')),
        SidebarNavItem(label: 'Availability', icon: Icons.calendar_today, isActive: true, onTap: () => context.goNamed('faculty-availability')),
        SidebarNavItem(label: 'Profile', icon: Icons.person, onTap: () => context.goNamed('faculty-profile')),
      ];

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';

    return ResponsiveLayout(
      sidebarItems: _sidebarItems(context),
      onLogout: () => context.goNamed('login'),
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('faculty_availability')
            .where('faculty_id', isEqualTo: uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          var schedule = <Map<String, dynamic>>[];
          if (snapshot.hasData) {
            schedule = snapshot.data!.docs.map((doc) {
              final d = doc.data() as Map<String, dynamic>;
              return {'id': doc.id, ...d};
            }).toList();
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text('Manage Availability', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textDark)),
                  const Spacer(),
                  ElevatedButton(
                    onPressed: () {
                      DialogHelper.showAddScheduleModal(
                        context,
                        onSave: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Schedule added'), backgroundColor: AppColors.statusAccepted),
                          );
                        },
                      );
                    },
                    style: ElevatedButton.styleFrom(minimumSize: const Size(140, 36)),
                    child: const Text('+ Add Schedule'),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              Container(
                decoration: BoxDecoration(
                  color: AppColors.cardWhite,
                  border: Border.all(color: AppColors.borderGray),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: const BoxDecoration(
                        border: Border(bottom: BorderSide(color: AppColors.borderGray)),
                        color: AppColors.lightGrayBg,
                      ),
                      child: Row(
                        children: [
                          Expanded(flex: 2, child: _headerText('Day')),
                          Expanded(flex: 2, child: _headerText('Start Time')),
                          Expanded(flex: 2, child: _headerText('End Time')),
                          Expanded(flex: 1, child: _headerText('Actions')),
                        ],
                      ),
                    ),
                    if (schedule.isEmpty)
                      Padding(
                        padding: const EdgeInsets.all(32),
                        child: Center(child: Text('No schedule set. Click + Add Schedule to add one.', style: GoogleFonts.inter(color: AppColors.textMuted))),
                      )
                    else
                      ...schedule.asMap().entries.map((entry) {
                        final i = entry.key;
                        final row = entry.value;
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            border: i < schedule.length - 1 ? const Border(bottom: BorderSide(color: AppColors.borderGray)) : null,
                          ),
                          child: Row(
                            children: [
                              Expanded(flex: 2, child: _bodyText(row['day'] as String? ?? '')),
                              Expanded(flex: 2, child: _bodyText(row['start_time'] as String? ?? '')),
                              Expanded(flex: 2, child: _bodyText(row['end_time'] as String? ?? '')),
                              Expanded(
                                flex: 1,
                                child: Row(
                                  children: [
                                    IconButton(
                                      onPressed: () {
                                        DialogHelper.showAddScheduleModal(
                                          context,
                                          initialDay: row['day'] as String?,
                                          initialStart: row['start_time'] as String?,
                                          initialEnd: row['end_time'] as String?,
                                          onSave: () async {
                                            try {
                                              await _useCase.updateSchedule(
                                                scheduleId: row['id'] as String,
                                                day: row['day'] as String,
                                                startTime: row['start_time'] as String,
                                                endTime: row['end_time'] as String,
                                              );
                                              if (context.mounted) {
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  const SnackBar(content: Text('Schedule updated'), backgroundColor: AppColors.primaryBlue),
                                                );
                                              }
                                            } catch (e) {
                                              if (context.mounted) {
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
                                                );
                                              }
                                            }
                                          },
                                        );
                                      },
                                      icon: const Icon(Icons.edit, color: AppColors.primaryBlue, size: 18),
                                      constraints: const BoxConstraints(),
                                      padding: EdgeInsets.zero,
                                    ),
                                    const SizedBox(width: 8),
                                    IconButton(
                                      onPressed: () {
                                        DialogHelper.showDeleteScheduleModal(
                                          context,
                                          day: row['day'] as String? ?? '',
                                          startTime: row['start_time'] as String? ?? '',
                                          endTime: row['end_time'] as String? ?? '',
                                          onConfirm: () async {
                                            try {
                                              await _useCase.deleteSchedule(scheduleId: row['id'] as String);
                                              if (context.mounted) {
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  const SnackBar(content: Text('Schedule deleted'), backgroundColor: AppColors.statusRejected),
                                                );
                                              }
                                            } catch (e) {
                                              if (context.mounted) {
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
                                                );
                                              }
                                            }
                                          },
                                        );
                                      },
                                      icon: const Icon(Icons.delete, color: AppColors.statusRejected, size: 18),
                                      constraints: const BoxConstraints(),
                                      padding: EdgeInsets.zero,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _headerText(String text) => Text(text, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textMuted));
  Widget _bodyText(String text) => Text(text, style: GoogleFonts.inter(fontSize: 14, color: AppColors.textDark));
}