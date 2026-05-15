import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

// Placeholder pages for student features

class StudentProfilePage extends StatelessWidget {
  const StudentProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: Text('Student Profile', style: TextStyle(color: AppColors.textPrimary))),
    );
  }
}
