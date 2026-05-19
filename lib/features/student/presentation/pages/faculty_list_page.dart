import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/responsive.dart';
import '../../../shared/widgets/book_appointment_dialog.dart';
import '../../../shared/widgets/skeleton_loader.dart';

class FacultyListPage extends StatefulWidget {
  const FacultyListPage({super.key});
  @override
  State<FacultyListPage> createState() => _FacultyListPageState();
}

class _FacultyListPageState extends State<FacultyListPage> {
  String _search = '';
  late final Future<QuerySnapshot> _facultyFuture;

  @override
  void initState() {
    super.initState();
    _facultyFuture = FirebaseFirestore.instance.collection('faculty').get();
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.darkText : AppColors.textDark;
    final mutedColor = isDark ? AppColors.darkMuted : AppColors.textMuted;

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Faculty Directory',
          style: GoogleFonts.inter(
              fontSize: Responsive.h2(w).fontSize, fontWeight: FontWeight.bold, color: textColor)),
      SizedBox(height: Responsive.s4),
      Text('Browse and book appointments with faculty members',
          style: GoogleFonts.inter(fontSize: Responsive.body(w).fontSize, color: mutedColor)),
      SizedBox(height: Responsive.s20),
      TextField(
        onChanged: (q) => setState(() => _search = q),
        decoration: InputDecoration(
          hintText: 'Search by name, department, or specialization...',
          prefixIcon: Icon(Icons.search_rounded, size: 18, color: mutedColor),
          filled: true,
          fillColor: isDark ? AppColors.darkCard : Colors.white,
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                  color: isDark ? AppColors.darkBorder : const Color(0xFFEEEFF2))),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                  color: isDark ? AppColors.darkBorder : const Color(0xFFEEEFF2))),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
      const SizedBox(height: 16),
      FutureBuilder<QuerySnapshot>(
        future: _facultyFuture,
        builder: (context, snap) {
          if (snap.hasError) {
            return Center(
                child: Text('Failed to load faculty list.',
                    style: GoogleFonts.inter(
                        fontSize: 13,
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.lightTextSecondary)));
          }
          if (!snap.hasData) {
            return LayoutBuilder(builder: (context, box) {
              final cols = box.maxWidth < 400 ? 1 : box.maxWidth < 600 ? 2 : box.maxWidth < 900 ? 3 : 5;
              final gap = 10.0;
              final cardW = (box.maxWidth - gap * (cols - 1)) / cols;
              return Wrap(spacing: gap, runSpacing: gap,
                children: List.generate(cols * 2, (_) => SizedBox(width: cardW, child: const SkeletonFacultyCard())));
            });
          }

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

          return LayoutBuilder(builder: (context, box) {
            final cols = box.maxWidth < 400 ? 1 : box.maxWidth < 600 ? 2 : box.maxWidth < 900 ? 3 : 5;
            final gap = 10.0;
            final cardW = (box.maxWidth - gap * (cols - 1)) / cols;
            return Wrap(spacing: gap, runSpacing: gap,
              children: docs.map((doc) {
                final d = doc.data() as Map<String, dynamic>;
                final name = d['full_name'] as String? ?? 'Faculty';
                final dept = d['department'] as String? ?? '';
                final spec = d['specialization'] as String? ?? '';
                final office = d['office_location'] as String? ?? '';
                final initials = name.split(' ').map((e) => e.isNotEmpty ? e[0] : '').take(2).join().toUpperCase();

                return SizedBox(width: cardW, child: Container(
                  padding: Responsive.cardPadding(w),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkCard : Colors.white,
                    borderRadius: BorderRadius.circular(Responsive.cardRadius(w)),
                    border: Border.all(color: isDark ? AppColors.darkBorder : const Color(0xFFEEEFF2)),
                    boxShadow: isDark ? null : [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 6, offset: const Offset(0, 1))],
                  ),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(children: [
                      Container(
                        width: 42, height: 42,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)]),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(child: Text(initials,
                          style: GoogleFonts.inter(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold))),
                      ),
                      SizedBox(width: Responsive.s8),
                      Expanded(child: Text(name,
                        style: GoogleFonts.inter(fontSize: Responsive.body(w).fontSize,
                          fontWeight: FontWeight.w600, color: textColor),
                        overflow: TextOverflow.ellipsis)),
                    ]),
                    if (dept.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Row(children: [
                        Icon(Icons.business_outlined, size: 12, color: mutedColor),
                        SizedBox(width: Responsive.s4),
                        Flexible(child: Text(dept, style: GoogleFonts.inter(
                          fontSize: Responsive.small(w).fontSize, color: mutedColor),
                          overflow: TextOverflow.ellipsis)),
                      ]),
                    ],
                    if (spec.isNotEmpty) ...[
                      SizedBox(height: Responsive.s2),
                      Row(children: [
                        Icon(Icons.science_outlined, size: 12, color: mutedColor),
                        SizedBox(width: Responsive.s4),
                        Flexible(child: Text(spec, style: GoogleFonts.inter(
                          fontSize: Responsive.small(w).fontSize, color: mutedColor),
                          overflow: TextOverflow.ellipsis)),
                      ]),
                    ],
                    if (office.isNotEmpty) ...[
                      SizedBox(height: Responsive.s2),
                      Row(children: [
                        Icon(Icons.location_on_outlined, size: 12, color: mutedColor),
                        SizedBox(width: Responsive.s4),
                        Flexible(child: Text(office, style: GoogleFonts.inter(
                          fontSize: Responsive.small(w).fontSize, color: mutedColor),
                          overflow: TextOverflow.ellipsis)),
                      ]),
                    ],
                    const SizedBox(height: 10),
                    SizedBox(width: double.infinity, child: ElevatedButton.icon(
                      onPressed: () async {
                        final booked = await BookAppointmentDialog.show(context,
                          facultyId: doc.id, facultyName: name);
                        if (booked == true && context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Appointment submitted! ✓'), backgroundColor: AppColors.success));
                        }
                      },
                      icon: const Icon(Icons.add_rounded, size: 14),
                      label: const Text('Book'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary, foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        textStyle: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        elevation: 0),
                    )),
                  ]),
                ));
              }).toList());
          });
        },
      ),
    ]);
  }
}
