import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/theme/app_colors.dart';

class FacultyListPage extends StatefulWidget {
  const FacultyListPage({super.key});
  @override
  State<FacultyListPage> createState() => _FacultyListPageState();
}

class _FacultyListPageState extends State<FacultyListPage> {
  String _search = '';

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.darkText : AppColors.textDark;
    final mutedColor = isDark ? AppColors.darkMuted : AppColors.textMuted;

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Faculty Directory', style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.bold, color: textColor)),
      const SizedBox(height: 4),
      Text('Browse and book appointments with faculty members', style: GoogleFonts.inter(fontSize: 13, color: mutedColor)),
      const SizedBox(height: 20),
      TextField(
        onChanged: (q) => setState(() => _search = q),
        decoration: InputDecoration(
          hintText: 'Search by name, department, or specialization...',
          prefixIcon: Icon(Icons.search_rounded, size: 18, color: mutedColor),
          filled: true,
          fillColor: isDark ? AppColors.darkCard : Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: isDark ? AppColors.darkBorder : const Color(0xFFEEEFF2))),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: isDark ? AppColors.darkBorder : const Color(0xFFEEEFF2))),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
      const SizedBox(height: 16),
      FutureBuilder<QuerySnapshot>(
        future: FirebaseFirestore.instance.collection('faculty').get(),
        builder: (context, snap) {
          if (!snap.hasData) return const Center(child: CircularProgressIndicator());
          var docs = snap.data!.docs;
          if (_search.isNotEmpty) {
            final q = _search.toLowerCase();
            docs = docs.where((doc) {
              final d = doc.data() as Map<String, dynamic>;
              return (d['full_name'] as String? ?? '').toLowerCase().contains(q) ||
                  (d['department'] as String? ?? '').toLowerCase().contains(q) ||
                  (d['specialization'] as String? ?? '').toLowerCase().contains(q);
            }).toList();
          }
          if (docs.isEmpty) {
            return Padding(
              padding: const EdgeInsets.all(40),
              child: Center(child: Text('No faculty found', style: GoogleFonts.inter(color: mutedColor))),
            );
          }
          return Column(
            children: docs.map((doc) {
              final d = doc.data() as Map<String, dynamic>;
              final name = d['full_name'] as String? ?? 'Faculty';
              final dept = d['department'] as String? ?? '';
              final spec = d['specialization'] as String? ?? '';
              final office = d['office_location'] as String? ?? '';
              final initials = name.split(' ').map((e) => e.isNotEmpty ? e[0] : '').take(2).join().toUpperCase();
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkCard : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: isDark ? AppColors.darkBorder : const Color(0xFFEEEFF2)),
                    boxShadow: isDark ? null : [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 6, offset: const Offset(0, 1))],
                  ),
                  child: Row(children: [
                    Container(
                      width: 48, height: 48,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)]),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(child: Text(initials,
                        style: GoogleFonts.inter(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold))),
                    ),
                    const SizedBox(width: 14),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(name, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: textColor)),
                      if (dept.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Row(children: [
                          Icon(Icons.business_outlined, size: 12, color: mutedColor),
                          const SizedBox(width: 4),
                          Text(dept, style: GoogleFonts.inter(fontSize: 12, color: mutedColor)),
                        ]),
                      ],
                      if (spec.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Row(children: [
                          Icon(Icons.science_outlined, size: 12, color: mutedColor),
                          const SizedBox(width: 4),
                          Text(spec, style: GoogleFonts.inter(fontSize: 12, color: mutedColor)),
                        ]),
                      ],
                      if (office.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Row(children: [
                          Icon(Icons.location_on_outlined, size: 12, color: mutedColor),
                          const SizedBox(width: 4),
                          Text(office, style: GoogleFonts.inter(fontSize: 12, color: mutedColor)),
                        ]),
                      ],
                    ])),
                    ElevatedButton.icon(
                      onPressed: () => context.goNamed('student-book-appointment'),
                      icon: const Icon(Icons.add_rounded, size: 14),
                      label: const Text('Book'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        textStyle: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        elevation: 0,
                      ),
                    ),
                  ]),
                ),
              );
            }).toList(),
          );
        },
      ),
    ]);
  }
}
